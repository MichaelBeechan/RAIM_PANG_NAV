function N = calcN(lat,a,b)
%
% CALCN calculates the prime vertical radius of curvature at a given
% latitude for a given ellipsoid.
% - CALCN(lat) calculates the prime vertical radius of curvature using
% the WGS84 ellipsoid parameters.
% - CALCN(lat,a,b) calculates the prime vertical radius of curvature 
% using the ellipsoid parameters specified by 'a' and 'b'.
%
%in input:
%         - "lat" latitude (in radians)
%         - "a" and "b" (optional) semimajor and semiminor ellipsoi axes
%         (in meters)
%
%in output:
%         - "N" the prime vertical radius of curvature
%
%%version 0.001 2013/07/30

if nargin<=2
	a = 6378137.0;
	b = 6356752.31425;
end

e2 = (a^2-b^2)/(a^2);
W  = sqrt(1.0-e2*((sin(lat)).^2));
N  = a./W;