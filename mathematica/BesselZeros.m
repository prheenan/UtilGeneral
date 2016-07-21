(* ::Package:: *)

(* :Name: NumericalMath`BesselZeros` *)

(* :Context: NumericalMath`BesselZeros` *)

(* :Title: Zeros of Bessel Functions *)

(* :Author: Jerry B. Keiper *)

(* :Summary:
     This package provides functions that find the zeros of Bessel functions.
*)

(* :Copyright: Copyright 1992-2007,  Wolfram Research, Inc. *)

(* :Package Version: 2.0 *)

(* :Mathematica Version: 3.0 *)

(* :History:
     V1.0 by Jerry B. Keiper, February 1992.
     V1.1 by Jerry B. Keiper, September 1994 -- Added extrapolation guesses.
     V2.0 by Shiekh Y. Anwar, July 1999 -- generalized most functions to
         negative order, added specification of zeros by interval, added code
         to catch degenerate cases of lambda.
*)

(* :Sources:
Abramowitz and Stegun, Handbook of Mathematical Functions,
    equations 9.5.12, 9.5.13, 9.5.27-33.
Royal Society Mathematical Tables, vol 7, Bessel functions, Part III. 
    Zeros and associated values, edited by F. W. Olver (Cambridge Univ. 
    Press, Cambridge, England, 1960).
J. Segura, A global Newton method for the zeros of cylinder 
    functions, Numerical Algorithms 18 (1998) 259-
J. Segura, Bounds on Differences of Adjacent Zeros of Bessel 
    Functions and Iterative Relations between consecutive Zeros, 
    Mathematics of Computation, (1997)
P. Kravanja, O. Ragos, M.N. Vrahatis and F.A. Zafiropoulos, ZEBEC: A 
    mathematical software package for computing simple zeros of Bessel 
    functions of real order and complex argument, Computer Physics 
    Communications 113 (1998) 220-
M.N. Vrahatis, O. Ragos, T. Skiniotis, F.A. Zafiropoulos and T.N. 
    Grapsa, Erratum to: RFSFNS: A portable package for the numerical 
    determination of the number and the calculation of roots of Bessel 
    functions, Computer Physics Communications 92 (1995) 252-, Computer 
    Physics Communications 117 (1999) 290-
J. Segura  and A. Gil, ELF and GNOME: Two tiny codes to evaluate the 
    real zeros of the Bessel functions of the first kind for real orders, 
    Computer Physics Communications 117 (1999) 250-
*)

(* :Limitations:
     Does not cover all negative orders for
     BesselJPrimeZeros and BesselKPrimeZeros.
*)

(* :Discussion:
The reason for not handling all negative orders of BesselJPrimeZeros
and BesselKPrimeZeros is the problem of the unsmooth
appearance of extra zeros, that does not seem amenable to the
method used in the case of the straight Bessel function. These
functions do handle orders >= -1 and >= -1/2, respectively.

For positive order, the techniques used by this package are rooted
around asymptotic formulae for the zeros of Bessel functions found
in Abramowitz and Stegun, Section 9.5. A&S does not include formulations
for negative orders of Bessel functions. However, a 
generalization for the Bessel function case (A&S 9.5.12), as opposed 
to the derivative case (A&S 9.5.13) was stumbled across, where by 
're-aligning' the counting of zeros in the negative order case, the 
original asymptotic approximation worked as well as in its original 
positive order arena. The shifted counting for negative order are:
   s -> s - Ceiling[nu]   for negative order BesselJ
   s -> s - Round[nu]     for negative order BesselY
s being the integer counter, and nu the order.
*)

Message[General::obspkg, "NumericalMath`BesselZeros`"]
BeginPackage["NumericalMath`BesselZeros`"]


Unprotect[
     BesselJZeros,
     BesselYZeros,
     BesselJPrimeZeros,
     BesselYPrimeZeros,
     BesselJYJYZeros,
     BesselJPrimeYPrimeJPrimeYPrimeZeros,
     BesselJPrimeYJYPrimeZeros,
     BesselJZerosInterval,
     BesselYZerosInterval,
     BesselJPrimeZerosInterval,
     BesselYPrimeZerosInterval,
     BesselJYJYZerosInterval,
     BesselJPrimeYPrimeJPrimeYPrimeZerosInterval,
     BesselJPrimeYJYPrimeZerosInterval
];


BesselJZeros::usage =
"BesselJZeros[nu, n] gives a list of the first n zeros of the order nu \
BesselJ function. BesselJZeros[nu, {m, n}] gives a list of the mth through \
the nth zeros."

BesselYZeros::usage =
"BesselYZeros[nu, n] gives a list of the first n zeros of the order nu \
BesselY function. BesselYZeros[nu, {m, n}] gives a list of the mth through \
the nth zeros."

(** add that this returns only for nu >= -1 **)
BesselJPrimeZeros::usage =
"BesselJPrimeZeros[nu, n] gives a list of the first n zeros of the \
derivative of the order nu BesselJ function, for nu >= -1. \
BesselJPrimeZeros[nu, {m, n}] gives a list of the mth through the nth zeros."

(** add that this returns only for nu >= -1/2 **)
BesselYPrimeZeros::usage =
"BesselYPrimeZeros[nu, n] gives a list of the first n zeros of the \
derivative of the order nu BesselY function, for nu >= -1/2. \
BesselYPrimeZeros[nu, {m, n}] gives a list of the mth through the nth zeros."

BesselJYJYZeros::usage =
"BesselJYJYZeros[nu, l, n] gives a list of the first n zeros of \
BesselJ[nu, z] BesselY[nu, l z] - BesselJ[nu, l z] BesselY[nu, z]. \
BesselJYJYZeros[nu, l, {m, n}] gives a list of the mth through the \
nth zeros."

