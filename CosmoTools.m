(* ::Package:: *)

(* Created 4-Jan-2013 by David Kirkby (University of California, Irvine) <dkirkby@uci.edu> *)

(* As of version 9, PhysicalConstants has been replaced by the built-in Quantity[],
but we keep using it here for backwards compatibility *)
Off[General::obspkg]
BeginPackage["DeepZot`CosmoTools`",{"Units`","PhysicalConstants`"}]


CosmoTools::usage=
"A collection of utilities for cosmological calculations."


criticalDensityToday::usage=
"criticalDensityToday[hValue] calcualtes the present critical density in J/m^3."


radiationDensity::usage=
"radiationDensity[Tcmb,Nnu] calculates the Stefan-Boltzmann radiation energy density
in J/m^3 for a CMB temperature Tcmb in Kelvin and Nnu massless neutrinos."


zstar::usage=
"zstar[\[CapitalOmega]mh2,\[CapitalOmega]bh2] calculates the redshift of last scattering using equation (E-1)
of Hu & Sugiyama 1996 (astro-ph/9510117)."


zeq::usage=
"zeq[\[CapitalOmega]mh2,Tcmb] calculates the redshift of matter-radiation equality using equation (2)
of Eistenstein & Hu 1998 (astro-ph/9709112)."


zdrag::usage=
"zdrag[\[CapitalOmega]mh2,\[CapitalOmega]bh2] calculates the redshift at which the baryon-photon fluid separates,
defined as the moment when the Compton drag experienced by the baryons falls below
some threshold, using equation (4) of Eistenstein & Hu 1998 (astro-ph/9709112)."


createCosmology::usage=
"createCosmology[name] associates the following definitions with the symbol name:
 - \[CapitalOmega]rad[name][z]
 - \[CapitalOmega]de[name][z]
 - \[CapitalOmega]mat[name][z]
 - H0[name]
 - Hratio[name][z]
 - curvatureTransform[name][x]
 - zstar[name]
 - zeq[name]
 - zdrag[name]
 - betas[name][z]
Separate help is available for each of these definitions, e.g., ?\[CapitalOmega]rad.
Use the following options (defaults in parentheses) to customize the
created cosmology:
 - h (0.7) H0/(100 km/s/Mpc).
 - \[CapitalOmega]\[CapitalLambda] (0.73) present-day fraction of dark energy.
 - \[CapitalOmega]bh2 (0.0227) present-day physical baryon fraction.
 - w0 (-1) dark-energy equation parameter state present-day value.
 - wa (0) dark-energy equation of state parameter derivative wrt scale a.
 - \[CapitalOmega]k (0) present-day curvature fraction.
 - Tcmb (2.725) present-day CMB temperature in Kelvin.
 - Nnu (3.046) effective number of massless neutrinos.
 - ns (0.972) scalar primordial power spectral index.
 - amps (2.41e-9) scalar primordial power amplitude.
 - kpivot (0.002/Mpc) pivot wavenumber used to define primordial scalar power.
 - retau (0.089) optical depth to reionization.
Use OptionValue[name,opt] to get option values associated with a named
cosmology. To clear a previously defined cosmology, use Clear[name]. Use
the name provided here to identify the created cosmology in functions
like comovingDistanceFunction."


exportToCamb::usage=
"exportToCamb[filename,name] writes the parameters of the named cosmology to the
specified filename in CAMB input format."


\[CapitalOmega]rad::usage=
"\[CapitalOmega]rad[name][z] returns the radiation energy density relative to the critical density at the specified redshift."


\[CapitalOmega]photons::usage=
"\[CapitalOmega]photons[name][z] returns the photon energy density relative to the critical density at the specified redshift."


\[CapitalOmega]de::usage=
"\[CapitalOmega]de[name][z] returns the dark-energy density relative to the critical density at the specified redshift."


