function [x,VCx,DOPs,nr_sat,Flag,Test_Results,sigma2post,PLs]=GE_LS_fix(obs_gps,eph_gps,obs_gal,eph_gal,x0,iono_corr,DOY)
%
% GE_LS_fix.m solves for the GPS/Galileo unknowns using pseudo-range
% and Least-Square method (processes only 1 epoch)
%
%in input:
%         - "obs_gps" GPS observation matrix [week sec prn PR D1 S1]
%         - "eph_gps" GPS satellites ephemerides 
%         - "obs_gal" Galileo observation matrix [week sec prn PR D1 S1]
%         - "eph_gal" Galileo satellites ephemerides 
%         - "x0" a priori state vector: lat(rad),long(rad),h(meter),offset receiver clock(meter)
%         - "iono_corr" Kloubuchar model parameters for ionospheric correction
%         - "DOY" Day Of Year
%
%in output:
%         - "x" State Vector: lat(rad),long(rad),h(meter),offset receiver
%           clock(meter),GPS/GLONASS inter-system offset(meter)
%         - "VCx" x Covariance Matrix  (m^2)
%         - "DOPs" vector of DOPs values : [PDOP_pre_raim;PDOP_post_raim];
%         - "nr_sat" number of sv : 
%           [nr_PR_pre_raim; nr_PR_post_raim]
%         - "Flag" solution availability
%                 Flag=1 => fix available,
%                 Flag=0 => fix unavailable (not enough sv or bad geometry)
%         - "Test_Results" solution reliability and number of rejections 
%           Test_Results(1)=position solution reliability,
%                 Test_Results(1)=0 => no redundancy or solution not tested
%                 Test_Results(1)=1 => solution reliable
%                 Test_Results(1)=2 => solution unreliable
%           Test_Results(2)=nr PR rejected
%         - "sigma2post" a posteriori variance PR & D1
%                 sigma2post(1) PR a posteriori variance
%                 sigma2post(2) D1 a posteriori variance
%         - "PLs" protection levels
%                 PLs(1) HPL 
%                 PLs(2) VPL
%
%function called:
%         - orbital_propagator_GPS0
%         - orbital_propagator_GAL0
%         - geo2ecef
%         - ecef2enu
%         - enu2altaz
%         - iono_correction
%         - tropo_correction0
%         - RAIM_Subset
%         - SLOPE
%         - calcN
%         - meridian_radius
%


global rot_e v_light v_config LambdaChi2 RAIMset

%vettore di configurazione
WEIGHT_flag=v_config(1);
RAIM_flag=v_config(2);

if isempty(iono_corr)
    iono_corr=zeros(2,4);
end
%iono corrections
alfa_corr=iono_corr(1,:); beta_corr=iono_corr(2,:);

%mette in ordine crescente di prn
obs_gps=sortrows(obs_gps,3);
obs_gal=sortrows(obs_gal,3);

%%%%%%%GPS%%%%%%%%%
prn_gps=obs_gps(:,3);
tr=unique(obs_gps(:,2));
PR_gps=obs_gps(:,4);

%elimina nan da PR, D1 e eph
prn_gps=prn_gps(~isnan(PR_gps));
PR_gps=PR_gps(~isnan(PR_gps));
eph_gps=eph_gps(:,ismember(eph_gps(1,:),prn_gps));

%number of GPS visible satellites
nr_PR_GPS0=sum(~isnan(PR_gps));

%%%%%%Galileo%%%%%%%
prn_gal=obs_gal(:,3);
%tr_gal=obs_gal(:,2);
PR_gal=obs_gal(:,4);

%elimina nan da PR, D1 e eph
prn_gal=prn_gal(~isnan(PR_gal));
PR_gal=PR_gal(~isnan(PR_gal));
eph_gal=eph_gal(:,ismember(eph_gal(1,:),prn_gal));

%number of Galileo visible satellites
nr_PR_GAL0=sum(~isnan(PR_gal));

nr_PR_tot0=nr_PR_GPS0+nr_PR_GAL0;

% Definition of the output
x=nan(5,1);
VCx=nan(5,5);
DOPs=nan(2,1);
Flag=0; %no fix
Test_Results=[0;0]; %no redundancy, no rejections
nr_sat=[nr_PR_tot0; nr_PR_tot0];
sigma2post=ones(1,1);
PLs=nan(2,1);
IA=[];

%%
%check on the number of visible satellites
if  nr_PR_tot0<4 || (nr_PR_tot0==4 && nr_PR_GAL0~=0 && nr_PR_GPS0~=0)
    %%%%%%%%%%%%%%%% NO FIX %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    return
    