BesselJPrimeYPrimeJPrimeYPrimeZeros::usage =
"BesselJPrimeYPrimeJPrimeYPrimeZeros[nu, l, n] \
gives a list of the first n zeros of \
BesselJ'[nu, z] BesselY'[nu, l z] - BesselJ'[nu, l z] BesselY'[nu, z]. \
BesselJPrimeYPrimeJPrimeYPrimeZeros[nu, l, {m, n}] gives a list of \
the mth through the nth zeros."

BesselJPrimeYJYPrimeZeros::usage =
"BesselJPrimeYJYPrimeZeros[nu, l, n] \
gives a list of the first n zeros of \
BesselJ'[nu, z] BesselY[nu, l z] - BesselJ[nu, l z] BesselY'[nu, z]. \
BesselJPrimeYJYPrimeZeros[nu, l, {m, n}] gives a list of the mth \
through the nth zeros."

BesselJZerosInterval::usage =
"BesselJZerosInterval[nu, {zmin, zmax}] \
gives a list of the zeros of the order nu BesselJ function \
that lie in the interval zmin to zmax."

BesselYZerosInterval::usage =
"BesselYZerosInterval[nu, {zmin, zmax}] \
gives a list of the zeros of the order nu BesselY function \
that lie in the interval zmin to zmax."

BesselJPrimeZerosInterval::usage =
"BesselJPrimeZerosInterval[nu, {zmin, zmax}] \
gives a list of the zeros of the derivative of the order nu \
BesselJ function that lie in the interval zmin to zmax."

BesselYPrimeZerosInterval::usage =
"BesselYPrimeZerosInterval[nu, {zmin, zmax}] \
gives a list of the zeros of the derivative of the order nu \
BesselY function that lie in the interval zmin to zmax."

BesselJYJYZerosInterval::usage =
"BesselJYJYZerosInterval[nu, l, {zmin, zmax}] \
gives a list of the zeros of \
BesselJ[nu, z] BesselY[nu, l z] - BesselJ[nu, l z] BesselY[nu, z] \
that lie in the interval zmin to zmax."

BesselJPrimeYPrimeJPrimeYPrimeZerosInterval::usage =
"BesselJPrimeYPrimeJPrimeYPrimeZerosInterval[nu, l, {zmin, zmax}] \
gives a list of the zeros of \
BesselJ'[nu, z] BesselY'[nu, l z] - BesselJ'[nu, l z] BesselY'[nu, z] \
that lie in the interval zmin to zmax."

BesselJPrimeYJYPrimeZerosInterval::usage =
"BesselJPrimeYJYPrimeZerosInterval[nu, l, {zmin, zmax}] \
gives a list of the zeros of \
BesselJ'[nu, z] BesselY[nu, l z] - BesselJ[nu, l z] BesselY'[nu, z] \
that lie in the interval zmin to zmax."

Options[BesselJZeros] =
Options[BesselYZeros] =
Options[BesselJPrimeZeros] =
Options[BesselYPrimeZeros] =
Options[BesselJYJYZeros] =
Options[BesselJPrimeYPrimeJPrimeYPrimeZeros] =
Options[BesselJPrimeYJYPrimeZeros] =
Options[BesselJZerosInterval] =
Options[BesselYZerosInterval] =
Options[BesselJPrimeZerosInterval] =
Options[BesselYPrimeZerosInterval] =
Options[BesselJYJYZerosInterval] =
Options[BesselJPrimeYPrimeJPrimeYPrimeZerosInterval] =
Options[BesselJPrimeYJYPrimeZerosInterval] =
     {WorkingPrecision -> MachinePrecision, AccuracyGoal -> Automatic}


Begin["`Private`"]

issueObsoleteFunMessage[fun_, context_] :=
        (Message[fun::obspkgfn, fun, context];
         )

General::tma2 =
"Warning: AccuracyGoal -> `1` is not a valid value, or is \
larger than WorkingPrecision -> `2`, computation may not \
be able to achieve desired accuracy.";

x$fr;  (* variable to be used by FindRoot *)

