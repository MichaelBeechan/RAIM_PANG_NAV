function M=meridian_radius(varargin)
%
%meridian_radius computes the Meridian Radius of Curvature for WGS84
%(default) or for another model specified in input
%
%in input:
%         - latitude in which compute the radius lat [rad]
%         - semi-major axis (m) and eccentricity of the ellipsoid (optional)
%
%in output:
%         - "M" Meridian Radius of Curvature [meter]
%
%note: 
%      M=meridian_radius(lat) returs the radius for WGS84,
%      M=meridian_radius(lat,a,e) returns the radius for the ellipsoid with
%      semi-major axis a and eccentricity e
%
%version 0.001 2013/08/27


if nargin==1

   %WGS84 ellipsoid definition
   a=6378137.0; %semi-major axis (meter)
   f=1/298.257223563; %flattering
   e=sqrt(2*f-f^2); %eccentricy
   
else
   
   a=varargin{2};
   e=varargin{3};
   
end

lat=varargin{1};

M=a*(1-e^2)/(1-e^2*(sin(lat))^2)^(3/2);
