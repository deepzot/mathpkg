(* ::Package:: *)

(* Created 4-Jan-2013 by David Kirkby (University of California, Irvine) <dkirkby@uci.edu> *)

(* As of version 9, PhysicalConstants has been replaced by the built-in Quantity[],
but we keep using it here for backwards compatibility *)
Off[General::obspkg]
BeginPackage["DeepZot`CosmoTools`",{"Units`","PhysicalConstants`"}]


CosmoTools::usage=
"A collection of utilities for cosmological calculations.";


criticalDensityToday::usage=
"criticalDensityToday[hValue] calcualtes the present (z=0) critical density in J/m^3.
Multiply by Hratio[z] to get the critical density at a different redshift.";


radiationDensity::usage=
"radiationDensity[Tcmb,Nnu] calculates the Stefan-Boltzmann radiation energy density
in J/m^3 for a CMB temperature Tcmb in Kelvin and Nnu massless neutrinos.";


zstar::usage=
"zstar[\[CapitalOmega]mh2,\[CapitalOmega]bh2] calculates the redshift of last scattering using equation (E-1)
of Hu & Sugiyama 1996 (astro-ph/9510117).";


zeq::usage=
"zeq[\[CapitalOmega]mh2,Tcmb] calculates the redshift of matter-radiation equality using equation (2)
of Eistenstein & Hu 1998 (astro-ph/9709112).";


zdrag::usage=
"zdrag[\[CapitalOmega]mh2,\[CapitalOmega]bh2] calculates the redshift at which the baryon-photon fluid separates,
defined as the moment when the Compton drag experienced by the baryons falls below
some threshold, using equation (4) of Eistenstein & Hu 1998 (astro-ph/9709112).";


createCosmology::usage=
"createCosmology[name] associates the following definitions with the symbol name:
 - \[CapitalOmega]rad[name][z]
 - \[CapitalOmega]de[name][z]
 - \[CapitalOmega]mat[name][z]
 - \[CapitalOmega]photons[name][z]
 - \[CapitalOmega]nu[name][z]
 - H0[name]
 - Hratio[name][z]
 - curvatureTransform[name][x]
 - logGrowthRate[name][z]
 - primordialPower[name][k]
 - zstar[name]
 - zeq[name]
 - zdrag[name]
 - Rb\[Gamma][name][z]
 - betas[name][z]
 - nH[name][z]
 - XeEq[name][z]
Separate help is available for each of these definitions, e.g., ?\[CapitalOmega]rad.
Use the following options (defaults in parentheses from Planck+WP best-fit column
of Table 2 in Planck 2013 results paper or CAMB July 2013 params.ini) to customize
the created cosmology:
 - h (0.6704) value of H0/(100 km/s/Mpc) or calculated from Hzero if Automatic.
 - Hzero (Automatic) value of H0 in km/s/Mpc or calculated from h if Automatic.
 - \[CapitalOmega]m (0.3183) present-day fraction of matter, including any massive neutrinos.
 - \[CapitalOmega]\[CapitalLambda] (Automatic) present-day fraction of dark energy.
 - \[CapitalOmega]bh2 (0.022032) present-day physical baryon fraction.
 - \[CapitalOmega]ch2 (Automatic) present-day cold dark matter fraction.
 - w0 (-1) dark-energy equation parameter state present-day value.
 - wa (0) dark-energy equation of state parameter derivative wrt scale a.
 - \[CapitalOmega]k (0) present-day curvature fraction.
 - Tcmb (2.7255) present-day CMB temperature in Kelvin.
 - Nnu (3.046) effective total number of neutrinos.
 - NnuMassive (1) number of massive neutrino species (must be 0,1,2 or 3).
 - mnu (0.06) Mass of massive neutrino species in eV.
 - ns (0.9619) scalar primordial power spectral index.
 - logA (3.0980) log(10^10 As) where As is the scalar primordial power amplitude.
 - kpivot (0.05/Mpc) pivot wavenumber used to define primordial scalar power.
 - retau (0.0925) optical depth to reionization.
 - YP (0.247695) Helimum fraction.
Use OptionValue[name,opt] to get option values associated with a named
cosmology. To clear a previously defined cosmology, use Clear[name]. Use
the name provided here to identify the created cosmology in functions
like comovingDistanceFunction.";


