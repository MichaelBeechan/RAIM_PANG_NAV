function varargout=orbital_propagator_GPS0(eph,tx_raw)

%
%orbital_propagator_GPS0.m implements the updating of GPS ephemerides and the transformation in ECEF frame 
% 
%in input:
%         - "eph" ephemerides matrix
%         - "tx_raw" raw epoch of transmission (when the satellite coordinates must be computed)
%
%in output:
%         - "position_ecef" (m x 3) satellite position in ECEF frame at epoch tx [meters] 
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
%            | eph(29,:) = tgd           |
%            | eph(30,:) = IODC          |
%            | eph(31,:) = TTimeMsg      |
%            | eph(32,:) = Fit_Interval  |
%            -----------------------------
%
%functions called:
%         - sv_clock_corr_GPS
%         - check_t
%         - matrix_rot
%         
%
%version 0.001 2013/08/30

global rot_e

% costante di gravitazione geocentrica [m^3/sec^2]
mu=3.986005*10^14;

%number of satellites
k=size(eph,2);


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
tgd=eph(29,:)';


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
        
% calcolo dell'anomalia vera all'epoca toss
AnVera=atan2((sqrt(1-ecc.^2)).*sin(AnEcc)./(1-ecc.*cos(AnEcc)),(cos(AnEcc)-ecc)./(1-ecc.*cos(AnEcc)));

% calcolo dell'argomento di latitudine all'epoca toss
u=omega+AnVera;

% argment of latitude correction
du=Cuc.*cos(2*u)+Cus.*sin(2*u);
% radius correction
dr=Crc.*cos(2*u)+Crs.*sin(2*u);
% inclination correction
di=Cic.*cos(2*u)+Cis.*sin(2*u);
         
% calcolo del raggio vettore all'epoca toss
r=A.*(1-ecc.*(cos(AnEcc)))+dr;
         
% aggiornamento dell'inclinazione all'epoca toss
i=i0+i_dot0.*dt+di;
         
% calcolo della longitudine del nodo ascendente all'epoca toss
LAMBDA=OMEGA0+(OMEGA_dot-rot_e).*dt-rot_e*toe;
                                                                                  
% corrected argment of latitude
u=u+du;

% coordinate dei satelliti nel sistema di riferimento orbitale
Xorb=r.*cos(u) ;
Yorb=r.*sin(u) ;
Zorb=zeros(size(Xorb)) ;

% coordinate dei satelliti nel sistema di coordinate ECEF 
Xecef=nan(k,1); Yecef=nan(k,1); Zecef=nan(k,1);
for dd=1:k
    Rx=matrix_rot(i(dd),'O','x');
    Rz=matrix_rot(LAMBDA(dd),'O','z');
    Xecef(dd)=Rz(1,:)*Rx*[Xorb(dd);Yorb(dd);Zorb(dd)];
    Yecef(dd)=Rz(2,:)*Rx*[Xorb(dd);Yorb(dd);Zorb(dd)];
    Zecef(dd)=Rz(3,:)*Rx*[Xorb(dd);Yorb(dd);Zorb(dd)];    
end

position_ecef=[Xecef'; Yecef'; Zecef'];

%relativistic effect correction
dtr=(-4.442807633e-10)*ecc.*roota.*sin(AnEcc);

dt_sv(:,1)=dt_sv(:,1)+dtr;

%outputs
varargout{1}=position_ecef;
varargout{2}=dt_sv;

    

