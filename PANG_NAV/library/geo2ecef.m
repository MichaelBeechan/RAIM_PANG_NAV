function [Xo,Yo,Zo]=geo2ecef(lat,long,h)
%
%GEO2ECEF function computes ECEF coordinates starting by geodetic
%
%in input:
%         - "lat","long","h" geodetic coordinates latitude,longitude,altitude [rad,rad,m]
%
%in output:
%         - "Xo","Yo","Zo" ECEF coordinates [m]
%
%note: the function works only with WGS84 reference
%
%called functions: 
%         - calcN
%
%version 0.001 2013/08/27

%WGS84 parameters
%a=6378137; %semi-major axis (m)
f=1/298.257222101; %flatness
ecc=sqrt(2*f-f^2); %eccentricity

%prime vertical radius computation
N = calcN(lat);

Xo=(N+h)*cos(long)*cos(lat);

Yo=(N+h)*sin(long)*cos(lat);

Zo=(N*(1-ecc^2)+h)*sin(lat);