elseif nr_PR_GAL0==0
    %%%%%%%%%%%%%%%% GPS ONLY FIX %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [x(1:4),VCx(1:4,1:4),DOPs,nr_sat(1:4),Flag,Test_Results,sigma2post,PLs]=GPS_LS_fix(obs_gps,eph_gps,x0(1:4),iono_corr,DOY);
    x(5)=x0(5);
    return
    
elseif nr_PR_GPS0==0
    %%%%%%%%%%%%%%%% GALILEO ONLY FIX %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('GALILEO only not available')
    return
    
else
%%%%%%%%%%%%%%%% GPS/GALILEO FIX %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    Flag=1; %yes fix   
    
    x=x0;
    
    %raw epoch of transmission
    tx_raw_gps=tr-PR_gps/v_light;
    %raw epoch of transmission
    tx_raw_gal=tr-PR_gal/v_light;

    %satellite position and velocity at transmissione epoch
    [position_ecef_gps,dt_sv_gps]=orbital_propagator_GPS0(eph_gps,tx_raw_gps);
    
    %satellite position and velocity at transmissione epoch
    [position_ecef_gal,dt_sv_gal]=orbital_propagator_GAL0(eph_gal,tx_raw_gal);
    
    dt_sv_bias_gps=dt_sv_gps(:,1);
    
    dt_sv_bias_gal=dt_sv_gal(:,1);
    
    Xs_gps=position_ecef_gps(1,:)';
    Ys_gps=position_ecef_gps(2,:)';
    Zs_gps=position_ecef_gps(3,:)';
    
    Xs_gal=position_ecef_gal(1,:)';
    Ys_gal=position_ecef_gal(2,:)';
    Zs_gal=position_ecef_gal(3,:)';
    
    nr_PR_GPS=nr_PR_GPS0;
    nr_PR_GAL=nr_PR_GAL0;
    dX(1:3)=[1;1;1];
    j=0;
    while norm(dX(1:3))>0.01 || j<100
        j=j+1;
        
        %
        [Xr,Yr,~]=geo2ecef(x(1),x(2),x(3));
        %Sagnac correction
        dS_gps=rot_e/v_light*(Ys_gps*Xr-Xs_gps*Yr);
        dS_gal=rot_e/v_light*(Ys_gal*Xr-Xs_gal*Yr);
        %
        
        %transformation of satellite coordinates and velocity from ECEF to ENU frame
        [Es_gps,Ns_gps,Us_gps]=ecef2enu(Xs_gps,Ys_gps,Zs_gps,x(1),x(2),x(3),'pos');
        [Es_gal,Ns_gal,Us_gal]=ecef2enu(Xs_gal,Ys_gal,Zs_gal,x(1),x(2),x(3),'pos');
        
        % a priori range satellite-receiver
        d0_gps=sqrt(Es_gps.^2+Ns_gps.^2+Us_gps.^2);
        d0_gal=sqrt(Es_gal.^2+Ns_gal.^2+Us_gal.^2);
        
        %trasformation from ENU to Altazimut coordinates
        [el_s_gps,az_s_gps] = enu2altaz(Es_gps,Ns_gps,Us_gps);
        [el_s_gal,az_s_gal] = enu2altaz(Es_gal,Ns_gal,Us_gal);
        
        %ionospheric delay in meters
        DI_gps=iono_correction(x(1),x(2),el_s_gps,az_s_gps,alfa_corr,beta_corr,tr);
        DI_gal=iono_correction(x(1),x(2),el_s_gal,az_s_gal,alfa_corr,beta_corr,tr);
        
        %tropospheric error in meters
        DT_gps=tropo_correction0(x(3),x(1),DOY,el_s_gps);
        DT_gal=tropo_correction0(x(3),x(1),DOY,el_s_gal);
        
        %PR corrected for sv clock error,relativistic effect and atmospheric error
        PR_corr_gps=PR_gps+dt_sv_bias_gps*v_light-DI_gps-DT_gps+dS_gps;
        PR_corr_gal=PR_gal+dt_sv_bias_gal*v_light-DI_gal-DT_gal+dS_gal;
        
        if j==1
            if WEIGHT_flag==0  %no weight
                R_PR_gps=eye(nr_PR_GPS);
                R_PR_gal=eye(nr_PR_GAL);
            elseif WEIGHT_flag==1
                R_PR_gps=diag(1./(sin(el_s_gps)).^2);
                R_PR_gal=diag(1./(sin(el_s_gal)).^2);
            end
            W_PR_gps=eye(size(R_PR_gps))/R_PR_gps;
            W_PR_gal=eye(size(R_PR_gal))/R_PR_gal;
            W_PR=blkdiag(W_PR_gps,W_PR_gal);
        end
        
        %PR measurements corrected for a priori information
        z_gps=PR_corr_gps-d0_gps-x(4);
        z_gal=PR_corr_gal-d0_gal-x(4)-x(5);
        z=[z_gps;z_gal];
                
        %geometry matrix for PR
        H_gps=[-Es_gps./d0_gps, -Ns_gps./d0_gps, -Us_gps./d0_gps, ones(nr_PR_GPS,1), zeros(nr_PR_GPS,1)];
        H_gal=[-Es_gal./d0_gal, -Ns_gal./d0_gal, -Us_gal./d0_gal, ones(nr_PR_GAL,1), ones(nr_PR_GAL,1)];
        H=[H_gps;H_gal];
        
        if j==1
            GDOP_matrix_pre=inv(H'*H);
            PDOP_pre=sqrt(trace(GDOP_matrix_pre(1:3,1:3)));
            DOPs(1)=PDOP_pre;
            if PDOP_pre>30
                Flag=0;
                x=nan(5,1);
                VCx=nan(5,5);
                Test_Results(1)=2;
                return
            end
        end
        
        %corrections
        dX=(H'*W_PR*H)\(H'*W_PR*z);

        %%% RAIM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if RAIM_flag==1 && j==1
            
            [Test_Results(1:2),zz,HH,WW_PR] = RAIM_Subset(z,dX,H,W_PR);
            dX=(HH'*WW_PR*HH)\(HH'*WW_PR*zz);
            [~,IA]=setdiff(z,zz);
            nr_PR_GPS_rej=sum(IA<=(length(z_gps)));
            nr_PR_GPS=nr_PR_GPS0-nr_PR_GPS_rej;
            nr_PR_GAL_rej=sum(IA>(length(z_gps)));
            nr_PR_GAL=nr_PR_GAL0-nr_PR_GAL_rej;
            nr_sat(2)=nr_PR_GPS+nr_PR_GAL;
            [Slope_maxH,Slope_maxV] = SLOPE( HH,WW_PR );
            HPL=Slope_maxH*sqrt(LambdaChi2(nr_PR_GPS+nr_PR_GAL-5));
            VPL=Slope_maxV*sqrt(LambdaChi2(nr_PR_GPS+nr_PR_GAL-5));
            PLs(1)=HPL;
            PLs(2)=VPL;
            if HPL>RAIMset.HAL || VPL>RAIMset.VAL
                Test_Results(1)=2;
            end
            
            W_PR=WW_PR;
            H=HH;
            z=zz;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    
        %state vector updating
        x(1)=x(1)+dX(2)/(meridian_radius(x(1))+x(3));
        x(2)=x(2)+dX(1)/((calcN(x(1))+x(3))*cos(x(1)));
        x(3:5)=x(3:5)+dX(3:5);

        if j==1 && nr_PR_tot0>5
            %residuals
            r=z-H*dX;
            %a posteriori variance
            sigma2post=(r'*W_PR*r)/(nr_PR_tot0-5);
        end
        
        %covariance matrix in m^2, (m/s2)^2, m^2
        %DOP computation
        VCx=sigma2post*inv(H'*W_PR*H);
        GDOP_matrix=inv(H'*H);
        DOPs(2)=sqrt(trace(GDOP_matrix(1:3,1:3)));
        
        if DOPs(2)>30
            Flag=0;
            x=nan(5,1);
            VCx=nan(5,5);
            Test_Results(1)=2;
            return
        end
        
        if j==1 && RAIM_flag==1 && ~isempty(IA)
            IA_gps=IA(IA<=nr_PR_GPS0);
            Xs_gps(IA_gps)=[];
            Ys_gps(IA_gps)=[];
            Zs_gps(IA_gps)=[];
            dt_sv_bias_gps(IA_gps)=[];
            PR_gps(IA_gps)=[];
            IA_gal=IA(IA>nr_PR_GPS0)-nr_PR_GPS0;
            Xs_gal(IA_gal)=[];
            Ys_gal(IA_gal)=[];
            Zs_gal(IA_gal)=[];
            dt_sv_bias_gal(IA_gal)=[];
            PR_gal(IA_gal)=[];
        end
        
    end
    
end