\[CapitalOmega]mat::usage=
"\[CapitalOmega]mat[name][z] returns the matter energy density relative to the critical density at the specified redshift."


H0::usage=
"H0[name] returns H0 in (km/s)/Mpc."


Hratio::usage=
"Hratio[name][z] returns H(z)/H0."


hubbleDistance::usage=
"hubbleDistance[name] returns the Hubble distance c/H0 in Mpc (not Mpc/h)."


curvatureTransform::usage=
"curvatureTransform[name][x] returns the comoving transverse distance DM corresponding to the
scaled comoving line-of-sight distance x = DC/(c/H0)."


primordialPower::usage=
"primordialPower[name][k] returns the primordial power P(k) in 1/Mpc for k in 1/Mpc."


betas::usage=
"betas[name][z] returns the sound speed in the bayron-photon fluid relative to the speed of light."


comovingDistanceFunction::usage=
"comovingDistanceFunction[cosmology,zmax] returns a function that evaluates the comoving distance
along the line of sight to a redshift z <= zmax for the named cosmology. Possible options (with
defaults in parentheses) are:
 - physical (False) units are Mpc (True) or Mpc/h (False).
 - inverted (False) return inverse function z(Dc) instead of Dc(z) when True.
 - pointsPerDecade (20) number of interpolation points to use per decade."


transverseDistanceFunction::usage=
"transverseDistanceFunction[cosmology,zmax] returns a function that evaluates the comoving distance
transverse to the line of sight at a redshift z <= zmax for the named cosmology. Options are the same
as for comovingDistanceFunction."


angularDiameterDistanceFunction::usage=
"angularDiameterDistanceFunction[cosmology,zmax] returns a function that evaluates the
angular diameter distance to a redshift z <= zmax for the named cosmology. Options are the same
as for comovingDistanceFunction."


luminosityDistanceFunction::usage=
"angularDiameterDistanceFunction[cosmology,zmax] returns a function that evaluates the
luminosity distance to a redshift z <= zmax for the named cosmology. Options are the same
as for comovingDistanceFunction."


ageOfUniverse::usage=
"ageOfUniverse[cosmology] returns the age of the universe in Gyr for the named cosmology.
The result is cached after first evaluation."


lookbackTimeFunction::usage=
"lookbackTimeFunction[cosmology,zmax] returns a function that evaluates the lookback time
to a redshift z <= zmax for the named cosmology. Possible options are:
 - physical (True) units Gyr (True) or Gyr/h (False).
 - pointsPerDecade (20) number of interpolation points to use per decade.
 - inverted (False) return inverse function z(tLB) instead of tLB(z) when True."


conformalTimeFunction::usage=
"conformalTimeFunction[cosmology,zmax] returns a function that evaluates the conformal time
at redshift z <= zmax for the named cosmology. Options are the same as for lookbackTimeFunction."


soundHorizonFunction::usage=
"soundHorizonFunction[cosmology,zmax] returns a function that evaluates the sound horizon at
redshift z <= zmax for the named cosmology. Options are the same as for comovingDistanceFunction."


rsdrag::usage=
"rsdrag[cosmology] returns the sound horizon in Mpc (not Mpc/h) at zdrag for the named cosmology.
The result is cached after the first evaluation."


recombinationXe::usage=
"recombinationXe[cosmology,zmin,zmax] returns a 2 functions that evaluate the free electron fraction
(relative to Hydrogen nuclei) and the matter temperature respectively at redshift zmin <= z <= zmax 
for the named cosmology."


\[Tau]b::usage=
"\[Tau]b[cosmology,xe,zd,zmin] calculates the baryon drag optical depth to redshift zd > zmin for 
the named cosmology and free election function xe."


Begin["Private`"]


criticalDensityToday[hvalue_]:=
Units`Convert[
	3 PhysicalConstants`SpeedOfLight^2/
	(8 \[Pi] PhysicalConstants`GravitationalConstant)
	(100 hvalue Units`Kilo Units`Meter/Units`Second/(Units`Mega Units`Parsec))^2/
	(Units`Joule/Units`Meter^3),1
]


