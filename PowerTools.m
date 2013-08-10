(* ::Package:: *)

(* Created 4-Jan-2013 by David Kirkby (University of California, Irvine) <dkirkby@uci.edu> *)

BeginPackage["DeepZot`PowerTools`"]


PowerTools::usage=
"A collection of utilities for working with cosmological power spectra.";


makePower::usage=
"makePower[data] uses a list of tabulated values {k,P(k)} in data to create a function that
interpolates in log(k) and P(k) and extrapolates using power laws in k. The following options
are supported:
  verbose (False) - set True to print out kmin, kmax, and the number of points being used.
  extrapolateBelow (True) - set False to print a message if extrapolation below kmin is attempted.
  extrapolateAbove (True) - set False to print a message if extrapolation above kmax is attempted.";


createDistortionModel::usage=
"createDistortionModel[name] associates the following definitions with the symbol name:
 - redshiftSpaceDistortion[name][k,mu]
 - nonlinearDistortion[name][k,mu]
 - transformedCoordinates[name][kp,mup]
Separate help is available for each of these definitions. Use the following options
(defaults in parentheses) to customize the created distortion model:
 - bias (1) tracer-1 bias
 - beta (0) tracer-1 redshift-space linear distortion parameter
 - bias2(Automatic) tracer-2 bias or same as tracer-1 bias if Automatic
 - beta2(Automatic) tracer-2 beta or same as tracer-1 beta if Automatic
 - sigL (0) longitudinal component of non-linear broadening sigma
 - sigT (0) transverse component of non-linear broadening sigma
 - sigS (0) fingers of god sigma
Use OptionValue[name,opt] to get option values associated with a named distortion model.
To clear a previously defined model, use Clear[name].";


redshiftSpaceDistortion::usage=
"redshiftSpaceDistortion[model][k,mu] calculates the redshift-space distortion factor.";


nonlinearDistortion::usage=
"nonlinearDistortion[model][k,mu] calculates the non-linear distortion factor.";


projectMultipole::usage=
"projectMultipole[f,ell] evaluates the multipole projection integral of f(mu)P(ell,mu) over {-1,+1}, scaled by (2 ell+1)/2.";


distortionMultipoleFunction::usage=
"distortionMultipoleFunction[model,kmin,kmax,ell,nPtsPerDecade] returns an interpolated function for kmin < k < kmax for the
specified distortion model multipole.";


sbTransform::usage=
"sbTransform[plfunc,rmin,rmax,ell,veps] calculates the spherical Bessel transform
of the specified function for multipole ell. Returns an interpolating function
defined for r in [rmin,rmax] that is free of any aliasing artifacts.
Use the veps parameter to control the numerical accuracy of the result.
sbTransform[plfunc,rmin,rmax,ell,veps,True] displays the k range and
sampling that is being used, which can be useful in building a suitable plfunc.";


createCorrelationFunction::usage=
"createCorrelationFunction[linearPower,rmin,rmax] returns a function of (r,mu) that evaluates the correlation function
corresponding to the specified linear theory power spectrum.";


createCorrelationMultipole::usage=
"createCorrelationMultipole[xi,rmin,rmax,ell] returns an interpolation function for the specified multipole of the specified
xi(r,mu) function, valid over the specified range of r. Options include:
  - alphaP : rescaling parallel to the line of sight (default 1)
  - alphaT : rescaling transverse to the line of sight (default 1)
Note that alphaP or alphaT different from 1 will generally require that xi(r,mu) be valid outside [rmin,rmax].";


Begin["Private`"]


powerLaw[{{k1_,p1_},{k2_,p2_}}]:=
Module[{a,c},
	a=Log[p2/p1]/Log[k2/k1];
	c=p1/k1^a;
	Function[k,c k^a]
]


