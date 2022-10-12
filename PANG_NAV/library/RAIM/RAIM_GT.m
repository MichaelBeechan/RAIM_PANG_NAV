function [flag,v,Cv,RedMatrix] = RAIM_GT(z,x,H,W)
%
% RAIM_GT function implements the RAIM global test concept
%
%in input:
%        - "z" measurements
%        - "x" state vector
%        - "H" design matrix
%        - "W" weitghing matrix
%
%in output:
%        - "flag" (0=>no redundancy) (1=>test OK) (2=>test not OK)
%        - "v" residuals
%        - "Cv" residuals covariance matrix
%        - "RedMatrix" Redundancy matrix
%
%note: for RAIM global test concept refer to 
%        - R.G. Brown and G.Y. Chin, “GPS RAIM Calculation of Threshold and Protection Radius Using Chi-Square Methods - A Geometric Approach”, Global Positioning System: Inst. Navigat., vol. V, pp. 155–179, 1997.
%        - Kuusniemi H. 2005, User-level reliability and quality monitoring in satellite-based personal navigation, PhD thesis, Tampere University of Technology
%        - Angrisano A., Gaglione S., Gioia C. 2012, RAIM algorithms for aided GNSS in urban scenario. Proc. UPINLBS 2012
%
%function called:
%        - RAIM_GT
%
%version 0.001 2013/08/27


global T_Global

v=nan;
Cv=nan;
RedMatrix=nan;

n=size(H,1);
m=size(H,2);

%redundancy
redundancy=n-m;

if redundancy>=1
    
    %residuals
    v=z-H*x;
    

    %statistic test
    D=v'*W*v;
    
    %theshold
    T = T_Global( redundancy );
    
    if D>T
        flag=2; %test not OK
    else
        flag=1; %test is OK
    end
    
    %VC matrix of residuals 
    Cv=inv(W)-(H/(H'*W*H))*H';
    
    %Redundancy matrix
    RedMatrix=Cv*W;
    
else
    
    flag=0; %not enough redundancy to perform the test
    
end

