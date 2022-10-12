function [x,VCx,DOPs,nr_sat,Flag,Test_Results,sigma2post,PLs]=GPS_LS_fix(obs,eph,x0,iono_corr,DOY)
%
% GPS_LS_fix.m solves for the GPS unknowns using pseudo-range
% and Least-Square method (processes only 1 epoch)
%
%in input:
%         - "obs" observation matrix [week sec prn PR D1 S1]
%         - "eph" satellites ephemerides 
%         - "x0" a priori state vector: lat(rad),long(rad),h(meter),offset receiver clock(meter)
%         - "iono_corr" Kloubuchar model parameters for ionospheric correction
%         - "DOY" Day Of Year
%
%in output:
%         - "x" State Vector: lat(rad),long(rad),h(meter),offset receiver clock(meter)
%         - "VCx" x Covariance Matrix  (m^2)
%         - "DOPs" vector of DOPs values : [PDOP_pre_raim; PDOP_post_raim];
%         - "nr_sat" number of sv : [nr_PR_pre_raim; nr_PR_post_raim];
%         - "Flag" solution availability
%                 Flag=1 => fix available,
%                 Flag=0 => fix unavailable (not enough sv or bad geometry)
%         - "Test_Results" solution reliability and number of rejections 
%           Test_Results(1)=position solution reliability,
%                 Test_Results(1)=0 => no redundancy or solution not tested
%                 Test_Results(1)=1 => solution reliable
%                 Test_Results(1)=2 => solution unreliable
%           Test_Results(2)=nr PR rejected, 
%         - "sigma2post" a posteriori variance PR
%         - "PLs" protection levels
%                 PLs(1) HPL 
%                 PLs(2) VPL
%
%function called:
%         - orbital_propagator_GPS0
%         - geo2ecef
%         - ecef2enu
%         - enu2altaz
%         - iono_correction
%         - tropo_correction0
%         - RAIM_Subset
%         - SLOPE
%         - calcN
%         - meridian_radius


global rot_e v_light v_config LambdaChi2 RAIMset sigma_pr

%vettore di configurazione
WEIGHT_flag=v_config(1);
RAIM_flag=v_config(2);

if isempty(iono_corr)
    iono_corr=zeros(2,4);
end
%iono corrections
alfa_corr=iono_corr(1,:); beta_corr=iono_corr(2,:);

%mette in ordine crescente di prn
obs=sortrows(obs,3);

prn=obs(:,3);
tr=unique(obs(:,2));
PR=obs(:,4);

%elimina nan da PR, D1 e eph
prn=prn(~isnan(PR));
PR=PR(~isnan(PR));
eph=eph(:,ismember(eph(1,:),prn));

%number of visible satellites
nr_PR0=sum(~isnan(PR));

% Definition of the output
x=nan(4,1);
VCx=nan(4,4);
DOPs=nan(2,1);
Flag=0; %no fix
Test_Results=[0;0]; %no redundancy, no rejections
nr_sat=[nr_PR0; nr_PR0];
sigma2post=ones(1,1);
PLs=nan(2,1);
IA=[];

%%
%check on the number of visible satellites
if  nr_PR0>=4
    
    Flag=1; %yes fix
    
    x=x0;
    
    %raw epoch of transmission
    tx_raw=tr-PR/v_light;
    
    %satellite position and velocity at transmissione epoch
    [position_ecef,dt_sv]=orbital_propagator_GPS0(eph,tx_raw);
    
    dt_sv_bias=dt_sv(:,1);
    
    %sv coordinates and velocity (ECEF)
    Xs=position_ecef(1,:)';
    Ys=position_ecef(2,:)';
    Zs=position_ecef(3,:)';
    
    nr_PR=nr_PR0;
    dX(1:3)=[1;1;1];
    j=0;
    while norm(dX(1:3))>0.01 && j<100
        j=j+1;

        %
        [Xr,Yr,~]=geo2ecef(x(1),x(2),x(3));
        %Sagnac correction
        dS=rot_e/v_light*(Ys*Xr-Xs*Yr);
        %
        
        %transformation of satellite coordinates and velocity from ECEF to ENU frame
        [Es,Ns,Us]=ecef2enu(Xs,Ys,Zs,x(1),x(2),x(3),'pos');
        
        % a priori range satellite-receiver
        d0=sqrt(Es.^2+Ns.^2+Us.^2);
        
        %trasformation from ENU to Altazimut coordinates
        [el_s,az_s] = enu2altaz(Es,Ns,Us);
        
        %ionospheric delay in meters
        DI=iono_correction(x(1),x(2),el_s,az_s,alfa_corr,beta_corr,tr(1));
        
        %tropospheric error in meters
        DT=tropo_correction0(x(3),x(1),DOY,el_s);
        
        %PR corrected for sv clock error,relativistic effect and atmospheric error
        PR_corr_gps=PR+dt_sv_bias*v_light-DI-DT+dS;
        
        if j==1
            if WEIGHT_flag==0  %no weight
                R_PR=eye(nr_PR);
            elseif WEIGHT_flag==1 %
                R_PR = diag(1./(sin(el_s)).^2);
            end
            W_PR=eye(size(R_PR))/R_PR;
        end
        
        %PR measurements corrected for a priori information
        z=PR_corr_gps-d0-x(4);
        
        %geometry matrix for PR
        H=[(-Es)./d0,(-Ns)./d0,(-Us)./d0,ones(nr_PR,1)];
        
        if j==1
            GDOP_matrix_pre=inv(H'*H);
            PDOP_pre=sqrt(trace(GDOP_matrix_pre(1:3,1:3)));
            DOPs(1)=PDOP_pre;
            if PDOP_pre>30
                Flag=0;
                x=nan(4,1);
                VCx=nan(4,4);
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
            nr_sat(2)=nr_sat(1)-Test_Results(2);
            nr_PR=nr_sat(2);
            [Slope_maxH,Slope_maxV] = SLOPE( HH,WW_PR );
            HPL=Slope_maxH*sigma_pr*sqrt(LambdaChi2(nr_PR-4));
            VPL=Slope_maxV*sigma_pr*sqrt(LambdaChi2(nr_PR-4));
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
        x(3:4)=x(3:4)+dX(3:4);
        
        if  nr_PR0>4
            %residuals
            r=z-H*dX;
            %a posteriori variance
            sigma2post=(r'*W_PR*r)/(nr_PR0-4);
        end
        
        %covariance matrix in m^2, (m/s2)^2, m^2
        %DOP computation
        VCx=sigma2post(1)*inv(H'*W_PR*H);
        GDOP_matrix=inv(H'*H);
        DOPs(2)=sqrt(trace(GDOP_matrix(1:3,1:3)));
        
        if DOPs(2)>30
            Flag=0;
            x=nan(4,1);
            VCx=nan(4,4);
            Test_Results(1)=2;
            return
        end
        
        if j==1 && RAIM_flag==1 && ~isempty(IA)
            Xs(IA)=[];
            Ys(IA)=[];
            Zs(IA)=[];
            dt_sv_bias(IA)=[];
            PR(IA)=[];
        end
        
    end

end