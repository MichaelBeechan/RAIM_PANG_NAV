function [tsv_corr,dtsv_corr]=sv_clock_corr_GPS(Af0,Af1,Af2,toc,t_raw)
%
%sv_clock_corr_GPS computes satellite clock bias and drift, using the parameters
%broadcast in the Navigation Message
%
%in input:
%         - "Af0","Af1","Af2" correction parameters [sec,sec/sec,sec/sec^2]
%         - "toc" corrections reference epoch 
%         - "t_raw" epoch when bias and drift are desired 
%in output:
%         - "tsv_corr" satellite clock bias [sec]
%         - "dtsv_corr" satellite clock drift [sec]
%
%note:
%the corrections are subtractive         
%
%functions called:
%         - check_t
%
%
%version 0.001 2013/08/01


dt=check_t(t_raw-toc);
tsv_corr=Af0+Af1.*(dt)+Af2.*(dt).^2;
dtsv_corr=Af1+2*Af2.*(dt);