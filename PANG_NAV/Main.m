%Main of PANG-NAV, a tool for GNSS SPP solution

clear

format long 

addpath(genpath('library'))
addpath('data')

%%
%%%%%%%%%%%%%%%%%%%%%%%%% Global Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global rot_e 
global v_light
global dt_data
global v_config
global mask_angle
global SNR_lim
global T_Global LambdaChi2
global RAIMset
global GalileoCode
global sigma_pr

%%
%%%%%%%%%%%%%%%%%%%%%%%%% constants %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Earth angular velocity (rad/sec)
rot_e=7.2921151467e-5;
%light speed [m/sec]
v_light=299792458;


%%
%%%%%%%%%%%%%%%%%%%%%%%%% settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%data interval [seconds]
dt_data=1;

%GNSS system
gnss_systems=1; % 1=GPS; 2=GPS/GALILEO;

% configuration
%weighting
Weight_flag=1; %0=EQUAL WEIGHTS; 1=(sin(el))^2;
%raim
RAIM_flag=1;   %0=noRAIM; 1=RAIM;
v_config=[Weight_flag,RAIM_flag];

%mask angle
mask_angle=deg2rad(10);
%signal-noise ratio limit
SNR_lim=20;

%pseudorange measurement precision
sigma_pr=3;

%error analysis
Error_Analysis_flag=0; %0=no analysis; 1=yes analysis
%solution source
Static_Solution_fromRINEX=0; %0=no; 1=yes

%RAIM settings
if RAIM_flag==1
    RAIMset.Pfa=0.001; % 0.1%
    RAIMset.Pmd=0.1; % 10%
    RAIMset.HAL=500; % meters
    RAIMset.VAL=500; % meters
    T_Global=[10.827566170662738,13.815510557964272,16.266236196238129,18.466826952903151,20.515005652432876,22.457744484825323,24.321886347856850,26.124481558376136,27.877164871256568,29.588298445074418,31.264133620239992,32.909490407360217,34.528178974870883,36.123273680398135,37.697298218353822,39.252354790768472,40.790216706902520,42.312396331679963]'; %using statistics toolbox T_Global=(chi2inv(1-RAIMset.Pfa,1:18))';
    LambdaChi2=[20.9045661706659,23.8175105579726,25.9352361962499,27.6828269529144,29.2060056524435,30.5737444848352,31.8258863478660,32.9874815583810,34.0761648712568,35.1032984450701,36.0781336202314,37.0094904073507,37.9011789748630,38.7582736803920,39.5842982183494,40.3833547907658,41.1572167069017,42.3133963316800,43.8211959645175,45.3157466181259]';
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%% data loading %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(' ')
disp('...data loading...')
disp(' ')
Rinex3_Parser
%out
% XYZ_station,leap_sec,observations,dt_data,header,version_rinex
%%


PRonL1_gps='C1C ';  % 'C1C' or 'C1S' or 'C1L' or 'C1X'
D1_gps='D1C ';     % 'D1C' or 'D1S' or 'D1L' or 'D1X'
S1_gps='S1C ';     % 'S1C' or 'S1S' or 'S1L' or 'S1X'

PRonL1_gal='C1C ';  % 'C1A' or 'C1B' or 'C1C' or 'C1X' or 'C1Z'
D1_gal='D1C ';     % 'D1A' or 'D1B' or 'D1C' or 'D1X' or 'D1Z'
S1_gal='S1C ';     % 'S1A' or 'S1B' or 'S1C' or 'S1X' or 'S1Z'


GalileoCode=PRonL1_gal;

% ionospheric model (Klobuchar)
Iono_corr=iono_corr.klo;


%settings display
disp('________________________________')
disp('Settings')
disp('---------')
if gnss_systems==1
    disp('GPS')
elseif gnss_systems==2
    disp('GPS/GALILEO')
end
disp(PRonL1_gps)
disp('---------')
if RAIM_flag==0
    disp('RAIM OFF')
elseif RAIM_flag==1
    %disp('---------')
    disp('RAIM ON')
    disp('Subset Method')
    str_raim1 = sprintf('     Pfa %d', RAIMset.Pfa);
    str_raim2 = sprintf('     Pmd %d', RAIMset.Pmd);
    str_raim3 = sprintf('     HAL %d', RAIMset.HAL);
    str_raim4 = sprintf('     VAL %d', RAIMset.VAL);
    disp(str_raim1),disp(str_raim2),disp(str_raim3),disp(str_raim4)
    %RAIMset
end
disp('---------')
if Weight_flag==0
    disp('Weights 1')
elseif Weight_flag==1
    disp('Weights f(sin(el)')
end
disp('---------')
stringa1 = sprintf('Mask Angle %d', rad2deg(mask_angle));
disp(stringa1)
stringa2 = sprintf('SNR limit %d', SNR_lim);
disp(stringa2)
disp('---------')
disp('Tropo Model: Saastamoinen')
disp('Iono model: Klobuchar')
disp('________________________________')