createCMBVariant::usage=
"createCMBVariant[name,base,changes] creates a new cosmology starting from the specified base cosmology
and applying the specified changes (specified as a rule or list of rules), while keeping the quantities
best measured by CMB fixed. Specifically, the values of \[CapitalOmega]mh2 and \[CapitalOmega]bh2 (which determine rs(z*) are held
fixed and the base model's value of h is adjusted to preserve the base models angular diameter
distance DA(z*). The result is equivalent to calling createCosmology with the new parameters. Options are:
  - verbose: display the \[Delta]DA(z*) vs \[Delta]h graph used to determine the new value of h and parameter values
    (default is True).
  - hrange: amount to vary the base model's value of h on each side (default is 0.1).
  - nsteps: number of steps to divide hrange into, giving a total of 2 nsteps + 1 models for interpolation
    (default is 2).";


exportToCamb::usage=
"exportToCamb[filename,name] writes the parameters of the named cosmology to the
specified filename in CAMB input format.";


loadPlanckChain::usage=
"loadPlanckChain[model,dataset,params] loads the named parameters from the specified Planck chain
and returns a WeightedData object whose rows correspond to chain rows and columns correspond
to the values of the named parameters. Options are:
  - verbose: give verbose output (default is False).
  - maxRows: maximum number of rows to return (default is All).
  - PLA: path of the Planck Legacy Archive (default is \"/Volumes/Data/planck/PLA/\").
  - post: posterior to apply (\"BAO\", \"HST\", \"SNLS\", \"Union2\", etc, default is None).
  - fileIndex: index of a single chain file to read (default is All).
This function has been tested wth the public Planck chains available from
http://www.sciops.esa.int/wikiSI/planckpla/index.php?title=Cosmological_Parameters&instance=Planck_Public_PLA#Parameter_Chains
and uses the parameter name tags specified in
http://www.sciops.esa.int/SYS/WIKI/uploads/Planck_Public_PLA/5/59/Parameter_tag_definitions.pdf
which should be provided in a list, e.g., {\"omegabh2\",\"rdrag\"}. Reads all available chain files
in order until maxRows are reached or no more files are available. Use the fileIndex option to instead
read a single file.";


\[CapitalOmega]rad::usage=
"\[CapitalOmega]rad[name][z] returns the radiation energy density at the specified redshift relative
to the critical density today. Divide by Hratio[z]^2 to get the density relative to the
critical density at z.";


\[CapitalOmega]photons::usage=
"\[CapitalOmega]photons[name][z] returns the photon energy density at the specified redshift relative
to the critical density today. Divide by Hratio[z]^2 to get the density relative to the
critical density at z.";


\[CapitalOmega]de::usage=
"\[CapitalOmega]de[name][z] returns the dark-energy density at the specified redshift relative
to the critical density today. Divide by Hratio[z]^2 to get the density relative to the
critical density at z.";


\[CapitalOmega]mat::usage=
"\[CapitalOmega]mat[name][z] returns the matter density at the specified redshift relative
to the critical density today. Divide by Hratio[z]^2 to get the density relative to the
critical density at z. Includes dark matter, baryons and any massive neutrinos.";


\[CapitalOmega]nu::usage=
"\[CapitalOmega]nu[name][z] returns the massive neutrino energy density at the specified redshift relative
to the critical density today. Divide by Hratio[z]^2 to get the density relative to the
critical density at z. Calculated as NnuMassive (mnu/93.04)/ h^2.";


\[CapitalOmega]baryon::usage=
"\[CapitalOmega]baryon[name][z] returns the baryonic energy density at the specified redshift relative to
the critical density today. Divide by Hratio[z]^2 to get the density relative to the
critical density at z.";


\[CapitalOmega]nuCombined::usage=
"\[CapitalOmega]nuCombined[name][z] returns the massive + massless neutrino energy density at the specified redshift relative to
the critical density today. Divide by Hratio[z]^2 to get the density relative to the
critical density at z.";


\[CapitalOmega]cb::usage=
"\[CapitalOmega]cb[name][z] returns the cdm + baryonic energy density at the specified redshift relative to
the critical density today. Divide by Hratio[z]^2 to get the density relative to the
critical density at z.";


H0::usage=
"H0[name] returns H0 in (km/s)/Mpc.";


Hratio::usage=
"Hratio[name][z] returns H(z)/H0.";


hubbleDistance::usage=
"hubbleDistance[name] returns the Hubble distance c/H0 in Mpc (not Mpc/h).";


logGrowthRate::usage=
"logGrowthRate[name][z] returns the logarithmic growth rate f(a) = d(logG(a))/d(log(a)) at a = 1/(1+z)
using the approximate eqn (15) of Weinberg 2012. Use growthFunction[name,zmax] to evaluate the
corresponding growth function integral eqn (16).";


curvatureTransform::usage=
"curvatureTransform[name][x] returns the comoving transverse distance DM corresponding to the
scaled comoving line-of-sight distance x = DC/(c/H0).";


primordialPower::usage=
"primordialPower[name][k] returns the primordial power P(k) in 1/Mpc for k in 1/Mpc.";


Rb\[Gamma]::usage=
"Rb\[Gamma][name][z] returns the baryon to photon energy density ratio at the specified redshift.";


betas::usage=
"betas[name][z] returns the sound speed in the bayron-photon fluid relative to the
speed of light.";


nH::usage=
"nH[name][z] returns the Hydrogen number density per m^3 at the specified redshift.";


XeEq::usage=
"XeEq[name][z] returns Xe, the ratio of the free electron to Hydrogen number densities,
at the specified redshift, calculated assuming that the reaction e- + p <-> H + \[Gamma] remains
in chemical equilibrium.";


comovingDistanceFunction::usage=
"comovingDistanceFunction[cosmology,zmax] returns a function that evaluates the comoving distance
along the line of sight to a redshift z <= zmax for the named cosmology. Possible options (with
defaults in parentheses) are:
 - physical (False) units are Mpc (True) or Mpc/h (False).
 - inverted (False) return inverse function z(Dc) instead of Dc(z) when True.
 - pointsPerDecade (20) number of interpolation points to use per decade.";


transverseDistanceFunction::usage=
"transverseDistanceFunction[cosmology,zmax] returns a function that evaluates the comoving distance
transverse to the line of sight at a redshift z <= zmax for the named cosmology. Options are the same
as for comovingDistanceFunction.";


angularDiameterDistanceFunction::usage=
"angularDiameterDistanceFunction[cosmology,zmax] returns a function that evaluates the
angular diameter distance to a redshift z <= zmax for the named cosmology. Options are the same
as for comovingDistanceFunction.";


luminosityDistanceFunction::usage=
"angularDiameterDistanceFunction[cosmology,zmax] returns a function that evaluates the
luminosity distance to a redshift z <= zmax for the named cosmology. Options are the same
as for comovingDistanceFunction.";


ageOfUniverse::usage=
"ageOfUniverse[cosmology] returns the age of the universe in Gyr for the named cosmology.
The result is cached after first evaluation.";


lookbackTimeFunction::usage=
"lookbackTimeFunction[cosmology,zmax] returns a function that evaluates the lookback time
to a redshift z <= zmax for the named cosmology. Possible options are:
 - physical (True) units Gyr (True) or Gyr/h (False).
 - pointsPerDecade (20) number of interpolation points to use per decade.
 - inverted (False) return inverse function z(tLB) instead of tLB(z) when True.";


conformalTimeFunction::usage=
"conformalTimeFunction[cosmology,zmax] returns a function that evaluates the conformal time
at redshift z <= zmax for the named cosmology. Options are the same as for
lookbackTimeFunction.";


growthFunction::usage=
"growthFunction[cosmology,zmax] returns a function that evaluates the normalized linear
growth function G(z) at redshift z <= zmax for the named cosmology. The method is eqn (16)
of Weinberg 2012, so not exact, and only valid for models close to LCDM. Possible options are:
 - pointsPerDecade (20) number of interpolation points to use per decade.
 - inverted (False) return inverse function z(tLB) instead of tLB(z) when True.";


opticalDepthFunction::usage=
"opticalDepthFunction[cosmology,zmax] returns a function that evaluates the optical depth at
redshift z <= zmax for the named cosmology. Options are:
 - xeMethod: \"Detailed\" (default) or \"Equilibrium\".
 - type: \"Photon\" (default) or \"Baryon\" (for zstar and zdrag, respectively).
 - pointsPerDecade (20) number of interpolation points to use per decade.
 - inverted (False) return inverse function z(tau) instead of tau(z) when True.";


soundHorizonFunction::usage=
"soundHorizonFunction[cosmology,zmax] returns a function that evaluates the sound horizon at
redshift z <= zmax for the named cosmology. Options are the same as for
comovingDistanceFunction.";


rsdrag::usage=
"rsdrag[cosmology] returns the sound horizon in Mpc (not Mpc/h) at zdrag for the named cosmology.
The result is cached after the first evaluation.";


recombinationXe::usage=
"recombinationXe[cosmology,zmin,zmax] returns a function that evaluates
the free electron fraction (relative to Hydrogen nuclei) at redshift
zmin <= z <= zmax for the named cosmology.";


\[Tau]b::usage=
"\[Tau]b[cosmology,xe,zd,zmin] calculates the baryon drag optical depth to redshift zd > zmin for 
the named cosmology and free election function xe.";


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


massiveNuFunction[mnu_,Nnu_,Tcmb_]:=With[{A=(180 Zeta[3])/(7 \[Pi]^4),p=1.8614683763259083`,T\[Nu]=(Nnu/3)^(1/4)(4/11)^(1/3)Tcmb}, Function[z,
(1+(A mnu/((1+z) T\[Nu] N[Units`Convert[PhysicalConstants`BoltzmannConstant/(Units`ElectronVolt/Units`Kelvin),1]]))^p)^(1/p)]]


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
createCosmology::overconstrained2 = "Parameters are overconstrained: h=`1`, Hzero=`2`.";
createCosmology::overconstrained3 = "Parameters are overconstrainted: \[CapitalOmega]ch2=`1`, \[CapitalOmega]bh2=`2`, h=`3`, \[CapitalOmega]\[Nu]=`4`, \[CapitalOmega]m=`5`.";
createCosmology::noh = "One of h or Hzero must be specified.";
createCosmology::noml = "One of \[CapitalOmega]m or \[CapitalOmega]\[CapitalLambda] must be specified.";
createCosmology::nobc = "One of \[CapitalOmega]bh2 or \[CapitalOmega]ch2 must be specified.";
createCosmology::badnnu = "Number of massive neutrinos must be 0,1,2 or 3.";
createCosmology::badmnu = "Cannot have mnu < 0, or mnu > 0 with NnuMassive = 0.";
createCosmology[name_,OptionsPattern[]]:=
With[{
    hopt=OptionValue["h"],
    Hzero=OptionValue["Hzero"],
    \[CapitalOmega]\[CapitalLambda]=OptionValue["\[CapitalOmega]\[CapitalLambda]"],
    \[CapitalOmega]m=OptionValue["\[CapitalOmega]m"],
    \[CapitalOmega]bh2=OptionValue["\[CapitalOmega]bh2"],
    \[CapitalOmega]ch2=OptionValue["\[CapitalOmega]ch2"],
    w0=OptionValue["w0"],
    wa=OptionValue["wa"],
    \[CapitalOmega]k=OptionValue["\[CapitalOmega]k"],
    Tcmb=OptionValue["Tcmb"],
    Nnu=OptionValue["Nnu"],
    NnuMassive=OptionValue["NnuMassive"],
    mnu=OptionValue["mnu"],
    ns=OptionValue["ns"],
    logA=OptionValue["logA"],
    kpivot=OptionValue["kpivot"],
    retau=OptionValue["retau"],
	YP=OptionValue["YP"]
},
Module[{hval,\[CapitalOmega]mval,\[CapitalOmega]\[CapitalLambda]val,\[CapitalOmega]bh2val,\[CapitalOmega]ch2val},
    If[!MemberQ[{0,1,2,3},NnuMassive],
        Message[createCosmology::badnnu];
        Return[$Failed]
    ];
    If[mnu<0||(NnuMassive==0&&mnu>0),
        Message[createCosmology::badmnu];
        Return[$Failed]
    ];
    If[hopt===Automatic&&Hzero===Automatic,
      Message[createCosmology::noh];
      Return[$Failed]
    ];
    hval=If[hopt===Automatic,Hzero/100,hopt];
    If[hval!=Hzero/100,
      Message[createCosmology::overconstrained2,hopt,Hzero];
      Return[$Failed]
    ];
    name/: Options[name]= { "h"->hopt,"Hzero"->Hzero,"\[CapitalOmega]\[CapitalLambda]"->\[CapitalOmega]\[CapitalLambda],"\[CapitalOmega]m"->\[CapitalOmega]m,"\[CapitalOmega]bh2"->\[CapitalOmega]bh2,
        "\[CapitalOmega]ch2"->\[CapitalOmega]ch2,"w0"->w0,"wa"->wa,"\[CapitalOmega]k"->\[CapitalOmega]k,
        "Tcmb"->Tcmb,"Nnu"->Nnu,"NnuMassive"->NnuMassive,"mnu"->mnu,
        "ns"->ns,"logA"->logA,"kpivot"->kpivot,"retau"->retau,"YP"->YP };
    name/: \[CapitalOmega]rad[name]=Function[z,Evaluate[Simplify[radiationDensity[Tcmb,Nnu (3-NnuMassive)/3]/criticalDensityToday[hval](1+z)^4]]];
	name/: \[CapitalOmega]photons[name]=Function[z,Evaluate[Simplify[photonDensity[Tcmb]/criticalDensityToday[hval](1+z)^4]]];
    (* Determine values of \[CapitalOmega]m and \[CapitalOmega]\[CapitalLambda], one of which might be automatically calculated *)
    If[\[CapitalOmega]m===Automatic&&\[CapitalOmega]\[CapitalLambda]===Automatic,
      Message[createCosmology::noml];
      Return[$Failed]
    ];
    \[CapitalOmega]mval=If[\[CapitalOmega]m===Automatic,1-\[CapitalOmega]\[CapitalLambda]-\[CapitalOmega]k-\[CapitalOmega]rad[name][0],\[CapitalOmega]m];
    \[CapitalOmega]\[CapitalLambda]val=If[\[CapitalOmega]\[CapitalLambda]===Automatic,1-\[CapitalOmega]m-\[CapitalOmega]k-\[CapitalOmega]rad[name][0],\[CapitalOmega]\[CapitalLambda]];
    (* In case both are specified, check that they are self consistent *)
    If[\[CapitalOmega]mval+\[CapitalOmega]\[CapitalLambda]val+\[CapitalOmega]k+\[CapitalOmega]rad[name][0]!=1,
        Message[createCosmology::overconstrained,\[CapitalOmega]\[CapitalLambda]val,\[CapitalOmega]mval,\[CapitalOmega]rad[name][0],\[CapitalOmega]k];
        Return[$Failed]
    ];
    name/: \[CapitalOmega]de[name]=Function[z,Evaluate[Simplify[\[CapitalOmega]\[CapitalLambda]val Exp[3(-((wa z)/(1 + z)) + (1 + w0 + wa) Log[1 + z])]]]];
    name/: \[CapitalOmega]mat[name]=Function[z,Evaluate[Simplify[\[CapitalOmega]mval (1+z)^3]]];
    name/: \[CapitalOmega]nu[name]=Function[z,Evaluate[Simplify[NnuMassive (mnu/93.04)/hval^2 (1+z)^3]]];
    name/: H0[name]=100 hval;
    (* Determine values of \[CapitalOmega]bh2 and \[CapitalOmega]cdm, one of which might be automatically calculated *)
    If[\[CapitalOmega]bh2===Automatic&&\[CapitalOmega]ch2===Automatic,
      Message[createCosmology::nobc];
      Return[$Failed]
    ];
    \[CapitalOmega]bh2val=If[\[CapitalOmega]bh2===Automatic,(\[CapitalOmega]mval-\[CapitalOmega]nu[name][0])hval^2-\[CapitalOmega]ch2,\[CapitalOmega]bh2];
    \[CapitalOmega]ch2val=If[\[CapitalOmega]ch2===Automatic,(\[CapitalOmega]mval-\[CapitalOmega]nu[name][0])hval^2-\[CapitalOmega]bh2,\[CapitalOmega]ch2];
    (* In case both are specified, check that they are self consistent *)
    If[(\[CapitalOmega]ch2val+\[CapitalOmega]bh2val)/hval^2+\[CapitalOmega]nu[name][0]!=\[CapitalOmega]mval,
      Message[createCosmology::overconstrained3,\[CapitalOmega]ch2val,\[CapitalOmega]bh2val,hval,\[CapitalOmega]nu[name][0],\[CapitalOmega]mval];
      Return[$Failed]
    ];
    name/: \[CapitalOmega]baryon[name]=Function[z,Evaluate[Simplify[(\[CapitalOmega]mval-\[CapitalOmega]ch2val/hval^2-\[CapitalOmega]nu[name][0])(1+z)^3]]];
	name/: \[CapitalOmega]nuCombined[name]=Function[z,Evaluate[Simplify[7/8(4/11)^(4/3) \[CapitalOmega]photons[name][0](Nnu/3)((3-NnuMassive)+NnuMassive massiveNuFunction[mnu,Nnu,Tcmb][z])*(1+z)^4]]];
	name/: \[CapitalOmega]cb[name]=Function[z,Evaluate[Simplify[(\[CapitalOmega]mval-\[CapitalOmega]nu[name][0]) (1+z)^3]]];
    name/: Hratio[name]=Function[z,Evaluate[Sqrt[Simplify[\[CapitalOmega]de[name][z]+\[CapitalOmega]k (1+z)^2+\[CapitalOmega]cb[name][z]+\[CapitalOmega]nuCombined[name][z]+\[CapitalOmega]photons[name][z]]]]];
    name/: hubbleDistance[name]=hubbleScale[PhysicalConstants`SpeedOfLight,hval,Units`Mega Units`Parsec];
    name/: curvatureTransform[name]=Function[x,Evaluate[Simplify[Which[
        \[CapitalOmega]k>0,Sinh[Sqrt[\[CapitalOmega]k]x]/Sqrt[\[CapitalOmega]k],\[CapitalOmega]k<0,Sin[Sqrt[-\[CapitalOmega]k]x]/Sqrt[-\[CapitalOmega]k],True,x]]]];
    name/: primordialPower[name]=Function[k,Evaluate[Simplify[10^-10 Exp[logA](k/kpivot)^(ns-1)k]]];
    name/: logGrowthRate[name]=
        With[{\[Gamma]=0.55+0.05(1+w0+wa/2)},
            Function[z,Evaluate[Simplify[(\[CapitalOmega]mat[name][z]/Hratio[name][z]^2)^\[Gamma]]]]
        ];
    With[{\[CapitalOmega]mh2=\[CapitalOmega]mat[name][0]hval^2},
        name/: zstar[name]=zstar[\[CapitalOmega]mh2,\[CapitalOmega]bh2];
        name/: zeq[name]=If[Tcmb>0,zeq[\[CapitalOmega]mh2,Tcmb],Indeterminate];
        name/: zdrag[name]=zdrag[\[CapitalOmega]mh2,\[CapitalOmega]bh2];
    ];
    With[{\[CapitalOmega]\[Gamma]=radiationDensity[Tcmb,0]/criticalDensityToday[hval],\[CapitalOmega]b=\[CapitalOmega]bh2/hval^2},
        name/: Rb\[Gamma][name]=If[\[CapitalOmega]\[Gamma]>0,Function[z,Evaluate[Simplify[(3\[CapitalOmega]b)/(4\[CapitalOmega]\[Gamma])/(1+z)]]],Indeterminate];
        name/: betas[name]=If[\[CapitalOmega]\[Gamma]>0,Function[z,Evaluate[Simplify[1/Sqrt[3(1+Rb\[Gamma][name][z])]]]],Indeterminate];
    ];
    With[{mc2=Convert[PhysicalConstants`ProtonMass PhysicalConstants`SpeedOfLight^2/Joule,1]},
      name/: nH[name]=Function[z,Evaluate[Simplify[(1-YP)\[CapitalOmega]bh2/hval^2 criticalDensityToday[hval]/mc2 (1+z)^3]]]
    ];
    With[{
      eps0=Units`Convert[Units`Rydberg/PhysicalConstants`BoltzmannConstant/Kelvin,1],
      scale=Units`Convert[
        PhysicalConstants`ElectronMass PhysicalConstants`BoltzmannConstant/
          (2 \[Pi] PhysicalConstants`PlanckConstantReduced^2)Kelvin Meter^2,1
      ]
    },
    name/: XeEq[name]=Function[z,
      With[{y=(scale Tcmb(1+z))^(3/2) Exp[-eps0/(Tcmb(1+z))]/nH[name][z]},
        (Sqrt[y(y+4)]-y)/2
      ]
    ]
  ];
]]
SetAttributes[createCosmology,HoldFirst]
Options[createCosmology]={
    "h"->0.6704,"Hzero"->Automatic,"\[CapitalOmega]\[CapitalLambda]"->Automatic,"\[CapitalOmega]m"->0.3183,"\[CapitalOmega]bh2"->0.022032,"\[CapitalOmega]ch2"->Automatic,
    "w0"->-1,"wa"->0,"\[CapitalOmega]k"->0,
    "Tcmb"->2.7255,"Nnu"->3.046,"NnuMassive"->1,"mnu"->0.06,
    "ns"->0.9619,"logA"->3.0980,"kpivot"->0.05,"retau"->0.0925,"YP"->0.247695
};


Clear[createCMBVariant]
createCMBVariant[variant_,base_,changes_,OptionsPattern[]]:=
With[{
  verbose=OptionValue["verbose"],
  hrange=OptionValue["hrange"],
  nsteps=OptionValue["nsteps"]
},
Module[{changesList,h0,h1,\[CapitalOmega]mh2,\[CapitalOmega]bh2,zstar0,zstar1,Dc0,Dc1,Dstar0,Dstar1,data,model,dh,h,interpolator,dhval},
  changesList=If[Head[changes]===Rule,{changes},changes];
  (* Extract base model parameters *)
  h0=H0[base]/100;
  \[CapitalOmega]bh2=OptionValue[base,"\[CapitalOmega]bh2"];
  \[CapitalOmega]mh2=\[CapitalOmega]mat[base][0]h0^2;
  zstar0=zstar[base];
  Dc0=angularDiameterDistanceFunction[base,zstar0,physical->True];
  Dstar0=Dc0[zstar0];
  (* Create a grid of variant models with different values of h and tabulate their Dc(zstar) values *)
  dh=hrange/nsteps;
  data=Table[
    (* Create the variant model *)
    h=h0+dh step;
    createCosmology[model,Join[{"h"->h,"\[CapitalOmega]m"->\[CapitalOmega]mh2/h^2},changesList,Options[base]]];
    (* zstar should not change unless we change \[CapitalOmega]mh2 or \[CapitalOmega]bh2 *)
    zstar1=zstar[model];
    Dc1=angularDiameterDistanceFunction[model,zstar1,physical->True];
    Dstar1=Dc1[zstar1];
    {h-h0,Dstar1-Dstar0}
    ,{step,-nsteps,+nsteps}
  ];
  If[verbose===True,
    Print[ListPlot[data,Frame->True,FrameLabel->{"\[Delta]h","\[Delta]D(z*) (Mpc)"},
      Joined->True,PlotMarkers->Automatic,PlotStyle->Directive[PointSize[Large],Red]]
    ];
  ];
  interpolator=Interpolation[data];
  dhval=dhval/.FindRoot[interpolator[dhval]==0,{dhval,0,-hrange,+hrange}];
  createCosmology[variant,Join[{"h"->h0+dhval,"\[CapitalOmega]m"->\[CapitalOmega]mh2/(h0+dhval)^2},changesList,Options[base]]];
  If[verbose===True,
    Print["base model: ",Options[base]];
    Print["variant model: ",Options[variant]];
    Print["changes: ",Complement[Options[variant],Options[base]]];
  ]
]]
SetAttributes[createCMBVariant,HoldFirst]
Options[createCMBVariant]={"verbose"->True,"hrange"->0.1,"nsteps"->2};


Clear[exportToCamb]
exportToCamb[filename_,cosmology_,OptionsPattern[]]:=With[{
    h=H0[cosmology]/100,
    \[CapitalOmega]m=\[CapitalOmega]mat[cosmology][0],
    \[CapitalOmega]b=\[CapitalOmega]baryon[cosmology][0],
    Nnu=OptionValue[cosmology,"Nnu"],
    NnuMassive=OptionValue[cosmology,"NnuMassive"],
    logA=OptionValue[cosmology,"logA"],
    \[CapitalOmega]\[Nu]=\[CapitalOmega]nu[cosmology][0],
    path=DirectoryName[filename],
    tag=FileBaseName[filename],
    redshifts=Sort[OptionValue["redshifts"],Greater],
    boilerplateFilename=OptionValue["boilerplate"],
    form=OptionValue["form"],
    abspath=OptionValue["abspath"]
},
Module[{lines,boilerplate,outputroot},
Assert[OptionValue[cosmology,"wa"]==0];
boilerplate=If[boilerplateFilename===None,{},ReadList[boilerplateFilename,String]];
outputroot=If[abspath===True,path<>tag,tag];
lines={
"## File automatically generated by DeepZot`CosmoTools`exportToCamb on "<>DateString[],
"## Recreate the cosmology that generated this file using:",
"## createCosmology["<>tag<>","<>ToString[InputForm[Options[cosmology]]]<>"]",
"use_physical = T",
"hubble = "<>ToString[H0[cosmology],form],
"ombh2 = "<>ToString[\[CapitalOmega]b h^2,form],
"omch2 = "<>ToString[(\[CapitalOmega]m-\[CapitalOmega]\[Nu]-\[CapitalOmega]b)h^2,form],
"omnuh2 = "<>ToString[\[CapitalOmega]\[Nu] h^2,form],
"omk = "<>ToString[OptionValue[cosmology,"\[CapitalOmega]k"],form],
"w = "<>ToString[OptionValue[cosmology,"w0"],form],
"temp_cmb = "<>ToString[OptionValue[cosmology,"Tcmb"],form],
"massless_neutrinos = "<>ToString[If[\[CapitalOmega]\[Nu]>0,((3-NnuMassive)/3)Nnu,Nnu],form],
"massive_neutrinos  = "<>ToString[If[\[CapitalOmega]\[Nu]>0,(NnuMassive/3)Nnu,0],form],
"helium_fraction = "<>ToString[OptionValue[cosmology,"YP"],form],
"scalar_amp(1) = "<>ToString[10^-10 Exp[logA],form],
"scalar_spectral_index(1) = "<>ToString[OptionValue[cosmology,"ns"],form],
"pivot_scalar = "<>ToString[OptionValue[cosmology,"kpivot"],form],
"re_optical_depth = "<>ToString[OptionValue[cosmology,"retau"],form],
"output_root = "<>outputroot,
"transfer_kmax = "<>ToString[OptionValue["kmax"],form],
"transfer_k_per_logint = "<>ToString[OptionValue["kPerLogInt"],form],
"transfer_num_redshifts = "<>ToString[Length[redshifts],form],
"accuracy_boost = "<>ToString[OptionValue["accuracyBoost"],form]
};
lines=Join[lines,
  Flatten[Table[{
    "transfer_redshift("<>ToString[i]<>") = "<>ToString[redshifts[[i]],form],
    "transfer_filename("<>ToString[i]<>") = transfer_"<>ToString[i]<>".dat",
    "transfer_matterpower("<>ToString[i]<>") = matterpower_"<>ToString[i]<>".dat"
  },{i,Length[redshifts]}]]
];
lines=Join[lines,boilerplate];
Export[filename,Append[lines,""],"Table"]
]]
Options[exportToCamb]={
  "form"->CForm,"kmax"->2,"kPerLogInt"->0,"redshifts"->{0},"accuracyBoost"->1,
  "boilerplate"->"DeepZot/camb_boilerplate.ini","abspath"->True
};


Clear[loadPlanckChain];
loadPlanckChain::nofile="No chains found for `1`.";
loadPlanckChain::nopnames="Missing parameter names file `1`.";
loadPlanckChain::nopar="No such parameter `1`.";
loadPlanckChain::notable="File is not in tabular format.";
loadPlanckChain::ncols="Found `1` columns but expected `2`.";
loadPlanckChain[model_,dataset_,parameters_List,OptionsPattern[]]:=
With[{
  verbose=OptionValue["verbose"],
  maxRows=OptionValue["maxRows"],
  PLA=OptionValue["PLA"],
  post=OptionValue["post"],
  fileIndex=OptionValue["fileIndex"]
},
Module[{path,indexPattern,files,pnamesFile,pnames,pos,columns,rows,raw,nrows,ncols,userows,data,wgts},
  (* Prepare the path for the requested chains *)
  path=FileNameJoin[{model,dataset,model<>"_"<>dataset}];
  If[StringQ[post],
    (* Append posterior tag to file path *)
    path=path<>"_post_"<>post
  ];
  If[verbose===True,
    Print["Reading chains from ",path]
  ];
  (* Find the names of all available chain files *)
  indexPattern=If[fileIndex === All,DigitCharacter..,ToString[fileIndex]];
  files = FileNames[path~~"_"~~indexPattern~~".txt",{PLA}];
  If[files==={},
    Message[loadPlanckChain::nofile,path];
    Return[$Failed]
  ];
  (* Get the filename containing parameter names for this chain *)
  pnamesFile=FileNameJoin[{PLA,path<>".paramnames"}];
  If[!FileExistsQ[pnamesFile],
    Message[loadPlanckChain::nopnames,pnamesFile];
    Return[$Failed]
  ];
  (* Parse the parameter names file *)
  pnames=Map[First[StringCases[First[#],RegularExpression["^\\s*(\\w+)\\*?"]->"$1"]]&,Import[pnamesFile]];
  (* Add the names of the header columns *)
  pnames=Join[{"weight","likelihood"},pnames];
  (* Lookup the requested parameter indices *)
  columns=Table[
    pos=Position[pnames,p,{1},Heads->False];
    If[pos=={},
      Message[loadPlanckChain::nopar,p];
      Return[$Failed]
    ];
    pos[[1,1]],{p,parameters}
  ];
  If[verbose===True,
    Print["Reading parameters in columns ",columns]
  ];
  (* Loop over chain files *)
  data={};
  wgts={};
  Do[
    raw=ReadList[file,Real,RecordLists->True];
    (* Check for the expected number of columns *)
    If[ArrayDepth[raw]!=2,
      Message[loadPlanckChain::notable];
      Return[$Failed]
    ];
    {nrows,ncols}=Dimensions[raw];
    If[ncols!=Length[pnames],
      Message[loadPlanckChain::ncols,ncols,Length[pnames]];
	  Print[pnames];
      Return[$Failed]
    ];
    userows=If[!IntegerQ[maxRows]||Length[data]+nrows<=maxRows,nrows,maxRows-Length[data]];
    If[userows===0,Break[]];
    If[verbose===True,
      Print["Reading ",userows," of ",nrows," rows from ",file]
    ];
    (* Extract the requested parameter values *)
    data=Join[data,raw[[;;userows,columns]]];
    (* Extract the corresponding weights, which are always in column 1 *)
    wgts=Join[wgts,raw[[;;userows,1]]];
    ,
    {file,files}
  ];
  (* Return a weighted dataset *)
  WeightedData[data,wgts]
]]
Options[loadPlanckChain]={
  "verbose"->False,"maxRows"->All,"PLA"->"/Volumes/Data/planck/PLA/","post"->None,"fileIndex"->All
};


(* Builds a function that evaluates f[z]=scale*transform[z,Integral[integrand[zz],{zz,0,z}]] using interpolation
in log(1+z) with the specified number of points per decade. The default scale=1 and transform[z,f]=f.
With inverted->True, evaluates z[f] instead of f[z]. *)
Clear[buildFunction]
buildFunction::badmethod="Only supported methods are \"NIntegrate\" and \"NDSolve\".";
buildFunction[integrand_,zmax_,OptionsPattern[]]:=
With[{
  method=OptionValue["method"],
  pointsPerDecade=OptionValue["pointsPerDecade"],
  inverted=OptionValue["inverted"],
  scale=OptionValue["scale"],
  transform=OptionValue["transform"]
},
Module[{npts,ds,sval,partials,tabulated,G,s,interpolator},
    If[method!="NIntegrate"&&method!="NDSolve",
      Message[buildFunction::badmethod];
      Return[$Failed]
    ];
    (* Create the grid in s = Log[1+z] to use *)
	npts=Ceiling[N[Log[1+zmax]pointsPerDecade/Log[10]]];
    ds=Log[1+zmax]/(npts-1);
	sval=Table[n ds,{n,0,npts-1}];
    If[method=="NIntegrate",
      (* Integrate over equally spaced intervals in s = log(1+z) *)
  	partials=Table[NIntegrate[integrand[Exp[s]-1]Exp[s],{s,sval[[n]],sval[[n+1]]}],{n,1,npts-1}];
      (* Accumulate the partials and add the boundary condition that the integral is zero at z = 0 *)
  	tabulated=Prepend[Accumulate[partials],0];
      ,
      (* Solve the ODE from s = 0 to s = Log[1+zmax] *)
      G=G/.First[NDSolve[{G'[s]==integrand[Exp[s]-1]Exp[s],G[0]==0},G,{s,0,Log[1+zmax]},MaxStepSize->ds]];
      (* Tabulate the solution *)
      tabulated=G/@sval;
    ];
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
Options[buildFunction]={
  "method"->"NDSolve","pointsPerDecade"->20,"scale"->1,"transform"->(#2&),"inverted"->False
};


Clear[growthFunction]
growthFunction[cosmology_,zmax_,options:OptionsPattern[{buildFunction}]]:=
Module[{\[Gamma]},
    buildFunction[logGrowthRate[cosmology][#1]/(1+#1)&,zmax,
        transform->(Exp[-#2]&),FilterRules[{options},Options[buildFunction]]]
]


(* Builds a distance function using options physical (Mpc vs Mpc/h), transverse (apply curvatureTransform), and
multiplying result by (1+z)^zpower *)
Clear[buildDistanceFunction]
buildDistanceFunction[cosmology_,zmax_,options:OptionsPattern[{buildDistanceFunction,buildFunction}]]:=
With[{physical=OptionValue["physical"],transverse=OptionValue["transverse"],zpower=OptionValue["zpower"]},
Module[{h,scale,transform},
    h=If[physical===True,H0[cosmology]/100,1];
    scale=hubbleScale[PhysicalConstants`SpeedOfLight,h,Units`Mega Units`Parsec];
    transform=If[transverse===True,curvatureTransform[cosmology][#2](1+#1)^zpower,#2 (1+#1)^zpower]&;
	buildFunction[1/Hratio[cosmology][#1]&,zmax,"scale"->scale,"transform"->transform,
        FilterRules[{options},Options[buildFunction]]
    ]
]]
Options[buildDistanceFunction]={"physical"->False,"transverse"->False,"zpower"->0};


Clear[opticalDepthFunction]
opticalDepthFunction::badtype="Invalid type `1`. Choose \"Photon\" (default) or \"Baryon\".";
opticalDepthFunction::badxe="Invalid xeMethod `1`. Choose \"Detailed\" (default) or \"Equilibrium\".";
opticalDepthFunction[cosmology_,zmax_,OptionsPattern[]]:=
With[{
  type=OptionValue["type"],
  xeMethod=OptionValue["xeMethod"],
  inverted=OptionValue["inverted"],
  pointsPerDecade=OptionValue["pointsPerDecade"],
  plotOption=OptionValue["plot"],
  clight=PhysicalConstants`SpeedOfLight,
  \[Sigma]T=PhysicalConstants`ThomsonCrossSection
},
Module[{Xe,drag,scale,taudot},
  (* Which type of optical depth are we calculating ? *)
  drag=Which[
    type=="Photon",1&,
    type=="Baryon",Rb\[Gamma][cosmology],
    True,Message[opticalDepthFunction::badtype,type];Return[$Failed]
  ];
  (* Get the free electron fraction function to use *)
  Xe=Which[
    xeMethod=="Detailed",recombinationXe[cosmology],
    xeMethod=="Equilibrium",XeEq[cosmology],
    True,Message[opticalDepthFunction::badxe,xeMethod];Return[$Failed]
  ];
  (* Calculate scale of d(tau)/dz, accounting for the units of nH and H0 *)
  scale=Convert[clight \[Sigma]T/(Meter^3)/((Kilo Meter/Second)/(Mega Parsec)),1];
  (* Make a function giving the derivative of the optical depth wrt redshift *)
  taudot=Function[z,Evaluate[Simplify[scale Xe[z]nH[cosmology][z]/((1+z)H0[cosmology]Hratio[cosmology][z])/drag[z]]]];
  If[plotOption===True,
    (* Plot the integrand that we will pass to build function *)
    Print[LogPlot[taudot[Exp[t]-1]Exp[t],{t,0,Log[1+zmax]},PlotRange->All]]
  ];
  (* Build and return the interpolated integral *)
  buildFunction[taudot,zmax,"inverted"->inverted,"pointsPerDecade"->pointsPerDecade]
]]
Options[opticalDepthFunction]={"type"->"Photon","xeMethod"->"Detailed","inverted"->False,"pointsPerDecade"->200,"plot"->False};


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
    scale=hubbleScale[1,H0[cosmology]/100,Units`Giga Units`Year];
	scale NIntegrate[1/Hratio[cosmology][Exp[s]-1],{s,0,Infinity}]
]


Clear[lookbackTimeFunction]
lookbackTimeFunction[cosmology_,zmax_,options:OptionsPattern[{lookbackTimeFunction,buildFunction}]]:=
With[{physical=OptionValue["physical"]},
Module[{h,scale},
    h=If[physical===True,H0[cosmology]/100,1];
    scale=hubbleScale[1,h,Units`Giga Units`Year];
	buildFunction[1/(1+#1)/Hratio[cosmology][#1]&,zmax,"scale"->scale,FilterRules[{options},Options[buildFunction]]]
]]
Options[lookbackTimeFunction]={"physical"->True};


Clear[conformalTimeFunction]
conformalTimeFunction[cosmology_,zmax_,options:OptionsPattern[{conformalTimeFunction,buildFunction}]]:=
With[{physical=OptionValue["physical"]},
Module[{h,scale,eta0},
    h=If[physical===True,H0[cosmology]/100,1];
    scale=hubbleScale[1,h,Units`Giga Units`Year];
    eta0=NIntegrate[1/Hratio[cosmology][Exp[s]-1]Exp[s],{s,0,Infinity}];
    buildFunction[1/Hratio[cosmology][#1]&,zmax,"scale"->scale,"transform"->((eta0-#2)&),FilterRules[{options},Options[buildFunction]]]
]]
Options[conformalTimeFunction]={"physical"->True};


Clear[soundHorizonFunction]
soundHorizonFunction[cosmology_,zmax_,options:OptionsPattern[{soundHorizonFunction,buildFunction}]]:=
With[{physical=OptionValue["physical"]},
Module[{h,scale,r0},
    h=If[physical===True,H0[cosmology]/100,1];
    scale=hubbleScale[PhysicalConstants`SpeedOfLight,h,Units`Mega Units`Parsec];
    r0=NIntegrate[betas[cosmology][Exp[s]-1]/Hratio[cosmology][Exp[s]-1]Exp[s],{s,0,Infinity}];
    buildFunction[betas[cosmology][#1]/Hratio[cosmology][#1]&,zmax,"scale"->scale,"transform"->((r0-#2)&),FilterRules[{options},Options[buildFunction]]]
]]
Options[soundHorizonFunction]={"physical"->False};


Clear[rsdrag]
rsdrag[cosmology_]:=rsdrag[cosmology]^=
Module[{scale,sdrag},
    scale=hubbleScale[PhysicalConstants`SpeedOfLight,H0[cosmology]/100,Units`Mega Units`Parsec];
    sdrag=Log[1+zdrag[cosmology]];
    scale NIntegrate[betas[cosmology][Exp[s]-1]/Hratio[cosmology][Exp[s]-1]Exp[s],{s,sdrag,Infinity}]
]


Clear[recombinationXe]
(* NDSolve doesn't like to go all the way down below ~100 or past ~1800 *)
recombinationXe[cosmology_,OptionsPattern[]]:=
With[{
  zmin=OptionValue["zmin"],
  zmaxOption=OptionValue["zmax"],
  zmaxXeEq=OptionValue["zmaxXeEq"],
  zmaxGuess=OptionValue["zmaxGuess"],
  extendedOption=OptionValue["extended"],
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
  \[CapitalOmega]b=OptionValue[cosmology,"\[CapitalOmega]bh2"]/(H0[cosmology]/100)^2 (* Baryon Fraction Today *),
  \[Rho]crit=criticalDensityToday[H0[cosmology]/100] Units`Joule/Units`Meter^3 (* Critical Density Today *)
},
Module[{zmax,z,H,Trad,Tmat,t,\[Rho]b,nez,nHz,nHez,xe,\[Alpha]B,\[Beta]B,K,C,eqns,xef},
    zmax=If[zmaxOption===Automatic,
        (* Find redshift where XeEq[z] = zMaxXeEq using zmaxGuess as starting point for root finder *)
        (* This could probably be solved analytically with a bit more work, if necessary *)
        z/.FindRoot[XeEq[cosmology][z]==zmaxXeEq,{z,zmaxGuess}],
        zmaxOption
    ];
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
	(* Number Density of Hydrogen nuclei as function of z *)
    nHz=nH[cosmology][z]/Units`Meter^3;
	(* Number Density of free electrons as function of z *)
	nez=Units`Convert[xe[z]nHz,1/Units`Meter^3];
	(* Number Density of Helium nuclei as a function of z (via \[Rho]b) *)
	nHez=Units`Convert[YP*\[Rho]b/(4*mp PhysicalConstants`SpeedOfLight^2),1/Units`Meter^3];
	(* Cosmological Redshifting Rate *)
	K=\[Lambda]\[Alpha]^3/(8 \[Pi] H);
	(* Effect of 2 Photon Decay and Redshifting *)
	C=Simplify[(1+K \[CapitalLambda]2\[Gamma] nHz (1-xe[z]))/(1+K (\[CapitalLambda]2\[Gamma] +\[Beta]B )nHz(1-xe[z]))];
    (* Simplify the equations to be solved *)
    eqns={
		(* Free electron equation *)
		D[xe[z],z]==Units`Convert[C (xe[z]^2 nHz \[Alpha]B-\[Beta]B(1-xe[z])Exp[-E2s1sH/(kB Tmat[z] Units`Kelvin)])/((1+z)H),1],
		(* Matter/Radiation Temperature Relation Eq 5 *)
		D[Tmat[z],z]==Units`Convert[(8\[Sigma]T Arad Trad^4)/(3(1+z)H  me PhysicalConstants`SpeedOfLight),1]Simplify[nez/(nez+nHz+nHez)]*(Tmat[z]-Trad/Units`Kelvin)+2Tmat[z]/(1+z),
		(*Initial conditions *)
		xe[zmax]==1,Tmat[zmax]==T0*(1+zmax)/Units`Kelvin
    };
	xef=(xe/.Flatten[NDSolve[eqns,{xe,Tmat},{z,zmin,zmax}]]);
    (* Use XeEq[z] above 0.999 zmax. This creates a tiny discontinuity at the cross over that
    could be interpolated out if necessary. *)
    If[extendedOption===True,Function[z,If[z<0.99zmax,xef[z],XeEq[cosmology][z]]],xef]
]]
Options[recombinationXe]={
  "zmin"->0,"zmax"->Automatic,"zmaxXeEq"->0.999,"zmaxGuess"->1500,"extended"->True
};


Clear[\[Tau]b];
\[Tau]b[cosmology_,xe_,zd_?NumericQ,zmin_:100]:=
With[{
\[Sigma]T=PhysicalConstants`ThomsonCrossSection,
mp=PhysicalConstants`ProtonMass,
c=PhysicalConstants`SpeedOfLight,
\[CapitalOmega]\[Gamma]=\[CapitalOmega]photons[cosmology][0],
\[Rho]crit=criticalDensityToday[H0[cosmology]/100]Units`Joule/Units`Meter^3,
YP=OptionValue[cosmology,"YP"],
h0=H0[cosmology] Convert[(Units`Kilo Units`Meter/Units`Second/(Units`Mega Units`Parsec)),1/Units`Second]
},
Module[{scale},
  scale=Convert[(4\[CapitalOmega]\[Gamma])/3(\[Sigma]T(1-YP)\[Rho]crit)/(mp h0 c),1];
  Print[LogLogPlot[scale (xe[zp](1+zp)^3)/Hratio[cosmology][zp],{zp,zmin,zd}]];
  scale NIntegrate[(xe[zp](1+zp)^3)/Hratio[cosmology][zp],{zp,zmin,zd}]
]]


End[]


EndPackage[]
