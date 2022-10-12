function [Slope_maxH,Slope_maxV] = SLOPE(varargin)
%
%SLOPE computes maximum weighetd SLOPE parameter 
%
%calls:
%       function Slope_max = SLOPEw(H)
%       function Slope_max = SLOPEw(H,W)
%
%in input:
%         - "H" design matrix
%         - "W" weighting matrix (optional)
%
%in output:
%         - "Slope_maxH" maximum Horizontale weighted SLOPE
%         - "Slope_maxV" maximum Vertical weighted SLOPE
%
%
%function called:
%
%
%note: refer to
%         - Brown, R.G., Chin, G.Y. 1997, GPS RAIM Calculation of Threshold and Protection Radius Using Chi-Square Methods - A Geometric Approach
%         - Ober 1996, New, Generally Applicable Metrics for RAIM/AAIM Integrity Monitoring
%         - Angrisano A., Gaglione S., Gioia C. 2012, RAIM algorithms for aided GNSS in urban scenario. Proc. UPINLBS 2012
%
%version 0.003 2013/10/21


H=varargin{1};

if nargin==1
    W=eye(size(H,1));
elseif nargin==2
    W=varargin{2};
end

A=inv(H'*W*H)*H'*W;
S=eye(size(H,1))-H*A;
SWS=S'*W*S;

SlopeH=(sqrt(A(1,:)'.^2+A(2,:)'.^2))./sqrt(diag(SWS));
SlopeV=sqrt((A(3,:)'.^2))./sqrt(diag(SWS));

Slope_maxH=max(SlopeH);
Slope_maxV=max(SlopeV);