%%
%%%%%%%%%%%%%%%%%%%%%%%% data pre-pocessing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if gnss_systems==1
    observations.gps(:,2)=round(observations.gps(:,2));
    epoche_obs=unique(observations.gps(:,2));
    %first_epoch
    first_epoch=min(epoche_obs);
    %last_epoch
    last_epoch=max(epoche_obs);
    nr_observations_gps=size(observations.gps,1);
    eph_GPS=eph.gps;
end


if gnss_systems==2
    observations.gps(:,2)=round(observations.gps(:,2));
    observations.gal(:,2)=round(observations.gal(:,2));
    epoche_obs=unique([observations.gps(:,2);observations.gal(:,2)]);
    %first_epoch
    first_epoch=min(epoche_obs);
    %last_epoch
    last_epoch=max(epoche_obs);
    nr_observations_gps=size(observations.gps,1);
    nr_observations_gal=size(observations.gal,1);
    eph_GPS=eph.gps;
    eph_GAL=eph.gal;
end


epochs=first_epoch:dt_data:last_epoch;
epochs=makeitcol(epochs);

%numero epochs totali presunte
nr_epoche=length(epochs);
%durata sessione 
durata_sessione=last_epoch-first_epoch;


%%%%%%%%%%%%%%%%%%%%%%%%%% obs format %%%%%%%%%%%%
% obs_GPS  week sec prn  C1 D1 S1
%            1   2   3   4  5  6 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if gnss_systems==1 || gnss_systems==2
    observations.gps=observations.gps(observations.gps(:,3)==0,:);
    obs_GPS=nan(nr_observations_gps,6);
    obs_GPS(:,1)=observations.gps(:,1);
    obs_GPS(:,2)=observations.gps(:,2);
    obs_GPS(:,3)=observations.gps(:,4);
    col_PRonL1_gps = find(ismember(header.gps,PRonL1_gps)==1);
    if ~isempty(col_PRonL1_gps)
        obs_GPS(:,4)=observations.gps(:,col_PRonL1_gps);
    end
    col_D1_gps = find(ismember(header.gps,D1_gps)==1);
    if ~isempty(col_D1_gps)
        obs_GPS(:,5)=observations.gps(:,col_D1_gps);
    end
    col_S1_gps = find(ismember(header.gps,S1_gps)==1);
    if ~isempty(col_S1_gps)
        obs_GPS(:,6)=observations.gps(:,col_S1_gps);
    end
end

if gnss_systems==2
    observations.gal=observations.gal(observations.gal(:,3)==0,:);
    obs_GAL=nan(nr_observations_gal,6);
    obs_GAL(:,1)=observations.gal(:,1);
    obs_GAL(:,2)=observations.gal(:,2);
    obs_GAL(:,3)=observations.gal(:,4);
    col_C1_gal = find(ismember(header.gal,PRonL1_gal)==1);
    if ~isempty(col_C1_gal)
        obs_GAL(:,4)=observations.gal(:,col_C1_gal);
    end
    col_D1_gal = find(ismember(header.gal,D1_gal)==1);
    if ~isempty(col_D1_gal)
        obs_GAL(:,5)=observations.gal(:,col_D1_gal);
    end
    col_S1_gal = find(ismember(header.gal,S1_gal)==1);
    if ~isempty(col_S1_gal)
        obs_GAL(:,6)=observations.gal(:,col_S1_gal);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 
% initial position %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if XYZ_station(1)==0 && XYZ_station(2)==0 && XYZ_station(3)==0
    %no info about approx coordinates of receiver
    obs_first_epoch_GPS=obs_GPS(obs_GPS(:,2)==epochs(1),:);
    LLH_Approx_Rec_Coords = Approx_Rec_Coords_Generator_GPS(eph_GPS,obs_first_epoch_GPS);
    Lat_station=LLH_Approx_Rec_Coords(1);
    Lon_station=LLH_Approx_Rec_Coords(2);
    Alt_station=LLH_Approx_Rec_Coords(3);
else
    [Lat_station,Lon_station,Alt_station]=ecef2geo(XYZ_station(1),XYZ_station(2),XYZ_station(3));
end

lat=Lat_station;
long=Lon_station; 
altitude=Alt_station;

if gnss_systems==1
    %GPS LS
    x0=[lat; long; altitude; 0];
else
    %GPS/GAL LS
    x0=[lat; long; altitude; 0; 0];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
% UTM zone %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
UTM_zone = UTM_LongZone(rad2deg(Lon_station));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 
% Pre-allocations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

%GPS LS
if gnss_systems==1
    X=nan(4,nr_epoche);
    VCx=nan(4,4,nr_epoche);
    DOPs=nan(2,nr_epoche);
    nr_sat=nan(2,nr_epoche);
    Flag=nan(1,nr_epoche);
    RAIM_Results=nan(2,nr_epoche);
    sigma2post=nan(2,nr_epoche);
    PLs=nan(2,nr_epoche);
end

