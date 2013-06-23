(* ::Package:: *)

(* Created 16-May-2013 by David Kirkby (University of California, Irvine) <dkirkby@uci.edu> *)

BeginPackage["DeepZot`BaoFitTools`",{"DeepZot`PlotTools`"}]


BaoFitTools::usage=
"A collection of utilities for analyzing and displaying baofit outputs."


loadFitMatrix::usage=
"loadFitMatrix[filename] constructs a symmetric matrix from a sequence of lines read
from the specified file of the form 'i j matrix(i,j)' where i,j are indices starting
from zero. Because of the assumed symmetry, only one of (i,j) and (j,i) are needed in
the file, but redundant entries are harmless. Missing diagonal elements are assumed to
be one and missing off-diagonal elements are assumed to be zero. The following options
are supported:
    - path : directory to prepend to filename (default is None)
    - size : size of the matrix to return (Automatic or integer value)
      (default is Automatic, which uses the largest index found)
    - invert : return the inverse of the loaded matrix (default is False)
    - sparse : should result be returned as a SparseArray? (Automatic,True,False)
      (default is Automatic, which decides based on the space saving)
    - sparseThreshold : prefers sparse matrix if sparseSize < threshold * denseSize
      (default is 1)";


saveFitMatrix::usage=
"saveFitMatrix[matrix,filename] saves the specified symmetric matrix in the format
expected by baofit (and read by loadFitMatrix). The following options are supported:
    - path : directory to prepend to filename (default is None)
    - indices : a vector of indices to use, of the same dimension as matrix
      (default is Automatic, which corresponds to 0,1,...,dim-1)";


saveFitData::usage=
"saveFitData{vector,filename] saves the specified data vector in the format expected
by baofit. The following options are supported:
    - path : directory to prepend to filename (default is None)
    - indices : a vector of indices to use, of the same dimension as matrix
      (default is Automatic, which corresponds to 0,1,...,dim-1)";


loadFitDump::usage=
"loadFitDump[filename] loads the best-fit multipoles from the specified filename.";


loadFitResiduals::usage=
"loadFitResiduals[tag,prefix] loads the residuals output file for the specified
output prefix and associates the results with the specified tag. The following
options are supported:
    - verbose: be verbose about what we are doing (default is True)
    - path: directory containing the residuals file (default is None)
    - cov: load fit input covariance matrix from this file under path (default is None)
    - icov: load fit input inverse covariance matrix from this file under path (default is None)
    - nlargest: if cov or icov is specified and verbose is True, prints this number of modes
      with largest contribution to chisq (default 10)
