(* ::Package:: *)

BeginPackage["TestPackage`"];
f::usage = "My function";

Begin["`Private`"]
    Mesg := Print["Private function of TestPackage"];
    f[x_] := Module[{a = 3, b = 3}, Mesg; a x^b];
End[]

EndPackage[]



