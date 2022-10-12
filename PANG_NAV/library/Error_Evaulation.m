function [Max,Mean,Rms] = Error_Evaulation( error )
%
%Error_Evaulation.m computes maximum, mean and RMS of a vector components 
%
%in input:
%         - "error" vector 
%
%in output:
%         - "Max" maximum value of vector components in input
%         - "Mean" mean value of vector components in input
%         - "Rms" Root Mean Square value of vector components in input
%
%note: 
%
%function called:
%         - RMS.m
%
%version 0.001 2013/08/29

Max=max(abs(error));
Mean=Mean0(error); %nanmean(error);
Rms=RMS(error);