%GPS/GAL LS
if gnss_systems==2
    X=nan(5,nr_epoche);
    VCx=nan(5,5,nr_epoche);
    DOPs=nan(2,nr_epoche);
    nr_sat=nan(2,nr_epoche);
    Flag=nan(1,nr_epoche);
    RAIM_Results=nan(2,nr_epoche);
    sigma2post=nan(2,nr_epoche);
    PLs=nan(2,nr_epoche);
end

disp(' ')
disp('...processing...')
disp(' ')
for k=1:nr_epoche
    
    if (k>1 && (RAIM_Results(1,k-1)==1) && RAIM_flag==1) || (k>1 && Flag(k-1)==1 && RAIM_flag==0)
        x0=X(:,k-1);
    end
    
    %selection of observations referred to the same epoch
    if gnss_systems==1 || gnss_systems==2
        obs_1epoch_GPS=obs_GPS(obs_GPS(:,2)==epochs(k),:);
    end
    if gnss_systems==2
        obs_1epoch_GAL=obs_GAL(obs_GAL(:,2)==epochs(k),:);
    end
    
    %controllo su elevazione e SNR
    if gnss_systems==1
        %unhealty SV elimination
        eph_GPS=eph_GPS(:,eph_GPS(28,:)==0);
        [eph_1epoch_GPS,obs_1epoch_GPS] = Preliminary_Check_GPS(eph_GPS,obs_1epoch_GPS,x0(1:3));
    end
    if gnss_systems==2
        %unhealty SV elimination
        eph_GAL=eph_GAL(:,eph_GAL(28,:)==0);
        eph_GPS=eph_GPS(:,eph_GPS(28,:)==0);
        [eph_1epoch_GPS,obs_1epoch_GPS] = Preliminary_Check_GPS(eph_GPS,obs_1epoch_GPS,x0(1:3));
        [eph_1epoch_GAL,obs_1epoch_GAL] = Preliminary_Check_GAL(eph_GAL,obs_1epoch_GAL,x0(1:3));
    end
    
    
    %%%%%%%%% GPS %%%%%%%%%%%
    if gnss_systems==1
        [X(:,k),VCx(:,:,k),DOPs(:,k),nr_sat(:,k),Flag(k),RAIM_Results(:,k),sigma2post(:,k),PLs(:,k)]=GPS_LS_fix(obs_1epoch_GPS,eph_1epoch_GPS,x0,Iono_corr,DOY);
    end
   
    %%%%%%%%% GPS/Galileo %%%%%%%%%%%
    if gnss_systems==2
        [X(:,k),VCx(:,:,k),DOPs(:,k),nr_sat(:,k),Flag(k),RAIM_Results(:,k),sigma2post(:,k),PLs(:,k)]=GE_LS_fix(obs_1epoch_GPS,eph_1epoch_GPS,obs_1epoch_GAL,eph_1epoch_GAL,x0,Iono_corr,DOY);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%

end

%solution availability and reliable availability
Sol_availability=sum(Flag)/nr_epoche;

%% 
% Error Analysis and Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if gnss_systems==1
    gnss_config='GPS only';
else
    gnss_config='GPS/Galileo';
end

TrajectoryPlot(epochs, X,UTM_zone,gnss_config,'g' )
VisibilityDOPs_Plot(epochs,nr_sat,DOPs,RAIM_flag)
if RAIM_flag==1
    PLs_Plot(epochs,PLs)
    Reliable_availability=sum(RAIM_Results(1,:)==1)/nr_epoche;
end

if Error_Analysis_flag==1
    if Static_Solution_fromRINEX==1
        [Lat_station,Lon_station,Alt_station]=ecef2geo(XYZ_station(1),XYZ_station(2),XYZ_station(3));
        solution(:,1)=epochs;
        solution(:,2)=rad2deg(Lat_station);
        solution(:,3)=rad2deg(Lon_station);
        solution(:,4)=Alt_station;
    else
        [filename_OBS,directory_OBS] = uigetfile('*.mat','select reference solution');
        filepath_OBS=[directory_OBS,filename_OBS];
        load(filepath_OBS)
        if size(solution,1)==1
            solution2(:,1)=epochs;
            solution2(:,2)=solution(1);
            solution2(:,3)=solution(2);
            solution2(:,4)=solution(3);
            solution=solution2;
        else
            ref_lat=interp1(solution(:,1),solution(:,2),epochs);
            ref_lon=interp1(solution(:,1),solution(:,3),epochs);
            ref_alt=interp1(solution(:,1),solution(:,4),epochs);
            solution=[epochs,ref_lat,ref_lon,ref_alt];
        end
    end
    [e_H_g,e_U_g,Error_Table_Pos]=ErrorsPlots0( solution,X,UTM_zone,gnss_config,'g' );
end

disp('processing successfully completed')

clearvars -except epochs X nr_sat DOPs PLs e_H_g e_U_g Error_Table_Pos Sol_availability Reliable_availability RAIM_Results