Clear[makePower]
makePower[tabulated_,OptionsPattern[]]:=
With[{verbose=OptionValue["verbose"],extrapolateBelow=OptionValue["extrapolateBelow"],extrapolateAbove=OptionValue["extrapolateAbove"]},
Module[{interpolator,kmin,kmax,plo,phi},
	interpolator=Interpolation[tabulated/.{k_,Pk_}:>{Log[k],Pk}];
	kmin=tabulated[[1,1]];
	kmax=tabulated[[-1,1]];
    If[verbose===True,Print["makePower using ",Length[tabulated]," points covering ",kmin," <= k <= ",kmax]];
	plo=If[extrapolateBelow===True,powerLaw[tabulated[[;;2]]],Message[makePower::ExtrapolationDisabled,#1,"<",kmin]&];
	phi=If[extrapolateAbove===True,powerLaw[tabulated[[-2;;]]],Message[makePower::ExtrapolationDisabled,#1,">",kmax]&];
	Function[k,
		Which[
			k<=kmin,plo[k],
			k>=kmax,phi[k],
			True,interpolator[Log[k]]
		]
	]
]]
Options[makePower]={"verbose"->False,"extrapolateBelow"->True,"extrapolateAbove"->True};
makePower::ExtrapolationDisabled="k = `1` is `2` `3`.";


Clear[createDistortionModel]
createDistortionModel[name_,OptionsPattern[]]:=
With[{
    bias=OptionValue["bias"],
    beta=OptionValue["beta"],
    bias2Option=OptionValue["bias2"],
    beta2Option=OptionValue["beta2"],
    sigL=OptionValue["sigL"],
    sigT=OptionValue["sigT"],
    sigS=OptionValue["sigS"],
    multipoleRescalingOption=OptionValue["multipoleRescaling"]
},
Module[{bias2,beta2},
    Clear[name];
    bias2=If[bias2Option===Automatic,bias,bias2Option];
    beta2=If[beta2Option===Automatic,beta,beta2Option];
    Options[name]^={ "bias"->bias,"beta"->beta,"bias2"->bias,"beta2"->beta2,"sigL"->sigL,"sigT"->sigT,"sigS"->sigS };
    redshiftSpaceDistortion[name]^=Function[{k,mu},Evaluate[Simplify[bias bias2(1+beta mu^2)(1+beta2 mu^2)]]];
    nonlinearDistortion[name]^=Function[{k,mu},Evaluate[Simplify[
        Exp[-(mu^2 sigL^2+(1-mu^2)sigT^2)k^2/2]/(1+(mu sigS k)^2)^2]]];
    multipoleRescaling[name]^=multipoleRescalingOption;
]]
SetAttributes[createDistortionModel,HoldFirst]
Options[createDistortionModel]={
    "bias"->1,"beta"->0,"bias2"->Automatic,"beta2"->Automatic,"sigL"->0,"sigT"->0,"sigS"->0,"multipoleRescaling"->None
};


projectMultipole[f_,ell_]:=(2 ell+1)/2 NIntegrate[f[mu]LegendreP[ell,mu],{mu,-1,+1},AccuracyGoal->12]


distortionMultipoleFunction[name_,kmin_,kmax_,ell_,OptionsPattern[]]:=
With[{
  nPtsPerDecade=OptionValue["nPtsPerDecade"],
  padFraction=OptionValue["padFraction"]
},
Module[{index,rescale,nk,dk,k,pts,interpolator},
  index=1+ell/2;
  rescale=Which[multipoleRescaling[name]===None,1,index<=Length[multipoleRescaling[name]],multipoleRescaling[name][[index]],True,1];
  Print["using rescale = ",rescale," for ell = ",ell];
  nk=Max[10,Ceiling[Log[10,kmax/kmin]nPtsPerDecade]];
  dk=padFraction^2(kmax/kmin)^(1/(nk-1));
  pts=Table[
    k=(kmin/padFraction) dk^(i-1);
    {Log[k],projectMultipole[rescale redshiftSpaceDistortion[name][k,##] nonlinearDistortion[name][k,##]&,ell]},
    {i,nk}
  ];
  interpolator=Interpolation[pts];
  Function[k,interpolator[Log[k]]]
]]
Options[distortionMultipoleFunction]={"nPtsPerDecade"->5,"padFraction"->1.05};


kr0[ell_,hankel_:False]:=
If[hankel,
2 \[Pi]^(1/(-1-2 ell)) Gamma[1+ell]^(2/(1+2 ell)),
2 \[Pi]^(-(1/(2 + 2 ell)))Gamma[3/2 + ell]^(1/(1 + ell))]


s0[ell_,hankel_:False]:=If[hankel,4/(2 ell + 1), 2/(ell + 1)]


f0[ell_,hankel_:False]:=With[{kr=kr0[ell,hankel]},If[hankel,(2/(\[Pi] kr))^(1/2),1/kr]]


nds[ell_,eps_,aligned_:True,hankel_:False]:=
Module[{kr,s,Y,\[Delta],nds0},
kr=kr0[ell,hankel];
s=s0[ell,hankel];
Y=(kr/(2\[Pi]))eps^(-s);
\[Delta]=Log[If[hankel,(Ceiling[1/8+Y/4]-1/8)/Y,Ceiling[Y]/Y]];
nds0=-s Log[eps];
If[aligned,nds0+\[Delta],nds0]
]


ds[ell_,eps_,hankel_:False]:= \[Pi]/kr0[ell,hankel] eps^(s0[ell,hankel])


ff[s_,ell_,kr0_,\[Alpha]_]:=Exp[\[Alpha] s]SphericalBesselJ[ell,kr0 Exp[s]]


gg[s_,plfunc_,ell_,k0_,\[Alpha]_]:=I^ell/(2\[Pi]^2)Exp[(3-\[Alpha])s]k0^3 plfunc[k0 Exp[s]]


ffH[s_,ell_,kr0_,\[Alpha]_]:=Exp[\[Alpha] s]BesselJ[ell,kr0 Exp[s]]


ggH[s_,plfunc_,ell_,k0_,\[Alpha]_]:=Exp[(2-\[Alpha])s]k0^2 plfunc[k0 Exp[s]]


wrap[n_,nmax_]:=If[n<nmax,n,n-2nmax]


epsApprox[veps_,ell_,hankel_:False]:=
With[{c=\[Pi]/kr0[ell,hankel]},
Module[{L0,L1,L2,tmp},
L0=veps/c//N;
Assert[L0<0.35];
L1=Log[L0];
L2=Log[-L1];
tmp=-L0/(6L1^3)(6 L1^4+6L1^2L2(L1+1)-3L1 L2(L2-2)+L2(2L2^2-9L2+6));
tmp^(1/s0[ell,hankel])
]]


getndsf[veps_,ell_,hankel_]:=Module[{eps,ndsf,dsfmax,nsf,dsf},
  eps=epsApprox[veps,ell,hankel];
  ndsf=nds[ell,eps,True,hankel];
  dsfmax=Min[ds[ell,eps,hankel],Log[10]/40];
  nsf=Ceiling[ndsf/dsfmax];
  dsf=ndsf/nsf;
  {nsf,dsf}
]


Clear[sbTransformWork]
sbTransformWork[callback_,rmin_,rmax_,ell_,veps_,hankel_,verbose_]:=
Module[{nsf,dsf,kr,k0,r0,nsg,ntot,n,\[Alpha],ffunc,gfunc,fdata,fnorm,plfunc,gdata,fgdata,rgrid,xigrid,rzoom,xizoom,popts},
{nsf,dsf}=getndsf[veps,ell,hankel];
kr=kr0[ell,hankel]//N;
r0=Sqrt[rmin rmax];
k0=kr/r0;
(* Calculate the number of samples needed to cover (rmin,rmax) *)
nsg=Ceiling[Log[rmax/rmin]/(2dsf)];
ntot=nsf+nsg;
(* Get the Pl(k) function to use *)
plfunc=callback[k0 Exp[-ntot dsf],k0 Exp[+ntot dsf],2 ntot];
(* Start tabulating... *)
\[Alpha]=If[hankel,(1-2ell)/4,(1-ell)/2];
ffunc=If[hankel,ffH,ff];
fdata=Table[
  n=wrap[m,nsg+nsf];
  If[Abs[n]<=nsf,ffunc[n dsf,ell,kr,\[Alpha]]dsf,0],
  {m,0,2(nsg+nsf)-1}
];
(* Note that we use -s here ! *)
gfunc=If[hankel,ggH,gg];
gdata=Table[gfunc[-n dsf,plfunc,ell,k0,\[Alpha]]dsf,{n,-ntot,ntot-1}];
fgdata=Re[Fourier[
  Fourier[fdata,FourierParameters->{1,-1}] Fourier[gdata,FourierParameters->{1,-1}]/(2ntot),
  FourierParameters->{1,+1}
]];
rgrid=Table[r0 Exp[n dsf],{n,-ntot,ntot-1}];
xigrid=fgdata (rgrid/r0)^(-\[Alpha])/dsf;
{fdata,gdata,fgdata,rgrid,xigrid,nsf}
]


Clear[sbTransform]
sbTransform[plfunc_,rmin_,rmax_,ell_,veps_,OptionsPattern[]]:=
With[{
  verboseOption=OptionValue["verbose"],
  distortionOption=OptionValue["distortion"],
  distortionSamplingOption=OptionValue["distortionSampling"],
  padFractionOption=OptionValue["padFraction"],
  hankelOption=OptionValue["hankel"]
},
Module[{fdata,gdata,fgdata,rgrid,xigrid,nsf,rzoom,xizoom,interpolator,callback,distortion},
  callback=Function[{kmin,kmax,nk},
    If[verboseOption===True,Print[kmin " \[LessEqual] k \[LessEqual] ",kmax," is covered with ",nk," samples (",nk/Log[kmax/kmin]," per logint)."]];
    If[distortionOption===None,
      plfunc,
      If[verboseOption===True,Print["Sampling distortion model at ",distortionSamplingOption," points per decade."]];
      distortion=distortionMultipoleFunction[distortionOption,kmin,kmax,ell,"nPtsPerDecade"->distortionSamplingOption];
      Function[k,plfunc[k]distortion[k]]
    ]
  ];
  {fdata,gdata,fgdata,rgrid,xigrid,nsf}=sbTransformWork[callback,rmin/padFractionOption,rmax padFractionOption,ell,veps,hankelOption,verboseOption];
  rzoom=rgrid[[nsf+1;;-nsf-1]];
  xizoom=xigrid[[nsf+1;;-nsf-1]];
  interpolator=Interpolation[Transpose[{Log[rzoom], xizoom}]];
  Function[r,interpolator[Log[r]]]
]]
Options[sbTransform]={
"verbose"->False,"distortion"->None,"distortionSampling"->5,"padFraction"->1.05,"hankel"->False
};


createCorrelationFunction[linearPower_,rmin_,rmax_,OptionsPattern[]]:=
With[{
  verboseOption=OptionValue["verbose"],
  lmaxOption=OptionValue["lmax"],
  distortionOption=OptionValue["distortion"],
  distortionSamplingOption=OptionValue["distortionSampling"],
  vepsOption=OptionValue["veps"]
},
Module[{lvec,xi},
  lvec=Range[0,lmaxOption,2];
  xi=Table[
    sbTransform[linearPower,rmin,rmax,ell,vepsOption,
      "distortion"->distortionOption,"distortionSampling"->distortionSamplingOption,"verbose"->verboseOption],
    {ell,lvec}
  ];
  Function[{r,mu},Sum[xi[[j]][r]LegendreP[lvec[[j]],mu],{j,Length[lvec]}]]
]]
Options[createCorrelationFunction]={
  "verbose"->False,"lmax"->4,"distortion"->None,"distortionSampling"->5,"veps"->0.001
};


createCorrelationMultipole[xi_,rmin_,rmax_,ell_,OptionsPattern[]]:=
With[{
  alphaPOption=OptionValue["alphaP"],
  alphaTOption=OptionValue["alphaT"],
  npointsOption=OptionValue["npoints"]
},
Module[{alphaP,alphaT,npoints,rvec,f,pts},
  alphaP=alphaPOption;
  alphaT=alphaTOption;
  npoints=If[npointsOption===Automatic,Ceiling[rmax-rmin],npointsOption];
  rvec=Table[rmin+(j-1)(rmax-rmin)/(npoints-1),{j,npoints}];
  f=Function[{r,mu},With[{alpha=Sqrt[alphaP^2 mu^2 + alphaT^2 (1-mu^2)]},xi[alpha r,(alphaP/alpha)mu]]];
  pts=Table[{r,projectMultipole[f[r,##]&,ell]},{r,rvec}];
  Interpolation[pts]
]]
Options[createCorrelationMultipole]={
  "alphaP"->1,"alphaT"->1,"npoints"->Automatic
};


End[]


EndPackage[]
