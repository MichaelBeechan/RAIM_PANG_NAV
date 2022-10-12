function varargout=orbital_propagator_GAL0(eph,tx_raw)
%
%
global GalileoCode
%
%possible calls:
%   function [position_ecef]=orbital_propagator_GPS(eph,tx_raw)
%   function [position_ecef,dt_sv]=orbital_propagator_GPS(eph,tx_raw)
%   function [position_ecef,velocity_ecef,dt_sv]=orbital_propagator_GPS(eph,tx_raw)
%   function [position_ecef,velocity_ecef,accel_ecef,dt_sv]=orbital_propagator_GPS(eph,tx_raw)
%
%orbital_propagator_GPS.m implements the updating of GPS ephemerides and the transformation in ECEF frame 
% 
%in input:
%         - "eph" ephemerides matrix
%         - "tx_raw" raw epoch of transmission (when the satellite coordinates must be computed)
%
%in output:
%         - "position_ecef" (m x 3) satellite position in ECEF frame at epoch tx [meters] 
%         - "velocity_ecef" (m x 3) satellite velocity in ECEF frame at epoch tx [m/sec]
%         - "accel_ecef" (m x 3) satellite acceleration in ECEF frame at epoch tx [m/sec^2]
%         - "dt_sv" (m x 2) satellite clock bias [sec] and drift [sec/sec]
%
%note:
%         - each sv must have 1 set of parameters, the selection of the set
%         must be performed preliminarly
%         - the "eph" structure is
%            -----------------------------
%            | eph(1,:)  = svprn         |
%            | eph(2,:)  = week_toc      | 
%            | eph(3,:)  = toc           |
%            | eph(4,:)  = af0           |
%            | eph(5,:)  = af1           | 
%            | eph(6,:)  = af2           |
%            | eph(7,:)  = IODE          |
%            | eph(8,:)  = crs           |
%            | eph(9,:)  = deltan        |
%            | eph(10,:) = M0            |
%            | eph(11,:) = cuc           |
%            | eph(12,:) = ecc           |
%            | eph(13,:) = cus           |
%            | eph(14,:) = roota         |
%            | eph(15,:) = toe           |
%            | eph(16,:) = cic           |
%            | eph(17,:) = Omega0        |
%            | eph(18,:) = cis           |
%            | eph(19,:) = i0            |
%            | eph(20,:) = crc           |
%            | eph(21,:) = omega         |
%            | eph(22,:) = Omegadot      |
%            | eph(23,:) = idot          |
%            | eph(24,:) = CodesOnL2     |
%            | eph(25,:) = week_toe      |
%            | eph(26,:) = L2Pflag       |
%            | eph(27,:) = SVaccuracy    |
%            | eph(28,:) = SVhealth      |
%            | eph(29,:) = BGD_E5aE1_gal |
%            | eph(30,:) = BGD_E5bE1_gal |
%            | eph(31,:) = TTimeMsg      |
%            | eph(32,:) = Fit_Interval  |
%            -----------------------------
%
%functions called:
%         - sv_clock_corr_GPS.m 
%         - check_t.m
%         - matrix_rot.m
%         
%
%version 0.001 2013/08/30

global rot_e

% costante di gravitazione geocentrica [m^3/sec^2]
mu=3.986005*10^14;

%number of satellites
k=size(eph,2);


%prn=eph(1,:);
M0=eph(10,:)';
roota=eph(14,:)';
Dn=eph(9,:)';
ecc=eph(12,:)';
omega=eph(21,:)';
Cuc=eph(11,:)';
Cus=eph(13,:)';
Crc=eph(20,:)';
Crs=eph(8,:)';
i0=eph(19,:)';
i_dot0=eph(23,:)';
Cic=eph(16,:)';
Cis=eph(18,:)';
OMEGA0=eph(17,:)';
OMEGA_dot=eph(22,:)';
toe=eph(15,:)';
toc=eph(3,:)';
Af0=eph(4,:)';
Af1=eph(5,:)';
Af2=eph(6,:)';
BGD_E5aE1_gal=eph(29,:)';
BGD_E5bE1_gal=eph(30,:)';

if strcmp(GalileoCode,'C1C ') || strcmp(GalileoCode,'C1X ') || strcmp(GalileoCode,'C1Z ')
    tgd=BGD_E5aE1_gal;
elseif strcmp(GalileoCode,'C5I ') || strcmp(GalileoCode,'C5Q ') || strcmp(GalileoCode,'C5X ')
    E1=1575.42;
    E5a=1176.45;
    tgd=(E1/E5a)^2*BGD_E5aE1_gal;
