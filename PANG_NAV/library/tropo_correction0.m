function varargout=tropo_correction0(varargin)
%
% tropo_correction function computes an estimation of the tropospheric delay in m,
% using Saastamoinen model. 
%
% the call is:
%       dD_tropo=tropo_correction(QuotaE,Latitudine,DOY,El)
%
%
%
%in input:
%         - "QuotaE" receiver altitude  [m]
%         - "Latitudine" receiver latitude  [rad]
%         - "DOY" day of the year
%         - "El" satellite elevation  [rad]
%
%in output:
%         - "dD_tropo" tropospheric delay [m]
%
%
%
%version 0.001 2013/09/11


%global tropo_model


QuotaE=varargin{1};
Latitudine=varargin{2};
DOY=varargin{3};
El=varargin{4};


LimLat=[15 30 45 60 75]';

%      P0(mbar)  T0(K)  e0(mbar) beta(K/m) lambda0  
Pmean=[1013.25, 299.65, 26.31,   6.30e-3,   2.7; 
       1017.25, 294.15, 21.79,   6.05e-3,   3.15;
       1015.75, 283.15, 11.66,   5.58e-3,   2.57;
       1011.75, 272.15,  6.78,   5.39e-3,   1.81;
       1013.00, 263.65,  4.11,   4.53e-3,   1.55];
   
%      DP(mbar)  DT(K)  De(mbar) Db(K/m)    dl 
Pseason=[ 0.00,   0.00,  0.00,   0.00e-3,   0.00;
         -3.75,   7.00,  8.85,   0.25e-3,   0.33;
         -2.25,  11.00,  7.24,   0.32e-3,   0.46;
         -1.75,  15.00,  5.36,   0.81e-3,   0.74;
         -0.50,  14.50,  3.39,   0.62e-3,   0.30];


Latitudine=rad2deg(Latitudine);

if Latitudine<0
    D_star=211;
else
    D_star=28;
end

i=find(LimLat<Latitudine,1,'last');
if isempty(i)==1
    P0=Pmean(1,:);
    DP=Pseason(1,:);
elseif i==5
    P0=Pmean(5,:);
    DP=Pseason(5,:);
elseif i<5
    m=(Latitudine-LimLat(i))/(LimLat(i+1)-LimLat(i));
    P0=Pmean(i,:)+(Pmean(i+1,:)-Pmean(i,:))*m;
    DP=Pseason(i,:)+(Pseason(i+1,:)-Pseason(i,:))*m;
end

Par=P0-DP.*cos(2*pi*(DOY-D_star)/365.25);

P=Par(1);T=Par(2);e=Par(3);beta=Par(4);lambda=Par(5);

fs=1-0.00266*cos(2*Latitudine)-0.00000028*QuotaE;

D_z_dry=(0.0022768-0.0000005)*P/fs;

D_z_wet=(0.002277*(1255/T+0.05)*e)/fs;

M=1.001./sqrt(0.002001+(sin(El)).^2);

dD_tropo=(D_z_dry+D_z_wet)*M;


varargout{1}=dD_tropo;