Use the following keys to access the loaded residuals:
  tag[\"INDEX\"] = global bin index
  tag[\"USER\"] = bin center in the user-defined binning variables
  tag[\"RMUZ\"] = bin center in (r,mu,z)
  tag[\"PRED\"] = model prediction for this bin
  tag[\"DATA\"] = data for this bin
  tag[\"ERROR\"] = diagonal error for this bin
  tag[\"GRADS\"] = gradients of the model prediction in this bin
  tag[\"ZVEC\"] = sorted list of redshifts with data
If the cov or icov options are provided, the following extra keys are available:
  tag[\"ICOV\"] = inverse covariance pruned to the bins used in the fit.
  tag[\"EVAL\"] = eigenvalues of the pruned inverse covariance in descending order.
  tag[\"EVEC\"] = corresponding matrix of eigenvectors, with vectors stored in successive rows.
  tag[\"CHIJK\"] = matrix of chisq contributions by mode and bin.
  tag[\"CHIJ\"] = vector of chisq contributions by mode.";


loadFitAnalysis::usage=
"loadFitAnalysis[tag,name] loads the analysis output file for the specified analysis
name and associates the results with the specified tag:
  tag[\"NPAR\"] = number of fixed+floating parameters
  tag[\"NDUMP\"] = number of r values dumped for each multipole and fit
  tag[\"NFIT\"] = number of fits for each sample
  tag[\"FITERR\"] = diagonal errors from baseline fits (zero for fixed parameters)
  tag[\"NFLOAT\"] = number of floating parameters in each fit config
  tag[\"BASELINE\"] = baseline fit
  tag[\"NSAMPLE\"] = number of samples
  tag[\"SAMPLE\"] = table of fits to each sample
Fit results in s = tag[\"BASELINE\"] and s = tag[\"SAMPLE\"][[k]] with 1 <= k <= nsample
have the same format:
  s[[fit,1]] = chisq of 1 <= fit <= nfit
  s[[fit,2,p]] = fitted or fixed value of param[p] with 1 <= p <= npar
  s[[fit,3,ell,ir]] = multipole ell=1,2,3 calculated at the i-th r value (i >= 1)";


fitAnalysisSamples::usage=
"fitAnalysisSamples[tag] returns a list of {p1,p2,p3,...,chisq-chisq(min)} tuples for the
fit analysis associated with the specified tag. The following options are supported:
    - parameters: Indices of parameters to include in the tuple. Default is {7,8}.
    - appendChiSq: Should the value of chisq-chisq(min) be append to each tuple?
      Default is True.
    - fitIndex: index of analysis fit to use, must be >= 1 and <= tag[\"NFIT\"].
      Default is 1.";


fitDensityPlot::usage=
"fitDensityPlot[tag] uses ListDensityPlot to plot the best-fit prediction for the first
redshift bin stored in the fit residuals previously loaded and associated with the specified tag.
The following options are supported:
    - key: name of vector associated with tag to plot (default is \"PRED\").
    - zindex: which redshift bin to plot (default is 1).
    - rpow: power of the radius to use for weighting each plot point (default is 0).
    - vector: list of values to plot instead of tag[key], must have correct size (default is None).
    - grid: type of grid to display (choices are None,Automatic,\"cartesian\",\"polar\" and default is Automatic).
    - rmin: plot range will be clipped at r > rmin (default is None).
    - rmax: plot range will be clipped at r < rmax (default is None).";


fitModePlot::usage=
"fitModePlot[tag,mode] plots the per-bin weights (left) and per-bin chisq contributions
(right) of the specified eigenmode.";


fitProjectedData::usage=
"fitProjectedData[tag,modeIndices] returns tag[\"DATA\"] with the covariance eigenmodes for the specified indices projected out.";


fitProjectedCovariance::usage=
"fitProjectedCovariance[tag,modeIndices] returns Inverse[tag[\"ICOV\"] with the errors associated with specified covariance
eigenmodes zeroed out.";


fitResidualsMultipole::usage=
"fitResidualsMultipole[tag] returns a multipole...";


fitMultipolePlot::usage=
"fitMultipolePlot[tag] plots a multipole...";


fitResidualsInterpolatedMultipoles::usage=
"fitResidualsInterpolatedMultipoles[tag] calculates the multipoles of the 3D binned
data associated with the specified tag...";


Begin["Private`"]


makePath::nosuchpath="No such path \"`1`\".";
makePath::filenotfound="File not found \"`1`\".";
makePath[filename_,pathOption_,exists_:True]:=
Module[{path},
    path=If[!(pathOption===None)&&StringLength[ToString[pathOption]]>0,
        If[!DirectoryQ[ToString[pathOption]],
            Message[makePath::nosuchpath,pathOption];
            Return[$Failed]
        ];
        FileNameJoin[{pathOption,filename}],
        filename
    ];
    If[exists && !FileExistsQ[path],
        Message[makePath::filenotfound,path];
        Return[$Failed]
    ];
    path
]


makeSample[line_,npar_,ndump_,nfit_]:=
With[{size=npar+1},
Table[{
  (* fit chisq *)
  line[[size(fit-1)+npar+1]],
  (* fit parameter values *)
  Table[line[[size(fit-1)+par]],{par,1,npar}],
  (* multipole dumps *)
  Table[line[[nfit size+3ndump(fit-1)+ndump(ell-1)+dump]],{ell,1,3},{dump,1,ndump}]
},{fit,1,nfit}
]]


Clear[loadFitDump]
loadFitDump::badell="Invalid value for ell: `1` (valid choices are 0,2,4).";
loadFitDump[filename_,OptionsPattern[loadFitDump]]:=
With[{
  pathOption=OptionValue["path"],
  ellOption=OptionValue["ell"]
},
Module[{path,raw},
  path=makePath[filename,pathOption];
  raw=ReadList[path,Real,RecordLists->True];
  Which[
    ellOption===0,raw[[;;,{1,2}]],
    ellOption===2,raw[[;;,{1,3}]],
    ellOption===4,raw[[;;,{1,4}]],
    ellOption===All,raw,
    True,
      Message[loadFitDump::badell,ellOption];
      $Failed
  ]
]]
Options[loadFitDump]={"path"->None,"ell"->All};


Clear[loadFitAnalysis]
loadFitAnalysis::badheader1="Analysis output file has badly formatted header line 1.";
loadFitAnalysis::badheader2="Analysis output file has badly formatted header line 2.";
loadFitAnalysis::badshape="Analysis output file has badly shaped samples.";
loadFitAnalysis::badncol="Analysis output file has wrong number of sample columns.";
loadFitAnalysis[tag_,name_,OptionsPattern[loadFitAnalysis]]:=
With[{
    verboseOption=OptionValue["verbose"],
    pathOption=OptionValue["path"]
},
Module[{path,raw,npar,ndump,nfit,nrow,ncol},
  Clear[tag];
  (* load the analysis file into memory *)
  path=makePath[name<>".dat",pathOption];
  raw=ReadList[path,Number,RecordLists->True];
  (* parse the first header line *)
  If[Length[raw[[1]]]!=3,
    Message[loadFitAnalysis::badheader1];
    Return[$Failed]
  ];
  {npar,ndump,nfit}=raw[[1]];
  tag["NPAR"]=npar;
  tag["NDUMP"]=ndump;
  tag["NFIT"]=nfit;
  (* parse the second header line *)
  If[Length[raw[[2]]]!=nfit npar,
    Message[loadFitAnalysis::badheader2];
    Return[$Failed]
  ];
  tag["FITERR"]=Table[raw[[2,(fit-1)npar+par]],{fit,1,nfit},{par,1,npar}];
  tag["NFLOAT"]=Map[Count[##,err_/;err>0]&,tag["FITERR"]];
  (* parse the sample data *)
  If[Length[Dimensions[raw[[3;;]]]]!=2,
    Message[loadFitAnalysis::badshape];
    Return[$Failed]
  ];
  {nrow,ncol}=Dimensions[raw[[3;;]]];
  If[ncol!=nfit(1+npar+3ndump),
    Message[loadFitAnalysis::badncol];
    Return[$Failed]
  ];
  tag["NSAMPLE"]=nrow-1;
  tag["BASELINE"]=makeSample[raw[[3]],npar,ndump,nfit];
  tag["SAMPLE"]=Map[makeSample[##,npar,ndump,nfit]&,raw[[4;;]]];
  (* all done *)
  If[verboseOption===True,
    Print["Loaded ",nrow-1," samples with npar = ",npar,", ndump = ",ndump,", nfit = ",
      nfit,", nfloating = ",tag["NFLOAT"],"."]
  ];
]]
SetAttributes[loadFitAnalysis,HoldFirst]
Options[loadFitAnalysis]={
    "verbose"->True,"path"->None
};


Clear[fitAnalysisSamples]
fitAnalysisSamples[tag_,OptionsPattern[fitAnalysisSamples]]:=
With[{
  parametersOption=OptionValue["parameters"],
  appendChiSqOption=OptionValue["appendChiSq"],
  fitIndexOption=OptionValue["fitIndex"]
},
Module[{chisq,pvec,chisq0,getter},
  chisq=Function[sfit,sfit[[1]]];
  chisq0=chisq[tag["BASELINE"][[fitIndexOption]]];
  pvec=Function[sfit,sfit[[2,parametersOption]]];
  getter=If[appendChiSqOption===True,
    Function[sfit,Append[pvec[sfit],chisq[sfit]-chisq0]],
    Function[sfit,pvec[sfit]]
  ];
  Developer`ToPackedArray[Map[getter,tag["SAMPLE"][[;;,fitIndexOption]]]]
]]
Options[fitAnalysisSamples]={ "parameters"->{7,8},"appendChiSq"->True,"fitIndex"->1 };


Clear[loadFitResiduals]
loadFitResiduals[tag_,prefix_,OptionsPattern[loadFitResiduals]]:=
With[{
    verboseOption=OptionValue["verbose"],
    pathOption=OptionValue["path"],
    covOption=OptionValue["cov"],
    icovOption=OptionValue["icov"],
    nlargestOption=OptionValue["nlargest"]
},
Module[{path,raw,ncols,nbins,ngrads,cov,keep,chij,nlargest,largest},
    Clear[tag];
    (* load the residuals file into memory *)
    path=makePath[prefix<>"residuals.dat",pathOption];
    raw=Transpose[Developer`ToPackedArray[ReadList[path,Real,RecordLists->True]]];
    {ncols,nbins}=Dimensions[raw];
    ngrads=ncols-11;
    If[verboseOption===True,
        Print["Read residuals for ",nbins," bins."];
        If[ngrads>0,
            Print["Found gradients for ",ngrads," parameters."],
            Print["No gradients available."]
        ]
    ];
    (* associate each of the filled arrays with the tag using a string key *)
    tag["INDEX"]=IntegerPart[raw[[1]]];
    tag["USER"]=Transpose[raw[[2;;4]]];
    tag["RMUZ"]=Transpose[raw[[5;;7]]];
    tag["PRED"]=raw[[8]];
    tag["DATA"]=raw[[9]];
    tag["ERROR"]=raw[[10]];
    tag["GRADS"]=If[ngrads>0,Transpose[raw[[11;;]]],None];
    tag["ZVEC"]=Union[raw[[7]]];
    (* Read cov or icov if available. If both are provided, cov takes precedence. *)
    cov=None;
    If[!(covOption===None),
        cov=loadFitMatrix[covOption,"path"->pathOption,"verbose"->verboseOption];
    ];
    If[cov===None&&!(icovOption===None),
        cov=loadFitMatrix[icovOption,"invert"->True,"path"->pathOption,"verbose"->verboseOption];
    ];
    If[!(cov===None),
        (* Prune the covariance to the bins used in the fit *)
        keep=1+tag["INDEX"];
        (* Save the corresponding inverse covariance *)
        tag["ICOV"]=Inverse[cov[[keep,keep]]];
        (* Calculate and save the eigenvalues and eigenvectors *)
        {tag["EVAL"],tag["EVEC"]}=Eigensystem[tag["ICOV"]];
        (* Calculate and save the matrix of chisq contributions to this fit *)
        tag["CHIJK"]=tag["EVEC"]Outer[Times,Sqrt[tag["EVAL"]],tag["DATA"]-tag["PRED"]];
        tag["CHIJ"]=Total/@tag["CHIJK"];
        If[verboseOption===True,
            Print["chi^2/dof = ",Total[tag["CHIJ"]^2]," / (",nbins," - ",ngrads,")"];
            nlargest=Min[nbins,nlargestOption];
            largest=Ordering[tag["CHIJ"]^2,nlargest,Greater];
            Print[nlargest," modes with largest chi^2 contributions:"];
            Print[TableForm[{largest,(tag["CHIJ"]^2)[[largest]]}]];
        ];
    ];
]]
SetAttributes[loadFitResiduals,HoldFirst]
Options[loadFitResiduals]={
    "verbose"->True,"path"->None,"cov"->None,"icov"->None,"nlargest"->10
};


(* See http://mathematica.stackexchange.com/questions/7887/best-way-to-create-symmetric-matrices *)
Clear[loadFitMatrix]
loadFitMatrix[filename_,OptionsPattern[loadFitMatrix]]:=
With[{
    verboseOption=OptionValue["verbose"],
    pathOption=OptionValue["path"],
    sizeOption=OptionValue["size"],
    invertOption=OptionValue["invert"],
    sparseOption=OptionValue["sparse"],
    sparseThresholdOption=OptionValue["sparseThreshold"]
},
Module[{path,raw,size,sparse,packed},
    path=makePath[filename,pathOption];
    raw=ReadList[path,{Number,Number,Number}];
    size=If[sizeOption===Automatic,Max[raw[[;;,1]]]+1,sizeOption];
    If[verboseOption===True,Print["Read matrix with size = ",size,"."]];
    With[{values=N[raw[[;;,3]]]},
        sparse=N[SparseArray[{
            1+raw[[;;,{1,2}]]->values,
            1+raw[[;;,{2,1}]]->values,
            {i_,i_}->1
        },{size,size}]];
    ];
    If[invertOption===True,
        sparse=Inverse[sparse];
        (* Force the inverse to be symmetric, to eliminate any rounding errors *)
        sparse=(sparse+Transpose[sparse])/2;
    ];
    If[sparseOption===True,Return[sparse]];
    (* Convert the matrix to a dense packed array *)
    packed=Developer`ToPackedArray[Normal[sparse]];
    If[sparseOption===Automatic&&ByteCount[sparse]<sparseThresholdOption ByteCount[packed],
        If[verboseOption===True,Print["Automatically selected sparse matrix format."]]; Return[sparse],
        If[verboseOption===True,Print["Automatically selected packed matrix format."]]; Return[packed]
    ];
]]
Options[loadFitMatrix]={ "verbose"->False,"path"->None, "size"->Automatic, "invert"->False, "sparse"->Automatic, "sparseThreshold"->1 };


Clear[saveFitMatrix]
saveFitMatrix::notsymm="Cannot save non-symmetric matrix.";
saveFitMatrix::badsize="Indices and matrix have different sizes.";
saveFitMatrix[matrix_,filename_,OptionsPattern[saveFitMatrix]]:=
With[{
  n=Length[matrix],
  pathOption=OptionValue["path"],
  indicesOption=OptionValue["indices"]
},
Module[{path,indices,save},
  If[!(SymmetricMatrixQ[matrix]===True),
    Message[saveFitMatrix::notsymm];
    Return[$Failed]
  ];
  path=makePath[filename,pathOption,False];
  indices=If[indicesOption===Automatic,Range[0,n-1],indicesOption];
  If[Length[indices]!=n,
    Message[saveFitMatrix::badsize];
    Return[$Failed]
  ];
  save=Flatten[
    Table[
      {indices[[row]],indices[[col]],matrix[[row,col]]},
      {row,1,n},{col,1,row}
    ],1];
  (* Do not write zero elements *)
  save=Select[save,Last[##]!=0&];
  Export[path,AppendTo[save,{}],"Table"]
]]
Options[saveFitMatrix]={"path"->None,"indices"->Automatic};


Clear[saveFitData]
saveFitData::badsize="Indices and data vector have different sizes.";
saveFitData[vector_,filename_,OptionsPattern[saveFitData]]:=
With[{
  n=Length[vector],
  pathOption=OptionValue["path"],
  indicesOption=OptionValue["indices"]
},
Module[{path,indices,save},
  path=makePath[filename,pathOption,False];
  indices=If[indicesOption===Automatic,Range[0,n-1],indicesOption];
  If[Length[indices]!=n,
    Message[saveFitData::badsize];
    Return[$Failed]
  ];
  save=Transpose[{indices,vector}];
  Export[path,AppendTo[save,{}],"Table"]
]]
Options[saveFitData]={"path"->None,"indices"->Automatic};


(* Returns a tuple { rT, rP, r^rpow value} given a value and an offset to use into tag[COORDS] *)
Clear[rxyTuple]
rxyTuple[offset_,value_,tag_,rpow_:0]:=
With[{r=tag["RMUZ"][[offset,1]],mu=tag["RMUZ"][[offset,2]]},
    {r Sqrt[1-mu^2],r mu,r^rpow value}
]


(* Returns a list of offsets corresponding to the specified values of the specified bin
coordinates, with _ representing a wildcard in the pattern *)
Clear[binSlice]
binSlice[tag_,pattern_,key_:"RMUZ"]:=Flatten[Position[tag[key],pattern]]


(* Returns sorted lists of the user coordinate values used for the first two axes at the specified
value of the third redshift axis, suitable for use with the Mesh plotting option *)
userGrid[tag_,zval_]:=With[{bins=tag["USER"][[binSlice[tag,{_,_,zval},"USER"]]]},
{Union[bins[[;;,1]]],Union[bins[[;;,2]]]}
]


Clear[fitDensityPlot]
fitDensityPlot::badtag="Invalid tag `1`.";
fitDensityPlot::badkey="Invalid key `1`.";
fitDensityPlot::badvec="Invalid vector for plotting.";
fitDensityPlot::badgrid="Invalid grid option, should be None, Automatic, \"cartesian\" or \"polar\".";
fitDensityPlot[tag_,options:OptionsPattern[{fitDensityPlot,dataRange,ListDensityPlot}]]:=
With[{
    rpow=OptionValue["rpow"],
    zindex=OptionValue["zindex"],
    key=OptionValue["key"],
    vector=OptionValue["vector"],
    grid=OptionValue["grid"],
    rmin=OptionValue["rmin"],
    rmax=OptionValue["rmax"]
},
Module[{vec,zval,points,rTmax,rPmax,rPmin,range,zmin,zmax,gridOptions,regionFunction},
    If[!ValueQ[tag["ZVEC"]],
        Message[fitDensityPlot::badtag,ToString[tag]];
        Return[$Failed]
    ];
    vec=If[vector===None,tag[key],vector];
    If[vector===None&&!ValueQ[tag[key]],
        Message[fitDensityPlot::badkey,key];
        Return[$Failed]
    ];
    If[Length[vec]<Length[tag["INDEX"]],
        Message[fitDensityPlot::badvec];
        Return[$Failed]
    ];
    zval=tag["ZVEC"][[zindex]];
    points=Table[rxyTuple[k,vec[[k]],tag,rpow],{k,binSlice[tag,{_,_,zval},"RMUZ"]}];
    rTmax=Max[points[[;;,1]]];
    rPmax=Max[points[[;;,2]]];
    rPmin=Min[points[[;;,2]]];
    range=dataRange[points[[;;,3]],FilterRules[{options},Options[dataRange]]];
    {zmin,zmax}=range;
    gridOptions=Which[
        grid===None,{},
        grid===Automatic,{MeshStyle->Opacity[0.25],Mesh->All},
        grid==="cartesian",{
            MeshStyle->Opacity[0.25],Mesh->userGrid[tag,zval],MeshFunctions->{#1&,#2&}
        },
        grid==="polar",{
            MeshStyle->Opacity[0.25],Mesh->userGrid[tag,zval],MeshFunctions->{Sqrt[#1^2+#2^2]&,#2/Sqrt[#1^2+#2^2]&}
        },
        True,Message[fitDensityPlot::badgrid];Return[$Failed]
    ];
    regionFunction=Which[
        NumberQ[rmin]&&NumberQ[rmax]&&rmin>0&&rmax>rmin,{RegionFunction->(rmin^2<=#1^2+#2^2<=rmax^2&)},
        NumberQ[rmax]&&rmax>0,{RegionFunction->(#1^2+#2^2<=rmax^2&)},
        NumberQ[rmin]&&rmin>0,{RegionFunction->(#1^2+#2^2>=rmin^2&)},
        True,{}
    ];
    ListDensityPlot[points,FilterRules[{options},Options[ListDensityPlot]],
        gridOptions,regionFunction,
        InterpolationOrder->0,PlotRange->{{0,rTmax},{Min[0,rPmin],rPmax},range},
        LabelStyle->Medium,ColorFunctionScaling->False,
        ColorFunction->(temperatureMap[(##-zmin)/(zmax-zmin)]&),
        FrameLabel->{"\!\(\*SubscriptBox[\(r\), \(\[Perpendicular]\)]\)(Mpc/h)","\!\(\*SubscriptBox[\(r\), \(||\)]\)(Mpc/h)"}
    ]
]]
Options[fitDensityPlot]={"rpow"->0,"zindex"->1,"key"->"PRED","vector"->None,"grid"->Automatic,"rmin"->None,"rmax"->None};


Clear[fitModePlot]
fitModePlot[tag_,mode_,options:OptionsPattern[{fitModePlot,fitDensityPlot,dataRange,ListDensityPlot}]]:=
With[{
  densityPlotOptions=FilterRules[{options},{Options[fitDensityPlot],Options[dataRange],Options[ListDensityPlot]}]
},
Print["Mode ",mode," of ",Length[tag["EVAL"]]," contributes ",tag["CHIJ"][[mode]]^2," to total chisq = ",Total[tag["CHIJ"]^2]];
GraphicsRow[{
    fitDensityPlot[tag,"vector"->tag["EVEC"][[mode]],densityPlotOptions,"centerValue"->0],
    fitDensityPlot[tag,"vector"->tag["CHIJK"][[mode]],densityPlotOptions,"centerValue"->0]
},Spacings->4]
]
Options[fitModePlot]={};


fitProjectedData[tag_,modeIndices_]:=
With[{data=tag["DATA"]},
  data - Sum[
    With[{mode=tag["EVEC"][[index]]},
      (data.mode)mode
    ],
    {index,modeIndices}
  ]
]


fitProjectedCovariance[tag_,modeIndices_]:=
Module[{cov},
  cov=Transpose[tag["EVEC"]].DiagonalMatrix[1/tag["EVAL"]].tag["EVEC"];
  cov -= Sum[
    With[{mode=tag["EVEC"][[index]],\[Lambda]=1/tag["EVAL"][[index]]},
      \[Lambda] Outer[Times,mode,mode]
    ],
    {index,modeIndices}
  ];
  (* Symmetrize the result to eliminate rounding errors *)
  (cov+Transpose[cov])/2
]


Clear[fitResidualsMultipole]
fitResidualsMultipole::badtag="Invalid tag `1`.";
fitResidualsMultipole::noeigen="Cannot project modes without eigendecomposition.";
fitResidualsMultipole::notdata="Can only project modes for key -> \"DATA\".";
fitResidualsMultipole[tag_,OptionsPattern[fitResidualsMultipole]]:=
With[{
  ell=OptionValue["ell"],
  zindex=OptionValue["zindex"],
  keyOption=OptionValue["key"],
  projectOutModesOption=OptionValue["projectOutModes"]
},
Module[{zval,indices,rvec,xivec,cov,sigvec},
  (* Check for a valid residuals tag *)
  If[!ValueQ[tag["ZVEC"]||!ValueQ[tag["USER"]]||!ValueQ[tag[keyOption]]],
    Message[fitResidualsMultipole::badtag,ToString[tag]];
    Return[$Failed]
  ];
  (* Check that we can project *)
  If[!(projectOutModesOption===None),
    If[!ValueQ[tag["EVEC"]],
      Message[fitResidualsMultipole::noeigen];
      Return[$Failed]
    ];
    If[!(keyOption==="DATA"),
      Message[fitResidualsMultipole::notdata];
      Return[$Failed]
    ];
  ];
  (* Lookup the dataset indices for the specified ell,z *)
  zval=tag["ZVEC"][[zindex]];
  indices=binSlice[tag,{_,N[ell],zval},"USER"];
  rvec=tag["USER"][[;;,1]][[indices]];
  If[projectOutModesOption===None,
    (* Get the data vector for this slice *)
    xivec=tag[keyOption][[indices]];
    (* Assign the errors for this slice *)
    sigvec=If[keyOption==="DATA",tag["ERROR"][[indices]],ConstantArray[0.,Length[rvec]]],
    (* Project out the data for this slice *)
    xivec=fitProjectedData[tag,projectOutModesOption][[indices]];
    (* Project out the covariance for this slice *)
    cov=fitProjectedCovariance[tag,projectOutModesOption][[indices,indices]];
    (* Calculate the projected diagonal errors *)
    sigvec=Sqrt[Diagonal[cov]];
  ];
  (* Return the corresponding vector of (r,xi,sigma) tuples *)
  Transpose[{rvec,xivec,sigvec}]
]]
Options[fitResidualsMultipole]={"ell"->0,"zindex"->1,"key"->"DATA","projectOutModes"->None};


Clear[fitMultipolePlot]
fitMultipolePlot::badcurves="curves has invalid dimensions `1`.";
fitMultipolePlot::badpoints="pointsWithErrors has invalid dimensions `1`.";
fitMultipolePlot::badpointstyles="pointStyles has wrong length (expected `1`).";
fitMultipolePlot[options:OptionsPattern[{fitMultipolePlot,dataRange,ListPlot}]]:=
With[{
  ellOption=OptionValue["ell"],
  rminOption=OptionValue["rmin"],
  rmaxOption=OptionValue["rmax"],
  rpowOption=OptionValue["rpow"],
  curvesOption=OptionValue["curves"],
  curvesStyleOption=OptionValue["curvesStyle"],
  fitCurvesOption=OptionValue["fitCurves"],
  pointsWithErrorsOption=OptionValue["pointsWithErrors"],
  pointStylesOption=OptionValue["pointStyles"],
  pointSizeOption=OptionValue["pointSize"],
  pointTicksOption=OptionValue["pointTicks"],
  pointSpreadOption=OptionValue["pointSpread"]
},
Module[{curves,points,pstyles,rvec,rpad,rmin,rmax,wgt,yvec,usepos,range,spread,labels},
  (* Wrap curves and pointsWithErrors in a List if there is only one dataset *)
  curves=If[Depth[curvesOption]==3,{curvesOption},curvesOption];
  points=If[Depth[pointsWithErrorsOption]==3,{pointsWithErrorsOption},pointsWithErrorsOption];
  (* Check that curves has the expected shape *)
  If[Cases[Map[Dimensions,curves],Except[{_,2}]]!={},
    Message[fitMultipolePlot::badcurves,Map[Dimensions,curves]];
    Return[$Failed]
  ];
  (* Check that pointsWithErrors has expected shape *)
  If[Cases[Map[Dimensions,points],Except[{_,3}]]!={},
    Message[fitMultipolePlot::badpoints,Map[Dimensions,points]];
    Return[$Failed]
  ];
  (* Check that pointStyles have expected length *)
  pstyles=If[Depth[pointStylesOption]==2,{pointStylesOption},pointStylesOption];
  If[!(pointStylesOption===None||points===None)&&Length[pstyles]!=Length[points],
    Message[fitMultipolePlot::badpointstyles,Length[points]];
    Return[$Failed]
  ];
  (* Use the min,max r values used in points unless rmin,rmax provided as options *)
  If[rminOption===Automatic || rmaxOption===Automatic,
    rvec=Union[Flatten[points[[;;,;;,1]]]];
    rpad=0.02(Max[rvec]-Min[rvec]);
    rmin=If[rminOption===Automatic,Min[rvec]-rpad,rminOption];
    rmax=If[rmaxOption===Automatic,Max[rvec]+rpad,rmaxOption];
  ];
  (* Apply rpow weighting *)
  yvec={};
  If[!(points===None),
    wgt=points[[;;,;;,1]]^rpowOption;
    points[[;;,;;,2]] *=wgt;
    points[[;;,;;,3]] *=wgt;
    AppendTo[yvec,points[[;;,;;,2]]-points[[;;,;;,3]]];
    AppendTo[yvec,points[[;;,;;,2]]+points[[;;,;;,3]]];
  ];
  If[!(curves===None),
    wgt=curves[[;;,;;,1]]^rpowOption;
    curves[[;;,;;,2]] *=wgt;
    If[fitCurvesOption===True,
      (* Only use curve points in [rmin,rmax] to set the range *)
      usepos=Flatten[Position[Flatten[curves[[;;,;;,1]]],r_/;rmin<=r<=rmax]];
      AppendTo[yvec,Flatten[curves[[;;,;;,2]]][[usepos]]];
    ];
  ];
  (* Determine the vertical range to use *)
  range=dataRange[yvec,FilterRules[{options},Options[dataRange]],"padFraction"->0.05];
  (* Apply horizontal point spreading *)
  If[NumericQ[pointSpreadOption],
    rvec=points[[;;,;;,1]];
    spread=Range[-pointSpreadOption/2,+pointSpreadOption/2,
      pointSpreadOption/(Length[points]-1)];
    points[[;;,;;,1]]+=Table[
      ConstantArray[spread[[set]],Length[points[[set]]]],
      {set,1,Length[points]}
    ];
  ];
  (* Create the default frame labels *)
  labels={
    "Comoving separation r (Mpc/h)",
    "Correlation Multipole "<>
      If[rpowOption!=0,"\*SuperscriptBox[r,"<>ToString[rpowOption]<>"]",""]<>
      "\*SubscriptBox[\[Xi],"<>ToString[ellOption]<>"](r)"
  };
  Show[{
    createFrame[Plot,{rmin,rmax},range,
      FrameLabel->labels,Axes->{True,False},AxesOrigin->{0,0},
      FilterRules[{options},Options[ListPlot]]],
    (* plot each curve *)
    If[curves===None,{},ListPlot[curves,Joined->True,PlotStyle->curvesStyleOption]],
    (* plot points for each set of data *)
    Graphics[If[points===None,{},Table[
      pointWithError[
        points[[set,pt,{1,2}]],points[[set,pt,3]],
        size->pointSizeOption,yTicks->pointTicksOption,
        style->If[pstyles===None,{},pstyles[[set]]]
      ],
      {set,1,Length[points]},{pt,1,Length[points[[set]]]}
    ]]]
  }]
]]
Options[fitMultipolePlot]={
  "ell"->0, "rmin"->Automatic, "rmax"->Automatic, "rpow"->2,
  "curves"->None,"curvesStyle"->{}, "fitCurves"->True,
  "pointsWithErrors"->None, "pointStyles"->None, "pointSize"->0.016,
  "pointTicks"->True,"pointSpread"->None
};


fitResidualsInterpolatedMultipoles::badgrid="Grid values are not in increasing order.";
fitResidualsInterpolatedMultipoles::nonneg="Negative grid values are not allowed.";
fitResidualsInterpolatedMultipoles::rcut="`1` of `2` data points fall outside rgrid and will not be use.";
fitResidualsInterpolatedMultipoles::under="Interpolation is underconstrained: npar = `1` > ndata = `2`-`3`.";
fitResidualsInterpolatedMultipoles[tag_,rgrid_,OptionsPattern[fitResidualsInterpolatedMultipoles]]:=
With[{
  lmaxOption=OptionValue["lmax"],
  gammaBiasOption=OptionValue["gammaBias"],
  zrefOption=OptionValue["zref"],
  verboseOption=OptionValue["verbose"]
},
Module[{zref,rmin,rmax,ndata,nrcut,lgrid,npar,lindex,rindex,ell,rk,r,mu,z,t,CM},
  (* Determine the zref value to use *)
  zref=If[zrefOption===Automatic,First[tag["RMUZ"]][[3]],zrefOption];
  If[verboseOption===True,Print["Using zref = ",zref]];
  (* Determine the grid limits *)
  If[rgrid!=Union[rgrid],
    Message[fitResidualsInterpolatedMultipoles::badgrid];
    Return[$Failed]
  ];
  rmin=Min[rgrid];
  rmax=Max[rgrid];
  If[rmin<0,
    Message[fitResidualsInterpolatedMultipoles::nonneg];
    Return[$Failed]
  ];
  ndata=Length[tag["RMUZ"]];
  nrcut=Length[Select[tag["RMUZ"][[;;,1]],!(rmin<=##<=rmax)&]];
  If[nrcut>0,
    Message[fitResidualsInterpolatedMultipoles::rcut,nrcut,ndata];
  ];
  (* Calculate our grid in ell *)
  lgrid=Range[0,lmaxOption,2];
  (* Calculate the size of our data and parameter vectors *)
  npar=Length[rgrid]Length[lgrid];
  If[npar > ndata-nrcut,
    Message[fitResidualsInterpolatedMultipoles::under,npar,ndata,nrcut];
    Return[$Failed]
  ];
  If[verboseOption===True,Print["ndata = ",ndata,", nrcut = ",nrcut,", npar = ",npar]];
  (* Calculate the coefficient matrix CM that transform a vector of xi(ell,r(k)), with ell
  increasing fastest, into a predicted data vector xi(r(i),mu(i),z(i)) *)
  CM = Table[
    (* Lookup the (ell,rk) corresponding to parameter vector element j *)
    {rindex,lindex}=QuotientRemainder[j-1,Length[lgrid]]+{1,1};
    ell=lgrid[[lindex]];
    rk=rgrid[[rindex]];
    (* Lookup the (r,mu,z) corresponding to data vector element i *)
    {r,mu,z}=tag["RMUZ"][[i]];
    (* Calculate the interpolation coefficient t of xi(ell,r(k)) for r on rgrid *)
    t=Which[
      (* bin center is outside interpolation range *)
      r<rmin || r>rmax, 0,
      (* r value falls exactly on r(k) *)
      r==rk, 1,
      (* interpolate linearly in r between r(k-1) and r(k) *)
      rindex>1 && rgrid[[rindex-1]] < r <= rk, (r-rgrid[[rindex-1]])/(rk-rgrid[[rindex-1]]),
      (* interpolate linearly in r between r(k) and r(k+1) *)
      rindex<Length[rgrid] && rk < r <= rgrid[[rindex+1]],(rgrid[[rindex+1]]-r)/(rgrid[[rindex+1]]-rk),
      (* r is within [rmin,rmax] but outside [r(k-1),r(k+1)] *)
      True, 0
    ];
    If[t==0,0,t LegendreP[ell,mu] ((1+z)/(1+zref))^gammaBiasOption],
    {i,ndata},{j,npar}
  ]
]]
Options[fitResidualsInterpolatedMultipoles] = {
  "verbose"->True, "lmax"->4, "gammaBias"->3.8, "zref"->Automatic
};


End[]


EndPackage[]