elseif strcmp(GalileoCode,'C7I ') || strcmp(GalileoCode,'C7Q ') || strcmp(GalileoCode,'C7X ')
    E1=1575.42;
    E5b=1207.140;
    tgd=(E1/E5b)^2*BGD_E5bE1_gal;
else
    disp('Galileo code not expected')
    tgd=0;
end

%satellite clock correction
[dt_sv(:,1),dt_sv(:,2)]=sv_clock_corr_GPS(Af0,Af1,Af2,toc,tx_raw);
dt_sv(:,1)=dt_sv(:,1)-tgd;

%approximate relativistic correction
dtr=(-4.442807633e-10)*ecc.*roota.*sin(M0);

%epoch of transmission
tx=tx_raw-dt_sv(:,1)-dtr;

% semi-major axis
A=roota.^2;

% calcolo del moto medio
n0=sqrt(mu./A.^3);

% intervallo tra epoca di interesse tx ed epoca di riferimento delle effemeridi
dt=tx-toe;
dt=check_t(dt);

% aggiornamento del moto medio all'epoca toss
n=n0+Dn;

% aggiornamento dell'anomalia media all'epoca toss
M=M0+n.*dt;

% % % derivative of Mean Anomaly M
% % M_dot=n;

AnEcc=nan(k,1);
for w=1:k
    % calcolo dell'anomalia eccentrica all'epoca toss
    E(1)=M(w);
    E(2)=E(1)-((E(1)-ecc(w)*sin(E(1))-M(w))/(1-ecc(w)*cos(E(1))));
    bb=1 ;
    while abs(E(bb+1)-E(bb))>10^-8 %% da -7 a -8
        bb=bb+1;
        E(bb+1)=E(bb)-((E(bb)-ecc(w)*sin(E(bb))-M(w))/(1-ecc(w)*cos(E(bb))));
    end
    AnEcc(w)=E(bb+1);
end

% % % derivative of Eccentric Anomaly AnEcc
% % AnEcc_dot=M_dot./(1-ecc.*cos(AnEcc));
        
% calcolo dell'anomalia vera all'epoca toss
%AnVera=2*atan(sqrt((1+ecc)./(1-ecc)).*tan(AnEcc/2));
AnVera=atan2((sqrt(1-ecc.^2)).*sin(AnEcc)./(1-ecc.*cos(AnEcc)),(cos(AnEcc)-ecc)./(1-ecc.*cos(AnEcc)));
    
% % % derivative of True Anomaly AnVera
% % AnVera_dot=sin(AnEcc).*AnEcc_dot.*(1+ecc.*cos(AnVera))./((1-ecc.*cos(AnEcc)).*sin(AnVera));

% calcolo dell'argomento di latitudine all'epoca toss
u=omega+AnVera;

% argment of latitude correction
du=Cuc.*cos(2*u)+Cus.*sin(2*u);
% radius correction
dr=Crc.*cos(2*u)+Crs.*sin(2*u);
% inclination correction
di=Cic.*cos(2*u)+Cis.*sin(2*u);

% % % derivative of argument of latitude
% % u_dot=AnVera_dot+2*(Cus.*cos(2*u)-Cuc.*sin(2*u)).*AnVera_dot;
         
% calcolo del raggio vettore all'epoca toss
r=A.*(1-ecc.*(cos(AnEcc)))+dr;
    
% % % derivative of Range earth center - satellite
% % r_dot=A.*ecc.*sin(AnEcc).*AnEcc_dot+2*(Crs.*cos(2*u)-Crc.*sin(2*u)).*AnVera_dot;
         
% aggiornamento dell'inclinazione all'epoca toss
i=i0+i_dot0.*dt+di;
    
% % % derivative of orbit inclination
% % i_dot=i_dot0+2*(Cis.*cos(2*u)-Cic.*sin(2*u)).*AnVera_dot;
         
% calcolo della longitudine del nodo ascendente all'epoca toss
LAMBDA=OMEGA0+(OMEGA_dot-rot_e).*dt-rot_e*toe;
    
% % % derivative of Longitude of Ascending Node
% % LAMBDA_dot=OMEGA_dot-rot_e;    
                                                                                  
% corrected argment of latitude
u=u+du;

% coordinate dei satelliti nel sistema di riferimento orbitale
Xorb=r.*cos(u) ;
Yorb=r.*sin(u) ;
Zorb=zeros(size(Xorb)) ;

