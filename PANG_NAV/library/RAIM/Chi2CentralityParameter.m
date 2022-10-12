function CentralityPar = Chi2CentralityParameter( DOF,Pfa,Pmd )
%T_GLOBAL Summary of this function goes here
%   Detailed explanation goes here


T=chi2inv(1-Pfa,DOF);

CentralityPar=T+0.001;
Pmd_computed = ncx2cdf(T,DOF,CentralityPar);

while Pmd_computed>Pmd
    
    CentralityPar=CentralityPar+0.001;
    Pmd_computed = ncx2cdf(T,DOF,CentralityPar);

end