radiationDensity[Tcmb_,Nnu_]:=
Units`Convert[
    (\[Pi]^2/15/(PhysicalConstants`PlanckConstantReduced PhysicalConstants`SpeedOfLight)^3
    (PhysicalConstants`BoltzmannConstant Tcmb Units`Kelvin)^4(1+7/8(4/11)^(4/3)Nnu))/
    (Units`Joule/Units`Meter^3),1
]


photonDensity[Tcmb_]:=
Units`Convert[
    (\[Pi]^2/15/(PhysicalConstants`PlanckConstantReduced PhysicalConstants`SpeedOfLight)^3
    (PhysicalConstants`BoltzmannConstant Tcmb Units`Kelvin)^4)/
    (Units`Joule/Units`Meter^3),1
]


zstar[\[CapitalOmega]mh2_,\[CapitalOmega]bh2_]:=
With[{g1=0.0783 \[CapitalOmega]bh2^(-0.238)/(1+39.5 \[CapitalOmega]bh2^(0.763)),g2=0.560/(1+21.1 \[CapitalOmega]bh2^(1.81))},
    1048(1+0.00124 \[CapitalOmega]bh2^(-0.738))(1+g1 \[CapitalOmega]mh2^g2)
]


zeq[\[CapitalOmega]mh2_,Tcmb_]:=25000 \[CapitalOmega]mh2 (2.7/Tcmb)^4


zdrag[\[CapitalOmega]mh2_,\[CapitalOmega]bh2_]:=
With[{b1=0.313 \[CapitalOmega]mh2^(-0.419)(1+0.607 \[CapitalOmega]mh2^(0.674)),b2=0.238 \[CapitalOmega]mh2^(0.223)},
    1291 \[CapitalOmega]mh2^(0.251)/(1+0.659 \[CapitalOmega]mh2^(0.828))(1+b1 \[CapitalOmega]bh2^b2)
]


(* Returns numerator/H0 in the specified units *)
hubbleScale[numerator_,hValue_,units_]:=
Units`Convert[numerator/(100 hValue Units`Kilo Units`Meter/Units`Second/(Units`Mega Units`Parsec))/units,1]