% % % derivative of satellite orbital coordinates
% % Xorb_dot=r_dot.*cos(u)-Yorb.*u_dot;
% % Yorb_dot=r_dot.*sin(u)+Xorb.*u_dot;

% coordinate dei satelliti nel sistema di coordinate ECEF 
Xecef=nan(k,1); Yecef=nan(k,1); Zecef=nan(k,1);
for dd=1:k
    Rx=matrix_rot(i(dd),'O','x');
    Rz=matrix_rot(LAMBDA(dd),'O','z');
    Xecef(dd)=Rz(1,:)*Rx*[Xorb(dd);Yorb(dd);Zorb(dd)];
    Yecef(dd)=Rz(2,:)*Rx*[Xorb(dd);Yorb(dd);Zorb(dd)];
    Zecef(dd)=Rz(3,:)*Rx*[Xorb(dd);Yorb(dd);Zorb(dd)];    
end

% % % derivative of satellite ECEF coordinates
% % Xecef_dot=Xorb_dot.*cos(LAMBDA)-Yorb_dot.*cos(i).*sin(LAMBDA)+Yorb.*sin(i).*sin(LAMBDA).*i_dot-Yecef.*LAMBDA_dot;
% % Yecef_dot=Xorb_dot.*sin(LAMBDA)+Yorb_dot.*cos(i).*cos(LAMBDA)-Yorb.*sin(i).*cos(LAMBDA).*i_dot+Xecef.*LAMBDA_dot;
% % Zecef_dot=Yorb_dot.*sin(i)+Yorb.*cos(i).*i_dot;

position_ecef=[Xecef'; Yecef'; Zecef'];
% % velocity_ecef=[Xecef_dot'; Yecef_dot'; Zecef_dot'];

%relativistic effect correction
dtr=(-4.442807633e-10)*ecc.*roota.*sin(AnEcc);

% % % satellite accelerations
% % Xorb_dot2=-mu*Xorb./r.^3;
% % Yorb_dot2=-mu*Yorb./r.^3;
% % Xdot2=-Xorb.*LAMBDA_dot.^2.*cos(LAMBDA)...
% %     +Yorb.*((LAMBDA_dot.^2+i_dot.^2).*sin(LAMBDA).*cos(i)+2*LAMBDA_dot.*i_dot.*cos(LAMBDA).*sin(i))...
% %     -2*Xorb_dot.*LAMBDA_dot.*sin(LAMBDA)-2*Yorb_dot.*(LAMBDA_dot.*cos(LAMBDA).*cos(i)-i_dot.*sin(LAMBDA).*sin(i))...
% %     +Xorb_dot2.*cos(LAMBDA)-Yorb_dot2.*sin(LAMBDA).*cos(i);
% % Ydot2=-Xorb.*LAMBDA_dot.^2.*sin(LAMBDA)...
% %     -Yorb.*((LAMBDA_dot.^2+i_dot.^2).*cos(LAMBDA).*cos(i)-2*LAMBDA_dot.*i_dot.*sin(LAMBDA).*sin(i))...
% %     +2*Xorb_dot.*LAMBDA_dot.*cos(LAMBDA)-2*Yorb_dot.*(LAMBDA_dot.*sin(LAMBDA).*cos(i)+i_dot.*cos(LAMBDA).*sin(i))...
% %     +Xorb_dot2.*sin(LAMBDA)+Yorb_dot2.*cos(LAMBDA).*cos(i);
% % Zdot2=-Yorb.*i_dot.^2.*sin(i)+2*Yorb_dot.*i_dot.*cos(i)+Yorb_dot2.*sin(i);
% % 
% % accel_ecef=[Xdot2,Ydot2,Zdot2];

% % %relativistic correction to Doppler measurement
% % dtr_dot=-2/(299792458)^2*((Xecef_dot.^2+Yecef_dot.^2+Zecef_dot.^2)+Xecef.*Xdot2+Yecef.*Ydot2+Zecef.*Zdot2);

dt_sv(:,1)=dt_sv(:,1)+dtr;

%dt_sv(:,2)=dt_sv(:,2)+dtr_dot;

%outputs
varargout{1}=position_ecef;
%if nargout==2
    varargout{2}=dt_sv;
%elseif nargout==3
%    varargout{2}=velocity_ecef;
%    varargout{3}=dt_sv;
%elseif nargout==4
%    varargout{2}=velocity_ecef;
%    varargout{3}=accel_ecef;
%    varargout{4}=dt_sv;
%end
    

