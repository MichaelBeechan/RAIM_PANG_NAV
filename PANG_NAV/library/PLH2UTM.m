function [ UTM_N, UTM_E, UTM_U ] = PLH2UTM( lat,long,elev,zone,a,b )
%
%    PLH2UTM(lat,long,elev,zone,a,b) converts lat long and elevation
%       coordinates to UTM coordinates
%       If no ellipsoid parameters are used the fucntion uses the WGS84
%       ellipsoid. The return values are arrays.  No nargout has been
%       coded.
%
%       REQUIRES: fucntions calcn.m, calcsM.m,
%       INPUT:  lat,long in [RADS], zone in [int] , a,b in [meters] 
%       OUTPUT: Northing, Easting and Vertical in [meters]
%       *NOTES*  This only computes the coordinates for the Northern
%       Hemisphere.
%       REMEMBER:  if long is west it must be negative(-)

%Argument error checking
if nargin <= 3
    error('Not enough arguments. Please input the Zone');    
end

if nargin >=7
    eror('Too many arguments');
end

if nargin <= 5
	a = 6378137.0;
	b = 6356752.31425;
    %disp('Using WGS84 Ellipsoid....')
end
%Compute or Get UTM Zone Properties
ko=0.9996;
long_naught=(-177+(zone-1)*6)*pi/180;  
%This line computes the central meridian and then converts it to radians

%Compute the ellipsoid params
e2=(a^2-b^2)/a^2;
ep2=e2/(1-e2);

%Compute the subparameters
N=calcN(lat,a,b);
T=tan(lat).^2;
C=ep2*cos(lat).^2;
A=(long-long_naught).*cos(lat);
sM=calcsM(lat,a,b);
sMo=calcsM(0,a,b);

%Compute the Norhting Easting and Elevation
UTM_E=ko.*N.*(A+(1-T+C).*A.^3/6+(5-18.*T+T.^2+72.*C-58.*ep2).*A.^5/120); %x
UTM_N=ko.*(sM-sMo+N.*tan(lat).*(A.^2/2+(5-T+9*C+4*C.^2).*A.^4/24+(61-58*T+T.^2+600*C-330.*ep2).*A.^6/720)); %y
UTM_U=elev;  %z

%Add in False Easting 
UTM_E=UTM_E+500000;



function sM = calcsM(lat,a,b)
% Calculates the ellipsoidal suface distance given a latitude from the equator
% plane for a given ellipsoid.
%   calcsM(lat) calculates the ellipsoidal surface distance using
%      the WGS84 ellipsoid parameters.
%   CLACN(lat,a,b) calculates the ellipsoidal surface distance using
%       the ellipsoid parameters specified by 'a' and 'b'.
%
%   The latitude parameter should be given in radians.

if nargin<=2
	a = 6378137.0;
	b = 6356752.31425;
end

e2 = (a^2-b^2)/(a^2);

sM=a*((1-e2/4-3*e2^2/64-5*e2^3/256)*lat ...
    -(3*e2/8 +3*e2^2/32 +45*e2^3/1024)*sin(2*lat) ...
    +(15*e2^2/256 + 45*e2^3/1024)*sin(4*lat) ...
    -(35*e2^3/3072)*sin(6*lat));