Clear[createCosmology]
createCosmology::overconstrained = "Parameters are overconstrained: \[CapitalOmega]\[CapitalLambda]=`1`, \[CapitalOmega]m=`2`, \[CapitalOmega]rad=`3`, \[CapitalOmega]k=`4`.";
createCosmology[name_,OptionsPattern[]]:=
With[{
    h=OptionValue["h"],
    \[CapitalOmega]\[CapitalLambda]=OptionValue["\[CapitalOmega]\[CapitalLambda]"],
    \[CapitalOmega]m=OptionValue["\[CapitalOmega]m"],
    \[CapitalOmega]bh2=OptionValue["\[CapitalOmega]bh2"],
    w0=OptionValue["w0"],
    wa=OptionValue["wa"],
    \[CapitalOmega]k=OptionValue["\[CapitalOmega]k"],
    Tcmb=OptionValue["Tcmb"],
    Nnu=OptionValue["Nnu"],
    ns=OptionValue["ns"],
    amps=OptionValue["amps"],
    kpivot=OptionValue["kpivot"],
    retau=OptionValue["retau"],
	YP=OptionValue["YP"]
},
Module[{\[CapitalOmega]mval,\[CapitalOmega]\[CapitalLambda]val},
    name/: Options[name]= { "h"->h,"\[CapitalOmega]\[CapitalLambda]"->\[CapitalOmega]\[CapitalLambda],"\[CapitalOmega]bh2"->\[CapitalOmega]bh2,"w0"->w0,"wa"->wa,"\[CapitalOmega]k"->\[CapitalOmega]k,
        "Tcmb"->Tcmb,"Nnu"->Nnu,"ns"->ns,"amps"->amps,"kpivot"->kpivot,"retau"->retau,"YP"->YP };
    name/: \[CapitalOmega]rad[name]=Function[z,Evaluate[Simplify[radiationDensity[Tcmb,Nnu]/criticalDensityToday[h](1+z)^4]]];
	name/: \[CapitalOmega]photons[name]=Function[z,Evaluate[Simplify[photonDensity[Tcmb]/criticalDensityToday[h](1+z)^4]]];
    \[CapitalOmega]mval=If[\[CapitalOmega]m===Automatic,1-\[CapitalOmega]\[CapitalLambda]-\[CapitalOmega]k-\[CapitalOmega]rad[name][0],\[CapitalOmega]m];
    \[CapitalOmega]\[CapitalLambda]val=If[\[CapitalOmega]\[CapitalLambda]===Automatic,1-\[CapitalOmega]m-\[CapitalOmega]k-\[CapitalOmega]rad[name][0],\[CapitalOmega]\[CapitalLambda]];
    If[\[CapitalOmega]m+\[CapitalOmega]\[CapitalLambda]+\[CapitalOmega]k+\[CapitalOmega]rad[name][0]!=1,
        Message[createCosmology::overconstrained,\[CapitalOmega]\[CapitalLambda],\[CapitalOmega]m,\[CapitalOmega]rad[name][0],\[CapitalOmega]k];
        Return[$Failed]
    ];
    name/: \[CapitalOmega]de[name]=Function[z,Evaluate[Simplify[\[CapitalOmega]\[CapitalLambda]val Exp[3(-((wa z)/(1 + z)) + (1 + w0 + wa) Log[1 + z])]]]];
    name/: \[CapitalOmega]mat[name]=Function[z,Evaluate[Simplify[\[CapitalOmega]mval (1+z)^3]]];
    name/: H0[name]=100 h;
    name/: Hratio[name]=Function[z,Evaluate[Sqrt[Simplify[\[CapitalOmega]de[name][z]+\[CapitalOmega]k (1+z)^2+\[CapitalOmega]mat[name][z]+\[CapitalOmega]rad[name][z]]]]];
    name/: hubbleDistance[name]=hubbleScale[PhysicalConstants`SpeedOfLight,h,Units`Mega Units`Parsec];
    name/: curvatureTransform[name]=Function[x,Evaluate[Simplify[Which[
        \[CapitalOmega]k>0,Sinh[Sqrt[\[CapitalOmega]k]x]/Sqrt[\[CapitalOmega]k],\[CapitalOmega]k<0,Sin[Sqrt[-\[CapitalOmega]k]x]/Sqrt[-\[CapitalOmega]k],True,x]]]];
    name/: primordialPower[name]=Function[k,Evaluate[Simplify[amps (k/kpivot)^(ns-1)k]]];
    With[{\[CapitalOmega]mh2=\[CapitalOmega]mat[name][0]h^2},
        name/: zstar[name]=zstar[\[CapitalOmega]mh2,\[CapitalOmega]bh2];
        name/: zeq[name]=If[Tcmb>0,zeq[\[CapitalOmega]mh2,Tcmb],Indeterminate];
        name/: zdrag[name]=zdrag[\[CapitalOmega]mh2,\[CapitalOmega]bh2];
    ];
    With[{\[CapitalOmega]\[Gamma]=radiationDensity[Tcmb,0]/criticalDensityToday[h],\[CapitalOmega]b=\[CapitalOmega]bh2/h^2},
        name/: betas[name]=If[\[CapitalOmega]\[Gamma]>0,Function[z,Evaluate[Simplify[1/Sqrt[3(1+(3\[CapitalOmega]b)/(4\[CapitalOmega]\[Gamma])/(1+z))]]]],Indeterminate];
    ]
]]
SetAttributes[createCosmology,HoldFirst]
Options[createCosmology]={
    "h"->0.7,"\[CapitalOmega]\[CapitalLambda]"->0.73,"\[CapitalOmega]m"->Automatic,"\[CapitalOmega]bh2"->0.0227,"w0"->-1,"wa"->0,"\[CapitalOmega]k"->0,
    "Tcmb"->2.72548,"Nnu"->3.03761,"ns"->0.972,"amps"->(2.41*10^-9),"kpivot"->0.002,
    "retau"->0.089,"YP"->0.24
};


Clear[exportToCamb]
exportToCamb[filename_,cosmology_,form_:CForm]:=With[{
    h=OptionValue[cosmology,"h"],
    \[CapitalOmega]m=\[CapitalOmega]mat[cosmology][0],
    \[CapitalOmega]bh2=OptionValue[cosmology,"\[CapitalOmega]bh2"],
    path=DirectoryName[filename],
    tag=FileBaseName[filename]
},
Assert[OptionValue[cosmology,"wa"]==0];
Export[filename,{
"## File automatically generated by DeepZot`CosmoTools`exportToCamb on "<>DateString[],
"## Recreate the cosmology that generated this file using:",
"## createCosmology["<>tag<>","<>ToString[InputForm[Options[cosmology]]]<>"]",
"use_physical = T",
"hubble = "<>ToString[H0[cosmology],form],
"ombh2 = "<>ToString[\[CapitalOmega]bh2,form],
"omch2 = "<>ToString[\[CapitalOmega]m h^2 - \[CapitalOmega]bh2,form],
"omnuh2 = 0",
"omk = "<>ToString[OptionValue[cosmology,"\[CapitalOmega]k"],form],
"w = "<>ToString[OptionValue[cosmology,"w0"],form],
"temp_cmb = "<>ToString[OptionValue[cosmology,"Tcmb"],form],
"massless_neutrinos = "<>ToString[OptionValue[cosmology,"Nnu"],form],
"massive_neutrinos  = 0",
"scalar_amp(1) = "<>ToString[OptionValue[cosmology,"amps"],form],
"scalar_spectral_index(1) = "<>ToString[OptionValue[cosmology,"ns"],form],
"pivot_scalar = "<>ToString[OptionValue[cosmology,"kpivot"],form],
"re_optical_depth = "<>ToString[OptionValue[cosmology,"retau"],form],
"output_root = "<>path<>tag,
""
},"Table"]]


(* Builds a function that evaluates f[z]=scale*transform[z,Integral[integrand[zz],{zz,0,z}]] using interpolation
in log(1+z) with the specified number of points per decade. The default scale=1 and transform[z,f]=f.
With inverted->True, evaluates z[f] instead of f[z]. *)
Clear[buildFunction]
buildFunction[integrand_,zmax_,OptionsPattern[]]:=
With[{pointsPerDecade=OptionValue["pointsPerDecade"],inverted=OptionValue["inverted"],
scale=OptionValue["scale"],transform=OptionValue["transform"]},
Module[{npts,ds,sval,partials,tabulated,interpolator},
	npts=Ceiling[N[Log[1+zmax]pointsPerDecade/Log[10]]];
    (* Integrate over equally spaced intervals in s = log(1+z) *)
    ds=Log[1+zmax]/(npts-1);
	sval=Table[n ds,{n,0,npts-1}];
	partials=Table[NIntegrate[integrand[Exp[s]-1]Exp[s],{s,sval[[n]],sval[[n+1]]}],{n,1,npts-1}];
    (* Accumulate the partials and add the boundary condition that the integral is zero at z = 0 *)
	tabulated=Prepend[Accumulate[partials],0];
    (* Apply the scale and transform[z,f] to the cummulative integrals *)
    tabulated=scale Apply[transform,Transpose[{Exp[sval]-1,tabulated}],1];
    (* Create the requested interpolation f(z) or z(f) *)
    If[inverted===True,
        interpolator=Interpolation[Transpose[{tabulated,sval}]];
	        Function[f,Exp[interpolator[f]]-1],
    	interpolator=Interpolation[Transpose[{sval,tabulated}]];
            Function[z,interpolator[Log[1+z]]]
    ]
]]
Options[buildFunction]={"pointsPerDecade"->20,"scale"->1,"transform"->(#2&),"inverted"->False};


(* Builds a distance function using options physical (Mpc vs Mpc/h), transverse (apply curvatureTransform), and
multiplying result by (1+z)^zpower *)
Clear[buildDistanceFunction]
buildDistanceFunction[cosmology_,zmax_,options:OptionsPattern[{buildDistanceFunction,buildFunction}]]:=
With[{physical=OptionValue["physical"],transverse=OptionValue["transverse"],zpower=OptionValue["zpower"]},
Module[{h,scale,transform},
    h=If[physical===True,OptionValue[cosmology,"h"],1];
    scale=hubbleScale[PhysicalConstants`SpeedOfLight,h,Units`Mega Units`Parsec];
    transform=If[transverse===True,curvatureTransform[cosmology][#2](1+#1)^zpower,#2 (1+#1)^zpower]&;
	buildFunction[1/Hratio[cosmology][#1]&,zmax,"scale"->scale,"transform"->transform,
        FilterRules[{options},Options[buildFunction]]
    ]
]]
Options[buildDistanceFunction]={"physical"->False,"transverse"->False,"zpower"->0};


Clear[comovingDistanceFunction]
comovingDistanceFunction[cosmology_,zmax_,options:OptionsPattern[]]:=
buildDistanceFunction[cosmology,zmax,"transverse"->False,"zpower"->0,options]
Options[comovingDistanceFunction]={"physical"->False,"inverted"->False,"pointsPerDecade"->20};


Clear[transverseDistanceFunction]
transverseDistanceFunction[cosmology_,zmax_,options:OptionsPattern[comovingDistanceFunction]]:=
buildDistanceFunction[cosmology,zmax,"transverse"->True,"zpower"->0,options]


Clear[angularDiameterDistanceFunction]
angularDiameterDistanceFunction[cosmology_,zmax_,options:OptionsPattern[comovingDistanceFunction]]:=
buildDistanceFunction[cosmology,zmax,"transverse"->True,"zpower"->-1,options]


Clear[luminosityDistanceFunction]
luminosityDistanceFunction[cosmology_,zmax_,options:OptionsPattern[comovingDistanceFunction]]:=
buildDistanceFunction[cosmology,zmax,"transverse"->True,"zpower"->+1,options]


Clear[ageOfUniverse]
ageOfUniverse[cosmology_]:=ageOfUniverse[cosmology]^=
Module[{scale},
    scale=hubbleScale[1,OptionValue[cosmology,"h"],Units`Giga Units`Year];
	scale NIntegrate[1/Hratio[cosmology][Exp[s]-1],{s,0,Infinity}]
]


Clear[lookbackTimeFunction]
lookbackTimeFunction[cosmology_,zmax_,options:OptionsPattern[{lookbackTimeFunction,buildFunction}]]:=
With[{physical=OptionValue["physical"]},
Module[{h,scale},
    h=If[physical===True,OptionValue[cosmology,"h"],1];
    scale=hubbleScale[1,h,Units`Giga Units`Year];
	buildFunction[1/(1+#1)/Hratio[cosmology][#1]&,zmax,"scale"->scale,FilterRules[{options},Options[buildFunction]]]
]]
Options[lookbackTimeFunction]={"physical"->True};


Clear[conformalTimeFunction]
conformalTimeFunction[cosmology_,zmax_,options:OptionsPattern[{conformalTimeFunction,buildFunction}]]:=
With[{physical=OptionValue["physical"]},
Module[{h,scale,eta0},
    h=If[physical===True,OptionValue[cosmology,"h"],1];
    scale=hubbleScale[1,h,Units`Giga Units`Year];
    eta0=NIntegrate[1/Hratio[cosmology][Exp[s]-1]Exp[s],{s,0,Infinity}];
    buildFunction[1/Hratio[cosmology][#1]&,zmax,"scale"->scale,"transform"->((eta0-#2)&),FilterRules[{options},Options[buildFunction]]]
]]
Options[conformalTimeFunction]={"physical"->True};


Clear[soundHorizonFunction]
soundHorizonFunction[cosmology_,zmax_,options:OptionsPattern[{soundHorizonFunction,buildFunction}]]:=
With[{physical=OptionValue["physical"]},
Module[{h,scale,r0},
    h=If[physical===True,OptionValue[cosmology,"h"],1];
    scale=hubbleScale[PhysicalConstants`SpeedOfLight,h,Units`Mega Units`Parsec];
    r0=NIntegrate[betas[cosmology][Exp[s]-1]/Hratio[cosmology][Exp[s]-1]Exp[s],{s,0,Infinity}];
    buildFunction[betas[cosmology][#1]/Hratio[cosmology][#1]&,zmax,"scale"->scale,"transform"->((r0-#2)&),FilterRules[{options},Options[buildFunction]]]
]]
Options[soundHorizonFunction]={"physical"->False};


Clear[rsdrag]
rsdrag[cosmology_]:=rsdrag[cosmology]^=
Module[{scale,sdrag},
    scale=hubbleScale[PhysicalConstants`SpeedOfLight,OptionValue[cosmology,"h"],Units`Mega Units`Parsec];
    sdrag=Log[1+zdrag[cosmology]];
    scale NIntegrate[betas[cosmology][Exp[s]-1]/Hratio[cosmology][Exp[s]-1]Exp[s],{s,sdrag,Infinity}]
]


Clear[recombinationXe]
(* NDSolve doesn't like to go all the way down below ~100 or past ~1800 *)
recombinationXe[cosmology_,zmin_:100,zmax_:1800]:=
With[{
(* Case B recombination parameters *)
a=4.309,b=-0.6166,c=0.6703,d=0.5300,F=1.14,
T0=OptionValue[cosmology,"Tcmb"]Units`Kelvin (* CMB Temperature Today *),
Arad=4 PhysicalConstants`StefanConstant/PhysicalConstants`SpeedOfLight (* Radiation Constant *),
\[Sigma]T=PhysicalConstants`ThomsonCrossSection,
kB=PhysicalConstants`BoltzmannConstant,
hP=PhysicalConstants`PlanckConstant,
me=PhysicalConstants`ElectronMass,
mp=PhysicalConstants`ProtonMass,
EionH2s=5.446605 10^-19 Units`Joule (* H 2s ionization energy *),
E2s1sH=1.63403067 10^-18 Units`Joule (* H 2s energy from the ground state *),
\[Lambda]\[Alpha]=1215.668 10^-10 Units`Meter (* Lyman Alpha wavelength *),
\[CapitalLambda]2\[Gamma]=8.22458/Units`Second (* 2 photon decay rate *),
YP=OptionValue[cosmology,"YP"] (* Helium fraction *),
\[CapitalOmega]b=OptionValue[cosmology,"\[CapitalOmega]bh2"]/OptionValue[cosmology,"h"]^2 (* Baryon Fraction Today *),
\[Rho]crit=criticalDensityToday[OptionValue[cosmology,"h"]] Units`Joule/Units`Meter^3 (* Critical Density Today *)},
Module[{z,H,Trad,Tmat,t,\[Rho]b,nb,ne,nH,nHe,xe,\[Alpha]B,\[Beta]B,K,C,TmatRHS},
	(* Hubble Rate *)
	H=H0[cosmology]Hratio[cosmology][z]Convert[(Units`Kilo Units`Meter/Units`Second/(Units`Mega Units`Parsec)),1/Units`Second];
	(* Radiation Temperature *)
	Trad=T0(1+z);
	(* t parameter for Case B recombination *)
	t=Tmat[z]Kelvin/(10^4 Kelvin);
	(* Case B recombination coefficient *)
	\[Alpha]B=F 10^-19 (a t^b)/(1+c t^d) Units`Meter^3 /Units`Second;
	(* Total Photoionization Rate *)
	\[Beta]B=Units`Convert[\[Alpha]B*( (2\[Pi] me Tmat[z]Units`Kelvin kB)/hP^2)^(3/2)Exp[-EionH2s/(Tmat[z]Units`Kelvin kB)],1/Units`Second];
	(* Baryon Density *)
	\[Rho]b=\[Rho]crit (1+z)^3 \[CapitalOmega]b;
	(* Number Density of Hydrogen Nuclei *)
	nH=Units`Convert[(1-YP)\[Rho]b/(mp PhysicalConstants`SpeedOfLight^2),1/Units`Meter^3];
	(* Number Density of Electrons *)
	ne=Units`Convert[xe[z]*nH,1/Units`Meter^3];
	(* Number Density of Helium Nuclei *)
	nHe=Units`Convert[YP*\[Rho]b/(4*mp PhysicalConstants`SpeedOfLight^2),1/Units`Meter^3];
	(* Cosmological Redshifting Rate *)
	K=\[Lambda]\[Alpha]^3/(8 \[Pi] H);
	(* Effect of 2 Photon Decay and Redshifting *)
	C=Simplify[(1+K \[CapitalLambda]2\[Gamma] nH (1-xe[z]))/(1+K (\[CapitalLambda]2\[Gamma] +\[Beta]B )nH(1-xe[z]))];
	{xe,Tmat}/.Flatten[NDSolve[{
		(* Free electron equation *)
		D[xe[z],z]==Units`Convert[C (xe[z]^2nH \[Alpha]B-\[Beta]B(1-xe[z])Exp[-E2s1sH/(kB Tmat[z] Units`Kelvin)])/((1+z)H),1],
		(* Matter/Radiation Temperature Relation Eq 5 *)
		D[Tmat[z],z]==Units`Convert[(8\[Sigma]T Arad Trad^4)/(3(1+z)H  me PhysicalConstants`SpeedOfLight),1]Simplify[ne/(ne+nH+nHe)]*(Tmat[z]-Trad/Units`Kelvin)+2Tmat[z]/(1+z),
		(*Initial conditions *)
		xe[zmax]==1,Tmat[zmax]==T0*(1+zmax)/Units`Kelvin
	},{xe,Tmat},{z,zmin,zmax}]]
]]


Clear[\[Tau]b];
\[Tau]b[cosmology_,xe_,zd_?NumericQ,zmin_:100]:=
With[{
\[Sigma]T=PhysicalConstants`ThomsonCrossSection,
mp=PhysicalConstants`ProtonMass,
c=PhysicalConstants`SpeedOfLight,
\[CapitalOmega]\[Gamma]=\[CapitalOmega]photons[cosmology][0],
\[Rho]crit=criticalDensityToday[OptionValue[cosmology,"h"]]Units`Joule/Units`Meter^3,
YP=OptionValue[cosmology,"YP"],
h0=H0[cosmology] Convert[(Units`Kilo Units`Meter/Units`Second/(Units`Mega Units`Parsec)),1/Units`Second]
},
Convert[(4\[CapitalOmega]\[Gamma])/3(\[Sigma]T(1-YP)\[Rho]crit)/(mp h0 c),1]NIntegrate[(xe[zp](1+zp)^3)/Hratio[cosmology][zp],{zp,zmin,zd}]
]


End[]


EndPackage[]
