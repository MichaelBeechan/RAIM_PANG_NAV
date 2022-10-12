function [Xecef,Yecef,Zecef]=enu2ecef(Xenu,Yenu,Zenu,latitudine,longitudine,quota,MODE)
%
%enu2ecef.m transforms ENU coordinates in ECEF, given the ENU origin
%
%in input:
%         - "Xenu","Yenu","Zenu" ENU coordinates [meter]
%         - "latitudine","longitudine","quota" geodetic coordinates of ENU origin [rad,rad,meter]
%         - "MODE" mode of use flag: 
%           'pos' for position vector transformation (rotation and translation), 
%           'vel' for velocity or acceleration vector transformation (only rotation)
%
%in output:
%         - "Xecef","Yecef","Zecef" ECEF coordinates [meter]
%
%note: Xenu,Yenu,Zenu can be matrix with same size
%      latitudine,longitudine,quota are scalar
%
%functions called: 
%         - makeitcol.m
%         - matrix_rot.m
%         - geo2ecef.m
%
%version 0.001 2013/07/30


%Xecef,Yecef,Zecef must be row for non scalar input
Xenu=(makeitcol(Xenu))';
Yenu=(makeitcol(Yenu))';
Zenu=(makeitcol(Zenu))';

%prima matrice di rotazione
R1=matrix_rot(pi/2+longitudine,'A','z');

%seconda matrice di rotazione
R2=matrix_rot(pi/2-latitudine,'A','x');

R=R1*R2;

%conversion Geodetic coordinates fi,lam,q to ECEF
[Xo,Yo,Zo]=geo2ecef(latitudine,longitudine,quota);

if strcmp(MODE,'pos')
    
   %
   [XYZecef]=[Xo;Yo;Zo]+R*[Xenu;Yenu;Zenu];
   Xecef=XYZecef(1,:);
   Yecef=XYZecef(2,:);
   Zecef=XYZecef(3,:);

elseif strcmp(MODE,'vel')
   
   %
   [XYZecef]=R*[Xenu;Yenu;Zenu];
   Xecef=XYZecef(1,:);
   Yecef=XYZecef(2,:);
   Zecef=XYZecef(3,:);
    
end

Xecef=Xecef';
Yecef=Yecef';
Zecef=Zecef';
