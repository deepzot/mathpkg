(* ::Package:: *)

(* Created 26-June-2013 by Daniel Margala (University of California, Irvine) <dmargala@uci.edu> *)

BeginPackage["DeepZot`MachineLearningTools`"]


MachineLearningTools::usage="A collection of machine learning utilities.";


sigmoid::usage=
"sigmoid[z] returns 1/(1+Exp[-z])."


sigmoidGradient::usage=
"sigmoidGradient[z] returns the gradient of the sigmoid function evaluated at z: sigmoid[z]*(1-sigmoid[z])."


randInitializeWeights::usage=
"randInitializeWeights[numIncoming,numOutgoing] returns a set of randomly initialized weights 
connecting two layers. The required input is the number of nodes in each layer (not counting the bias node). 
The range of random numbers determined from the number of nodes using a recommended by (citation ??)."


unrollWeights::usage=
"unrollWeights[nnParams,inputLayerSize,hiddenLayerSize] transforms a flattened list of weights into the theta1 and theta2"


nnCostFunction::usage=
"nnCostFunction[nnParams,inputLayerSize,hiddenLayerSize,numLabels,X,y,lambda] performs forward progation to determine 
cost of the current network and backprogation to compute the gradient w/ respect to the network weights."


nnLearn::usage=
"nnLearn[costFunction,initParams,\[Alpha],maxIter] performs gradient descent learning on the network."


nnPredict::usage=
"nnPredict[Theta1,Theta2,X] makes a set of predictions provided network weights and an input data vector."


Begin["Private`"]


sigmoid[z_]:=1./(1.+Exp[-z])
SetAttributes[sigmoid,Listable]


sigmoidGradient[z_]:=With[{s=sigmoid[z]},s*(1.-s)]
SetAttributes[sigmoidGradient,Listable]


randInitializeWeights[numIncoming_, numOutgoing_] :=
With[{\[Epsilon] = Sqrt[6.]/Sqrt[numIncoming + numOutgoing]},
	RandomReal[{-\[Epsilon], \[Epsilon]}, {numOutgoing, numIncoming + 1}]
]


unrollWeights[nnParams_, inputLayerSize_, hiddenLayerSize_]:=With[{
Theta1 = Partition[nnParams[[1;;(hiddenLayerSize*(inputLayerSize+1))]],(inputLayerSize+1)],
Theta2 = Partition[nnParams[[(1+(hiddenLayerSize*(inputLayerSize+1)));;]],(hiddenLayerSize+1)]},
	{Theta1, Theta2}
]


nnCostFunction[nnParams_,inputLayerSize_,hiddenLayerSize_,numLabels_,X_,y_,lambda_]:=
Module[{m,Theta1,Theta2,J,Theta1Grad,Theta2Grad,a1,z2,a2,z3,a3,newy,d3,d2,grad},
	(* Number of samples *)
	m=Length[X];
	{Theta1, Theta2}=unrollWeights[nnParams, inputLayerSize, hiddenLayerSize];
	(* Forward Propgation *)
	a1=Map[Join[{1.},#]&,X];
	z2=a1.Transpose[Theta1];
	a2=Map[Join[{1.},#]&,Evaluate[sigmoid[z2]]];
	a3=sigmoid[a2.Transpose[Theta2]];
	newy=ConstantArray[0.,{m,numLabels}];
	(*newy=SparseArray[Table[{i, y[[i]]}->1., {i, 1, m}],{m,numLabels}];*)
	(* labels are expected to be successive positive integers *)
	Do[newy[[i,y[[i]]]]=1.,{i,1,m}];
	(* Calculate Cost *)
	J = 1./m Total[Total[Evaluate[-newy*Log[a3]-(1-newy)*Log[1-a3]]]]
		(* Include regularization, (overfitting penalty) *)
		+lambda/(2*m)*(Total[Flatten[Theta1[[All,2;;]]]^2]+Total[Flatten[Theta2[[All,2;;]]]^2]);
	(* Perform backprogation *)
	d3 = a3 - newy;
	d2 = (d3.Theta2)[[All, 2 ;;]]*sigmoidGradient[z2];
	(* Updates to weights, including regularization *)
	Theta1Grad=1./m*(Transpose[d2].a1)+lambda/m*Map[Join[{0.},#]&,Theta1[[All,2;;]]];
	Theta2Grad=1./m*(Transpose[d3].a2)+lambda/m*Map[Join[{0.},#]&,Theta2[[All,2;;]]];
	grad=Join[Flatten[Theta1Grad], Flatten[Theta2Grad]];
	(*Clear[m,Theta1,Theta2,Theta1Grad,Theta2Grad,a1,z2,a2,z3,a3,newy,d3,d2];*)
	{J, grad}
]


nnLearn[costFunction_,initParams_,\[Alpha]_:1,maxIter_:500]:=Module[{cost,grad,params=initParams,p=0},
	Print[ProgressIndicator[Dynamic[p]]];
	Do[
		p=i/maxIter;
		{cost,grad}=costFunction[params];
		params-=\[Alpha]*grad;
		Sow[cost];
	,{i,1,maxIter}];
	params
]


nnPredict[Theta1_, Theta2_, X_]:=Module[{h1, h2},
	h1=sigmoid[Map[Join[{1.},#]&,X].Theta1\[Transpose]];
	h2=sigmoid[Map[Join[{1.},#]&,h1].Theta2\[Transpose]];
	Flatten[Map[Ordering[#,-1]&,h2]]
]


End[]


EndPackage[]
