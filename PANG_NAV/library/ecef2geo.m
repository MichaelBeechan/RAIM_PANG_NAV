function [Latitudine,Longitudine,QuotaE]=ecef2geo(Xecef,Yecef,Zecef)
%
% la function ecef2geografiche converte coordinate ECEF in coordinate geografiche:
% latitudine, longitudine e altezza ellissoidica, riferite all'ellissoide
% WGS84 utilizzando le formule di B.R.Bowring
%
% input in metri
% è consentito l'utilizzo di input/output vettoriali o matriciali
%
% output in radianti e metri


format long
% definizione elementi ellissoide WGS84
a=6378137; %in m
f=1/298.257222101;
e=sqrt(2*f-f^2);
b=a*(1-f);
e_sec=sqrt((a^2-b^2)/(b^2));
% formule di Bowring
Longitudine=atan2(Yecef,Xecef);
% sin_lat_ridotta=Zecef./b;
r=sqrt(Xecef.^2+Yecef.^2);
lat_ridotta=(atan2(Zecef,(1-f)*r));
% cos_lat_ridotta=r/a;
Latitudine=atan((Zecef+e_sec^2*b*(sin(lat_ridotta).^3))./(r-e^2*a*(cos(lat_ridotta).^3)));
QuotaE=r.*cos(Latitudine)+Zecef.*sin(Latitudine)-a*sqrt(1-e^2*(sin(Latitudine)).^2);
