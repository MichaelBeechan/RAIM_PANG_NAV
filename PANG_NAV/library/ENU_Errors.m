function [e_H,e_U,Error_Table] = ENU_Errors( E,N,U, E_true,N_true,U_true )

%ENU_Errors computes ENU errors and error table
%
%
%in input:
%         - "E","N","U" estimated UTM coordinates (meters)
%         - "E_true","N_true","U_true"  true UTM coordinates (meters)
%
%in output:
%         - "e_H" mx1 horizontal error (m)
%         - "e_U" mx1 vertical error (m)
%         - "Error_Table" table of errors [mean Hor,mean Up, RMS Hor,RMS Up,max Hor,max Up]
%
%function called:
%         - makeitcol.m
%         - Error_Evaulation.m
%
%version 0.001 2014/08/28

E=makeitcol(E);
N=makeitcol(N);
U=makeitcol(U);
E_true=makeitcol(E_true);
N_true=makeitcol(N_true);
U_true=makeitcol(U_true);

e_E=E_true-E;
e_N=N_true-N;
e_U=U_true-U;
e_H=sqrt(e_E.^2+e_N.^2);
%e_3D=sqrt(e_E.^2+e_N.^2+e_U.^2);

%[e_E_Max,e_E_Mean,e_E_RMS] = Error_Evaulation(e_E);
%[e_N_Max,e_N_Mean,e_N_RMS] = Error_Evaulation(e_N);
[e_U_Max,e_U_Mean,e_U_RMS] = Error_Evaulation(e_U);
[e_H_Max,e_H_Mean,e_H_RMS] = Error_Evaulation(e_H);
%[e_3D_Max,e_3D_Mean,e_3D_RMS] = Error_Evaulation(e_3D);

e_U=abs(e_U);

Error_Table=[e_H_Mean,e_U_Mean,e_H_RMS,e_U_RMS,e_H_Max,e_U_Max];