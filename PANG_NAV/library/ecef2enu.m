function [Xenu,Yenu,Zenu]=ecef2enu(Xecef,Yecef,Zecef,latitudine,longitudine,quota,MODE)
%
%ecef2enu transforms ECEF coordinates in ENU, given the origin
%
%in input:
%         - "Xecef","Yecef","Zecef" ECEF coordinates [meter]
%         - "latitudine","longitudine","quota" geodetic coordinates of ENU origin [rad,rad,meter]
%         - "MODE" mode of use flag: 
%           'pos' for position vector transformation (rotation and translation), 
%           'vel' for velocity or acceleration vector transformation (only rotation)
%
%in output:
%         - "Xenu","Yenu","Zenu" ENU coordinates [meter]
%
%note: Xecef,Yecef,Zecef can be matrix with same size
%      latitudine,longitudine,quota are scalar
%
%functions called: 
%         - makeitcol.m
%         - matrix_rot.m
%         - geo2ecef.m
%
%version 0.001 2013/07/30


%Xecef,Yecef,Zecef must be row for non scalar input
Xecef=(makeitcol(Xecef))';
Yecef=(makeitcol(Yecef))';
Zecef=(makeitcol(Zecef))';

%prima matrice di rotazione
R1=matrix_rot(pi/2+longitudine,'A','z');

%seconda matrice di rotazione
R2=matrix_rot(pi/2-latitudine,'A','x');

R=R2*R1;

%conversion Geodetic coordinates fi,lam,q to ECEF
[Xo,Yo,Zo]=geo2ecef(latitudine,longitudine,quota);

if strcmp(MODE,'pos')
    
   %
   [XYZenu]=R*[Xecef-Xo;Yecef-Yo;Zecef-Zo];
   Xenu=XYZenu(1,:);
   Yenu=XYZenu(2,:);
   Zenu=XYZenu(3,:);

elseif strcmp(MODE,'vel')
   
   %
   [XYZenu]=R*[Xecef;Yecef;Zecef];
   Xenu=XYZenu(1,:);
   Yenu=XYZenu(2,:);
   Zenu=XYZenu(3,:);
    
end

Xenu=Xenu';
Yenu=Yenu';
Zenu=Zenu';