(*
   vnl = ((TrueQ[NumberQ[#] && (# >= 0)])&   )
   Old validity test for nu and l, no longer used
*)

mu[nu_] := 4 nu^2;

(* using rational interpolation, predict the predecessor of
	the first element in x *)
pred[x_List] :=
Module[{b = InterpolatingPolynomial[Drop[x,1]-Drop[x,-1],x$fr] /. x$fr->0},
     If[x[[1]] <= 1.2 b,
         {x$fr, 0.000001, 0.3 x[[1]]},
         {x$fr, x[[1]] - 1.2 b, x[[1]] - 0.8 b}
     ]
]

(** for cases generalised to negative order, moved nu_?vnl to nu_?(Im[#]==0&) **)
(** also move the type check on all the zero number variables from
     Integer to Integer?Positive
**)
BesselJZeros[
     nu_?(Im[#]==0 && NumericQ[#]&),
     {m_Integer?Positive, n_Integer?Positive},
     opts___?OptionQ
] :=
(issueObsoleteFunMessage[BesselJZeros,"NumericalMath`BesselZeros`"];
	Module[{ans},
     ans /;
     (ans = bz[nu, m, n, BesselJZeros, opts]) =!= $Failed
]);

BesselJZeros[
     nu_?(Im[#]==0 && NumericQ[#]&),
     n_Integer?Positive,
     opts___?OptionQ
] :=
(issueObsoleteFunMessage[BesselJZeros,"NumericalMath`BesselZeros`"];
	Module[{ans},
     ans /;
     (ans = bz[nu, 1, n, BesselJZeros, opts]) =!= $Failed
]);

BesselYZeros[
     nu_?(Im[#]==0 && NumericQ[#]&),
     {m_Integer?Positive, n_Integer?Positive},
     opts___?OptionQ
] :=
(issueObsoleteFunMessage[BesselYZeros,"NumericalMath`BesselZeros`"];
	Module[{ans},
     ans /;
     (ans = bz[nu, m, n, BesselYZeros, opts]) =!= $Failed
]);

BesselYZeros[
     nu_?(Im[#]==0 && NumericQ[#]&),
     n_Integer?Positive,
     opts___?OptionQ
] :=
(issueObsoleteFunMessage[BesselYZeros,"NumericalMath`BesselZeros`"];
	Module[{ans},
     ans /;
     (ans = bz[nu, 1, n, BesselYZeros, opts]) =!= $Failed
]);

(** analytically continue back to order -1 **)
BesselJPrimeZeros[
     nu_?(Im[#] == 0 && #>=-1 && NumericQ[#]&),
     {m_Integer?Positive, n_Integer?Positive},
     opts___?OptionQ
] :=
(issueObsoleteFunMessage[BesselJPrimeZeros,"NumericalMath`BesselZeros`"];
	Module[{ans},
     ans /;
     (ans = bz[nu, m, n, BesselJPrimeZeros, opts]) =!= $Failed
]);

BesselJPrimeZeros[
     nu_?(Im[#] == 0 && #>=-1 && NumericQ[#]&),
     n_Integer?Positive,
     opts___?OptionQ
] :=
(issueObsoleteFunMessage[BesselJPrimeZeros,"NumericalMath`BesselZeros`"];
	Module[{ans},
     ans /;
     (ans = bz[nu, 1, n, BesselJPrimeZeros, opts]) =!= $Failed
]);

(** analtically continue back to order -1/2 **)
BesselYPrimeZeros[
     nu_?(Im[#] == 0 && #>=-1/2 && NumericQ[#]&),
     {m_Integer?Positive, n_Integer?Positive},
     opts___?OptionQ
] :=
(issueObsoleteFunMessage[BesselYPrimeZeros,"NumericalMath`BesselZeros`"];
	Module[{ans},
     ans /;
     (ans = bz[nu, m, n, BesselYPrimeZeros, opts]) =!= $Failed
]);

BesselYPrimeZeros[
     nu_?(Im[#] == 0 && #>=-1/2 && NumericQ[#]&),
     n_Integer?Positive,
     opts___?OptionQ
] :=
(issueObsoleteFunMessage[BesselYPrimeZeros,"NumericalMath`BesselZeros`"];
	Module[{ans},
     ans /;
     (ans = bz[nu, 1, n, BesselYPrimeZeros, opts]) =!= $Failed
]);

bz[nu_, m_, n_, f_, opts___] :=
     Module[{i, wp, ag, ff, his, xp, nn, d},
	wp = WorkingPrecision /. Flatten[{opts, Options[f]}];
	ag = AccuracyGoal /. Flatten[{opts, Options[f]}];
	If[ag === Automatic, ag = wp - 6];
	If[!TrueQ[0 < wp],
        Message[f::wprec, wp];
        Return[$Failed]
    ];
    If[!TrueQ[0 < ag <= wp],
        Message[f::tma2, ag, wp]
    ];
	ff = bzfunc[f, nu];
	d = 1;
	nn = n+1;
	While[!NumberQ[guess[f, nn, nu]], nn += Ceiling[d *= 1.2]];
	his = Table[xp = guess[f, i, nu];
		x$fr /. FindRoot[ff[x$fr], {x$fr, xp-0.02, xp+0.02},
			WorkingPrecision -> wp, AccuracyGoal -> ag,
			MaxIterations -> 35],
		{i, nn, nn+3}];
	If[!VectorQ[his, NumberQ], Return[$Failed]];
         While[!OrderedQ[his],
		nn += Ceiling[d *= 1.2];
		his = Table[xp = guess[f, i, nu];
			x$fr /. FindRoot[ff[x$fr], {x$fr, xp-0.02, xp+0.02},
				WorkingPrecision -> wp, AccuracyGoal -> ag,
				MaxIterations -> 35],
			{i, nn, nn+3}];
		If[!VectorQ[his, NumberQ], Return[$Failed]];
		];
	xp = Drop[his,1]-Drop[his,-1];
	While[Max[Abs[(Drop[xp,1]-Drop[xp,-1])/xp[[1]]]] > 0.25,
		nn += Ceiling[d *= 1.2];
		his = Table[xp = guess[f, i, nu];
			x$fr /. FindRoot[ff[x$fr], {x$fr, xp-0.02, xp+0.02},
				WorkingPrecision -> wp, AccuracyGoal -> ag,
				MaxIterations -> 35],
			{i, nn, nn+3}];
		If[!VectorQ[his, NumberQ], Return[$Failed]];
		xp = Drop[his,1]-Drop[his,-1]
		];
	Do[ xp = x$fr /. FindRoot[ff[x$fr], Evaluate[pred[his]],
				WorkingPrecision -> MachinePrecision,
				AccuracyGoal -> 6, MaxIterations -> 35];
	    If[!NumberQ[xp], Return[$Failed]];
	    his = RotateRight[his];
	    his[[1]] = xp, {nn-n-1}];
	Reverse[Table[
	    xp = x$fr /. FindRoot[ff[x$fr], Evaluate[pred[his]],
				WorkingPrecision -> wp, AccuracyGoal -> ag,
				MaxIterations -> 35];
	    If[!NumberQ[xp], Return[$Failed]];
	    his = RotateRight[his];
	    his[[1]] = xp;
	    xp, {n-m+1}]]
     ]

(** for cases generalised to negative order, moved nu_?vnl to nu_?(Im[#]==0&) **)
(** since all the cross product case are nu, -nu symmetric, use Abs[nu] **)
(** proven using 9.1.2 of Abramowitz and Stegun **)
BesselJYJYZeros[
     nu_?(Im[#]==0 && NumericQ[#]&),
     l_?(Positive[#] && NumericQ[#]&),
     {m_Integer?Positive, n_Integer?Positive},
     opts___?OptionQ
] :=
(issueObsoleteFunMessage[BesselJYJYZeros,"NumericalMath`BesselZeros`"];
	Module[{ans},
     ans /;
     (ans = bcz[Abs[nu], l, m, n, BesselJYJYZeros, opts]) =!= $Failed
]);

BesselJYJYZeros[
     nu_?(Im[#]==0 && NumericQ[#]&),
     l_?(Positive[#] && NumericQ[#]&),
     n_Integer?Positive,
     opts___?OptionQ
] :=
(issueObsoleteFunMessage[BesselJYJYZeros,"NumericalMath`BesselZeros`"];
	Module[{ans},
     ans /;
     (ans = bcz[Abs[nu], l, 1, n, BesselJYJYZeros, opts]) =!= $Failed
]);

BesselJPrimeYPrimeJPrimeYPrimeZeros[
     nu_?(Im[#]==0 && NumericQ[#]&),
     l_?(Positive[#] && NumericQ[#]&),
     {m_Integer?Positive, n_Integer?Positive},
     opts___?OptionQ
] :=
(issueObsoleteFunMessage[BesselJPrimeYPrimeJPrimeYPrimeZeros,"NumericalMath`BesselZeros`"];
	Module[{ans},
     ans /;
     (ans = bcz[Abs[nu], l, m, n, BesselJPrimeYPrimeJPrimeYPrimeZeros, 
opts]) =!= $Failed
]);

BesselJPrimeYPrimeJPrimeYPrimeZeros[
     nu_?(Im[#]==0 && NumericQ[#]&),
     l_?(Positive[#] && NumericQ[#]&),
     n_Integer?Positive,
     opts___?OptionQ
] :=
(issueObsoleteFunMessage[BesselJPrimeYPrimeJPrimeYPrimeZeros,"NumericalMath`BesselZeros`"];
	Module[{ans},
     ans /;
     (ans = bcz[Abs[nu], l, 1, n, BesselJPrimeYPrimeJPrimeYPrimeZeros, 
opts]) =!= $Failed
]);

BesselJPrimeYJYPrimeZeros[
     nu_?(Im[#]==0 && NumericQ[#]&),
     l_?(Positive[#] && NumericQ[#]&),
     {m_Integer?Positive, n_Integer?Positive},
     opts___?OptionQ
] :=
(issueObsoleteFunMessage[BesselJPrimeYJYPrimeZeros,"NumericalMath`BesselZeros`"];
	Module[{ans},
     ans /;
     (ans = bcz[Abs[nu], l, m, n, BesselJPrimeYJYPrimeZeros, opts]) =!= $Failed
]);

BesselJPrimeYJYPrimeZeros[
     nu_?(Im[#]==0 && NumericQ[#]&),
     l_?(Positive[#] && NumericQ[#]&),
     n_Integer?Positive,
     opts___?OptionQ
] :=
(issueObsoleteFunMessage[BesselJPrimeYJYPrimeZeros,"NumericalMath`BesselZeros`"];
	Module[{ans},
     ans /;
     (ans = bcz[Abs[nu], l, 1, n, BesselJPrimeYJYPrimeZeros, opts]) =!= $Failed
]);

bcz[nu_, l_, m_, n_, f_, opts___] :=
     Module[{i, wp, ag, ff, his, xp, nn, d},
	wp = WorkingPrecision /. Flatten[{opts, Options[f]}];
	ag = AccuracyGoal /. Flatten[{opts, Options[f]}];
	If[ag === Automatic, ag = wp - 6];

         (* take care of degenerate lambda = 1 case *)
         If[
             l == 1,
             Which[
                 f === BesselJYJYZeros,                     Return[ {{}} ],
                 f === BesselJPrimeYPrimeJPrimeYPrimeZeros, Return[ {{}} ],
                 f === BesselJPrimeYJYPrimeZeros,           Return[ {} ]
             ]
         ];

	If[!TrueQ[0 < wp],
        Message[f::wprec, wp];
        Return[$Failed]
    ];
    If[!TrueQ[0 < ag <= wp],
        Message[f::tma2, ag, wp]
    ];

	ff = bczfunc[f, nu, l];
	d = 1;
	nn = n+1;
	While[!NumberQ[cguess[f, nn, nu, l]], nn += Ceiling[d *= 1.2]];
	his = Table[xp = cguess[f, i, nu, l];
		x$fr /. FindRoot[ff[x$fr], {x$fr, xp-0.02, xp+0.02},
			WorkingPrecision -> wp, AccuracyGoal -> ag,
			MaxIterations -> 35],
		{i, nn, nn+3}];
	If[!VectorQ[his, NumberQ], Return[$Failed]];
	While[!OrderedQ[his],
		nn += Ceiling[d *= 1.2];
		his = Table[xp = cguess[f, i, nu, l];
			x$fr /. FindRoot[ff[x$fr], {x$fr, xp-0.02, xp+0.02},
				WorkingPrecision -> wp, AccuracyGoal -> ag,
				MaxIterations -> 35],
			{i, nn, nn+3}];
		If[!VectorQ[his, NumberQ], Return[$Failed]];
		];
	xp = Drop[his,1]-Drop[his,-1];
	While[Max[Abs[(Drop[xp,1]-Drop[xp,-1])/xp[[1]]]] > 0.25,
		nn += Ceiling[d *= 1.2];
		his = Table[xp = cguess[f, i, nu, l];
			x$fr /. FindRoot[ff[x$fr], {x$fr, xp-0.02, xp+0.02},
				WorkingPrecision -> wp, AccuracyGoal -> ag,
				MaxIterations -> 35],
			{i, nn, nn+3}];
		If[!VectorQ[his, NumberQ], Return[$Failed]];
		xp = Drop[his,1]-Drop[his,-1]
		];
	Do[ xp = x$fr /. FindRoot[ff[x$fr], Evaluate[pred[his]],
				WorkingPrecision -> MachinePrecision,
				AccuracyGoal -> 6, MaxIterations -> 35];
	    If[!NumberQ[xp], Return[$Failed]];
	    his = RotateRight[his];
	    his[[1]] = xp, {nn-n-1}];
	Reverse[Table[
	    xp = x$fr /. FindRoot[ff[x$fr], Evaluate[pred[his]],
				WorkingPrecision -> wp, AccuracyGoal -> ag,
				MaxIterations -> 35];
	    If[!NumberQ[xp], Return[$Failed]];
	    his = RotateRight[his];
	    his[[1]] = xp;
	    xp, {n-m+1}]]
     ]

(* -------------------- J, Y, JPrime YPrime --------------------------- *)

beta[BesselJZeros, s_, nu_?Positive] := N[Pi] (s + nu/2 - 0.25);
(** analytic continuation to -ve nu **)
beta[BesselJZeros, s_, nu_] := N[Pi] (s - Ceiling[nu] + nu/2 - 0.25);

beta[BesselYZeros, s_, nu_?Positive] := N[Pi] (s + nu/2 - 0.75);
(** analytic continuation to -ve nu **)
beta[BesselYZeros, s_, nu_] := N[Pi] (s - Round[nu] + nu/2 - 0.75);


beta[BesselJPrimeZeros, s_, nu_?Positive] := N[Pi] (s + nu/2 - 0.75);
(** analytically continue to nu >= -1 **)
beta[BesselJPrimeZeros, s_, nu_?(#>=-1&)] := N[Pi] (s + 1 + nu/2 - 0.75);
(** analytically continue to nu >= -1/2 **)
beta[BesselYPrimeZeros, s_, nu_?(#>=-1/2&)] := N[Pi] (s + nu/2 - 0.25);

guess[BesselJZeros, s_, nu_] := guess1[BesselJZeros, s, nu];
guess[BesselYZeros, s_, nu_] := guess1[BesselYZeros, s, nu];
guess[BesselJPrimeZeros, s_, nu_] := guess2[BesselJPrimeZeros, s, nu];
guess[BesselYPrimeZeros, s_, nu_] := guess2[BesselYPrimeZeros, s, nu];

guess1[f_, s_, nu_] :=		(* A&S 9.5.12 *)
     Module[{b = beta[f, s, nu], m = mu[nu], z},
	z = 64(m-1)(6949m^3-153855m^2+1585743m-6277237)/(105 (8b)^7);
	If[Abs[z] > 1/4, Return[$Failed]];
	z += 32(m-1)(83m^2-982m+3779)/(15 (8b)^5);
	z += (m-1)/(8b) + 4(m-1)(7m-31)/(3 (8b)^3);
	b-z
	]

guess2[f_, s_, nu_] :=		(* A&S 9.5.13 *)
     Module[{b = beta[f, s, nu], m = mu[nu], z},
	z = 64(6949m^4+296492m^3-1248002m^2+7414380m-5853627)/(105 (8b)^7);
	If[Abs[z] > 1/4, Return[$Failed]];
	z += 32(83m^3+2075m^2-3039m+3537)/(15 (8b)^5);
	z += (m+3)/(8b) + 4(7m^2+82m-9)/(3 (8b)^3);
	b-z
	]


bzfunc[BesselJZeros, nu_] := BesselJ[nu, #]&
bzfunc[BesselYZeros, nu_] := BesselY[nu, #]&
bzfunc[BesselJPrimeZeros, nu_] := (Evaluate[Derivative[0,1][BesselJ][nu, #]])&
bzfunc[BesselYPrimeZeros, nu_] := (Evaluate[Derivative[0,1][BesselY][nu, #]])&

(* -------------------- cross products --------------------------- *)

cguess[BesselJYJYZeros, s_, nu_, l_] := guess3[s, nu, l];
cguess[BesselJPrimeYPrimeJPrimeYPrimeZeros, s_, nu_, l_] := guess4[s, nu, l];
cguess[BesselJPrimeYJYPrimeZeros, s_, nu_, l_] := guess5[s, nu, l];

guess3[s_, nu_, ll_] :=		(* A&S 9.5.28 *)
     Module[{b, m = mu[nu], z, p, q, r, l},
	l = If[ll > 1, ll, 1/ll];
	b = N[Pi] s/(l-1);
	p = (m-1)/(8l);
	q = (m-1)(m-25)(l^3-1)/(6 (4l)^3 (l-1));
	r = (m-1)(m^2-114m+1073)(l^5-1)/(5 (4l)^5 (l-1));
	p = 1/(l-1);
	z = (r - 4 p q + 2 p^3)/b^5;
	If[Abs[z] > p/4, Return[$Failed]];
	z = b + p/b + (q - p^2)/b^3 + z;
	If[ll < 1, z *= l];
	z
     ]

guess4[s_, nu_, ll_] :=		(* A&S 9.5.31 *)
     Module[{b, m = mu[nu], z, p, q, r, l},
	l = If[ll > 1, ll, 1/ll];
	b = N[Pi] If[TrueQ[nu == 0], s, (s-1)]/(l-1);
	p = (m+3)/(8l);
	q = (m^2+46m-63)(l^3-1)/(6 (4l)^3 (l-1));
	r = (m^3+185m^2-2053m+1899)(l^5-1)/(5 (4l)^5 (l-1));
	p = 1/(l-1);
	z = (r - 4 p q + 2 p^3)/b^5;
	If[Abs[z] > p/4, Return[$Failed]];
		z = b + p/b + (q - p^2)/b^3 + z;
	If[ll < 1, z *= l];
	z
     ]

guess5[s_, nu_, ll_] :=		(* A&S 9.5.33 *)
     Module[{b, m = mu[nu], z, p, q, r, l},
	l = If[ll > 1, ll, 1/ll];
	b = N[Pi] (s-1/2)/(l-1);
	p = ((m+3)l-(m-1))/(8l (l-1));
	q = ((m^2+46m-63)l^3-(m-1)(m-25))/(6 (4l)^3 (l-1));
	r = ((m^3+185m^2-2053m+1899)l^5-(m-1)(m^2-114m+1073))/(5 (4l)^5 (l-1));
	p = 1/(l-1);
	z = (r - 4 p q + 2 p^3)/b^5;
	If[Abs[z] > p/4, Return[$Failed]];
	z = b + p/b + (q - p^2)/b^3 + z;
	If[ll < 1, z *= l];
	z
     ]

bczfunc[BesselJYJYZeros, nu_, l_] :=
	(BesselJ[nu, #] BesselY[nu, l #] - BesselJ[nu, l #] BesselY[nu, #])&

bczfunc[BesselJPrimeYPrimeJPrimeYPrimeZeros, nu_, l_] := (Evaluate[
	(Derivative[0,1][BesselJ][nu, #] Derivative[0,1][BesselY][nu, l #] -
	Derivative[0,1][BesselJ][nu, l #] Derivative[0,1][BesselY][nu, #])])&

bczfunc[BesselJPrimeYJYPrimeZeros, nu_, l_] := (Evaluate[
	(Derivative[0,1][BesselJ][nu, #] BesselY[nu, l #] -
	BesselJ[nu, l #] Derivative[0,1][BesselY][nu, #])])&


BesselJZerosInterval[
     nu_?(Im[#]==0 && NumericQ[#]&),
     {x1_?(Positive[#] && NumericQ[#]&), x2_?(Positive[#] && NumericQ[#]&)},
     opts___?OptionQ
] :=
(issueObsoleteFunMessage[BesselJZerosInterval,"NumericalMath`BesselZeros`"];
	Module[{ans},
     ans /;
     (ans = besselZerosInterval[nu, {x1,x2}, BesselJZeros, opts]) =!= $Failed
]);

BesselJZerosInterval[
     nu_?(Im[#]==0 && NumericQ[#]&),
     Interval[l:({_?(Positive[#] && NumericQ[#]&), _?(Positive[#] && NumericQ[#]&)}..)],
     opts___?OptionQ
] :=
  Flatten[Map[BesselJZerosInterval[nu, #, opts]&, {l}],1]

BesselYZerosInterval[
     nu_?(Im[#]==0 && NumericQ[#]&),
     {x1_?(Positive[#] && NumericQ[#]&), x2_?(Positive[#] && NumericQ[#]&)},
     opts___?OptionQ
] :=
(issueObsoleteFunMessage[BesselYZerosInterval,"NumericalMath`BesselZeros`"];
	Module[{ans},
     ans /;
     (ans = besselZerosInterval[nu, {x1,x2}, BesselYZeros, opts]) =!= $Failed
]);

BesselYZerosInterval[
     nu_?(Im[#]==0 && NumericQ[#]&),
     Interval[l:({_?(Positive[#] && NumericQ[#]&), _?(Positive[#] && NumericQ[#]&)}..)],
     opts___?OptionQ
] :=
  Flatten[Map[BesselYZerosInterval[nu, #, opts]&, {l}],1]

BesselJPrimeZerosInterval[
     nu_?(#>=-1 && NumericQ[#]&),
     {x1_?(Positive[#] && NumericQ[#]&), x2_?(Positive[#] && NumericQ[#]&)},
     opts___?OptionQ
] :=
(issueObsoleteFunMessage[BesselJPrimeZerosInterval,"NumericalMath`BesselZeros`"];
	Module[{ans},
     ans /;
     (ans = besselZerosInterval[nu, {x1,x2}, BesselJPrimeZeros, opts]) =!= $Failed
]);

BesselJPrimeZerosInterval[
     nu_?(#>=-1 && NumericQ[#]&),
     Interval[l:({_?(Positive[#] && NumericQ[#]&), _?(Positive[#] && NumericQ[#]&)}..)],
     opts___?OptionQ
] :=
  Flatten[Map[BesselJPrimeZerosInterval[nu, #, opts]&, {l}],1]

BesselYPrimeZerosInterval[
     nu_?(#>=-1/2 && NumericQ[#]&),
     {x1_?(Positive[#] && NumericQ[#]&), x2_?(Positive[#] && NumericQ[#]&)},
     opts___?OptionQ
] :=
(issueObsoleteFunMessage[BesselYPrimeZerosInterval,"NumericalMath`BesselZeros`"];
	Module[{ans},
     ans /;
     (ans = besselZerosInterval[nu, {x1,x2}, BesselYPrimeZeros, opts]) =!= $Failed
]);

BesselYPrimeZerosInterval[
     nu_?(#>=-1/2 && NumericQ[#]&),
     Interval[l:({_?(Positive[#] && NumericQ[#]&), _?(Positive[#] && NumericQ[#]&)}..)],
     opts___?OptionQ
] :=
  Flatten[Map[BesselYPrimeZerosInterval[nu, #, opts]&, {l}],1]

BesselJYJYZerosInterval[
     nu_?(Im[#]==0 && NumericQ[#]&),
     lambda_?(Positive[#] && NumericQ[#]&),
     {x1_?(Positive[#] && NumericQ[#]&), x2_?(Positive[#] && NumericQ[#]&)},
     opts___?OptionQ
] :=
(issueObsoleteFunMessage[BesselJYJYZerosInterval,"NumericalMath`BesselZeros`"];
	Module[{ans},
     ans /;
     (ans = besselZerosInterval[nu, lambda, {x1,x2}, BesselJYJYZeros, opts]) =!=
$Failed
]);

BesselJYJYZerosInterval[
     nu_?(Im[#]==0 && NumericQ[#]&),
     lambda_?(Positive[#] && NumericQ[#]&),
     Interval[l:({_?(Positive[#] && NumericQ[#]&), _?(Positive[#] && NumericQ[#]&)}..)],
     opts___?OptionQ
] :=
  Flatten[Map[BesselJYJYZerosInterval[nu, lambda, #, opts]&, {l}],1]

BesselJPrimeYPrimeJPrimeYPrimeZerosInterval[
     nu_?(Im[#]==0 && NumericQ[#]&),
     lambda_?(Positive[#] && NumericQ[#]&),
     {x1_?(Positive[#] && NumericQ[#]&), x2_?(Positive[#] && NumericQ[#]&)},
     opts___?OptionQ
] :=
(issueObsoleteFunMessage[BesselJPrimeYPrimeJPrimeYPrimeZerosInterval,"NumericalMath`BesselZeros`"];
	Module[{ans},
     ans /;
     (ans = besselZerosInterval[nu, lambda, {x1,x2},
BesselJPrimeYPrimeJPrimeYPrimeZeros, opts]) =!= $Failed
]);

BesselJPrimeYPrimeJPrimeYPrimeZerosInterval[
     nu_?(Im[#]==0 && NumericQ[#]&),
     lambda_?(Positive[#] && NumericQ[#]&),
     Interval[l:({_?(Positive[#] && NumericQ[#]&), _?(Positive[#] && NumericQ[#]&)}..)],
     opts___?OptionQ
] :=
  Flatten[Map[BesselJPrimeYPrimeJPrimeYPrimeZerosInterval[nu, lambda, #, opts]&, {l}],1]

BesselJPrimeYJYPrimeZerosInterval[
     nu_?(Im[#]==0 && NumericQ[#]&),
     lambda_?(Positive[#] && NumericQ[#]&),
     {x1_?(Positive[#] && NumericQ[#]&), x2_?(Positive[#] && NumericQ[#]&)},
     opts___?OptionQ
] :=
(issueObsoleteFunMessage[BesselJPrimeYJYPrimeZerosInterval,"NumericalMath`BesselZeros`"];
	Module[{ans},
     ans /;
     (ans = besselZerosInterval[nu, lambda, {x1,x2}, BesselJPrimeYJYPrimeZeros,
opts]) =!= $Failed
]);

BesselJPrimeYJYPrimeZerosInterval[
     nu_?(Im[#]==0 && NumericQ[#]&),
     lambda_?(Positive[#] && NumericQ[#]&),
     Interval[l:({_?(Positive[#] && NumericQ[#]&), _?(Positive[#] && NumericQ[#]&)}..)],
     opts___?OptionQ
] :=
  Flatten[Map[BesselJPrimeYJYPrimeZerosInterval[nu, lambda, #, opts]&, {l}],1]

(*
   The bisection routine for locating the root pair that
   stradles the point x.
   The use of an explicity If statement was retained
   in the interests of readability.
*)
boundingPair[{n1_, n2_},
              nu_,
              lambda_:Automatic,
              x_,
              function_,
              options_?OptionQ] :=
Block[{bisector, m1, m2, left, right},
     {m1, m2} = {n1, n2};
     bisector = Round[(m1 + m2)/2];

     {left, right} = If[ lambda === Automatic,
                         function[nu, {bisector, bisector+1}, options],
                         function[nu, lambda, {bisector, bisector+1}, options]
                     ];

     While[
         !(left <= x && right >= x)
         ,
         Which[
             left  > x, m2 = bisector - 1
             ,
             right < x, m1 = bisector + 1
         ];
         bisector = Round[(m1 + m2)/2];
         If[ bisector == 0, Break[] ];
         {left, right} = If[ lambda === Automatic,
                             function[nu, {bisector, bisector+1}, options],
                             function[nu, lambda, {bisector, 
bisector+1}, options]
                         ];
     ];

     Return[{bisector, bisector+1}];

]


besselZerosInterval[nu_, {x1_, x2_}, function_, opts___] :=
Module[{ options, n1, n2, n1final, n2final },

     options = Flatten[ {opts, Options[function]} ];

     (* check if the first root is beyond the range, or if the range is empty*)
     If[
         (First[ function[nu, {1,1}, options ] ] > x2) || (x2 < x1)
         ,
         Return[{}]
     ];

     (*find bounding enumerations*)
     n1 = 1;
     n2 = Ceiling[x2/Pi];

     (*use the bisection method to refine n1 and n2*)
     n2final = First[ boundingPair[{n1, n2}, nu, x2, function, options ] ];
     n1final = Last[ boundingPair[{n1, n2final}, nu, x1, function, options ] ];

     Return[
         function[nu, {n1final, n2final}, options]
     ];

]

besselZerosInterval[nu_, lambda_, {x1_, x2_}, function_, opts___] :=
Module[{options, n1, n2, n1final, n2final},

     options = Flatten[ {opts, Options[function]} ];

     (* take care of degenerate lambda = 1 case *)
     If[
         lambda == 1,
         Which[
             function === BesselJYJYZeros,                     Return[ {{}} ],
             function === BesselJPrimeYPrimeJPrimeYPrimeZeros, Return[ {{}} ],
             function === BesselJPrimeYJYPrimeZeros,           Return[ {} ]
         ]
     ];

     (* check if the first root is beyond the range, or if the range is empty*)
     If[
         (First[ function[nu, lambda, {1,1}, options ] ] > x2) || (x2 < x1)
         ,
         Return[{}]
     ];

     (*find bounding enumerations*)
     n1 = 1;
     n2 = Ceiling[ lambda x2/Pi ];

     (*use the bisection method to refine n1 and n2*)
     n2final = First[ boundingPair[{n1, n2}, nu, lambda, x2, function, 
options ] ];
     n1final = Last[ boundingPair[{n1, n2final}, nu, lambda, x1, 
function, options ]
];

     Return[
         function[nu, lambda, {n1final, n2final}, options]
     ];

]

End[ ] (* NumericalMath`BesselZeros`Private` *)

SetAttributes[
     {
     BesselJZeros,
     BesselYZeros,
     BesselJPrimeZeros,
     BesselYPrimeZeros,
     BesselJYJYZeros,
     BesselJPrimeYPrimeJPrimeYPrimeZeros,
     BesselJPrimeYJYPrimeZeros,
     BesselJZerosInterval,
     BesselYZerosInterval,
     BesselJPrimeZerosInterval,
     BesselYPrimeZerosInterval,
     BesselJYJYZerosInterval,
     BesselJPrimeYPrimeJPrimeYPrimeZerosInterval,
     BesselJPrimeYJYPrimeZerosInterval
     }
     ,
     {Protected, ReadProtected}
]


EndPackage[] (* NumericalMath`BesselZeros` *)

(* :Tests:
BesselJ[1, #]& /@ BesselJZeros[1, 3]
BesselY[2, #]& /@ BesselYZeros[2, 4]
(Evaluate[Derivative[0,1][BesselJ][3, #]])& /@ BesselJPrimeZeros[3, 4]
(Evaluate[Derivative[0,1][BesselY][3, #]])& /@ BesselYPrimeZeros[3, 4]
(BesselJ[1, #] BesselY[1, 2 #] - BesselJ[1, 2 #] BesselY[1, #])& /@
	BesselJYJYZeros[1, 2, 3]
Evaluate[Derivative[0,1][BesselJ][1,#] Derivative[0,1][BesselY][1,2#] -
	Derivative[0,1][BesselJ][1,2#] Derivative[0,1][BesselY][1,#]]& /@
	BesselJPrimeYPrimeJPrimeYPrimeZeros[1, 2, 3]
Evaluate[Derivative[0,1][BesselJ][2,#] BesselY[2, 11/10 #] -
	BesselJ[2, 11/10 #] Derivative[0,1][BesselY][2,#]]& /@
	BesselJPrimeYJYPrimeZeros[2, 11/10, 3,
		WorkingPrecision -> 30, AccuracyGoal -> 20]
Evaluate[Derivative[0,1][BesselJ][2,#] BesselY[2, 1/10 #] -
	BesselJ[2, 1/10 #] Derivative[0,1][BesselY][2,#]]& /@
	BesselJPrimeYJYPrimeZeros[2, 1/10, 3]
(BesselJ[1, #] BesselY[1, 1/2 #] - BesselJ[1, 1/2 #] BesselY[1, #])& /@
	BesselJYJYZeros[1, 1/2, 3]
(BesselJ[1, #] BesselY[1, 9/10 #] - BesselJ[1, 9/10 #] BesselY[1, #])& /@
	BesselJYJYZeros[1, 9/10, 3]
Evaluate[Derivative[0,1][BesselJ][1,#] Derivative[0,1][BesselY][1,#/2] -
	Derivative[0,1][BesselJ][1,#/2] Derivative[0,1][BesselY][1,#]]& /@
	BesselJPrimeYPrimeJPrimeYPrimeZeros[1, 1/2, 3]

BesselJ[1, #]& /@ BesselJZeros[1, {3, 5}]
BesselY[2, #]& /@ BesselYZeros[2, {4, 6}]
(Evaluate[Derivative[0,1][BesselJ][3, #]])& /@ BesselJPrimeZeros[3, {2, 4}]
(Evaluate[Derivative[0,1][BesselY][3, #]])& /@ BesselYPrimeZeros[3, {2, 4}]
(BesselJ[1, #] BesselY[1, 2 #] - BesselJ[1, 2 #] BesselY[1, #])& /@
	BesselJYJYZeros[1, 2, {3, 5}]
Evaluate[Derivative[0,1][BesselJ][1,#] Derivative[0,1][BesselY][1,2#] -
	Derivative[0,1][BesselJ][1,2#] Derivative[0,1][BesselY][1,#]]& /@
	BesselJPrimeYPrimeJPrimeYPrimeZeros[1, 2, {2, 3}]
Evaluate[Derivative[0,1][BesselJ][2,#] BesselY[2, 11/10 #] -
	BesselJ[2, 11/10 #] Derivative[0,1][BesselY][2,#]]& /@
	BesselJPrimeYJYPrimeZeros[2, 11/10, {707, 709}]
*)

