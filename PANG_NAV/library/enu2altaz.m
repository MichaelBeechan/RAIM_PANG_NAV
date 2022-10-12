function [h,az] = enu2altaz(Xenu,Yenu,Zenu)
%
% enu2altaz computes elevation and azimuth angles from ENU coordinates
%
%in input:
%         - "Xenu","Yenu","Zenu" ENU coordinates [meter]
%
%in output:
%         - "h" elevation [radians]
%         - "az" azimuth [radians]
%
%
%version 0.002 2017/01/18



% calcolo distanza osservatore-satellite
Renu=sqrt(Xenu.^2+Yenu.^2+Zenu.^2);

% altezza
h=asin(Zenu./Renu);
% angolo azimutale [-180°,180°]
az=atan2(Xenu,Yenu); 

% azimut [0°,360°]
az(az<0)=2*pi+az(az<0); %