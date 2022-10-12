function [eph_GPS,obs_GPS,nr_sv_excl] = Preliminary_Check_GPS(eph_GPS,obs_GPS,x0)
%
%Preliminary_Check_GPS.m performs a prelimary check on GPS measurement set
%(single epoch) to screen out low satellites (below a defined mask angle), 
%weak signals (below a defined S/N threshold) and cases where ephemeris or
%observations are missing
%
%in input:
%         - "eph_GPS" GPS ephemerides (multiple sv and epochs) 
%         - "obs_GPS" GPS observations (single epoch) 
%         - "x0" aproximate receiver LLH coordinates [rad,rad,meter]
%
%in output:
%         - "eph_GPS" selected GPS ephemerides (1 sv --> 1 ephemerides set) 
%         - "obs_GPS" selected GPS observations 
%         - "nr_sv_excl" number of excluded sv
%
%
%function called:
%         - orbital_propagator_GPS.m
%         - ecef2enu.m
%         - enu2altaz.m
%
%
%version 0.001 2013/08/29


global mask_angle SNR_lim


max_time_propagation_GPS=7200; %sec

nr_sv_GPS0=size(obs_GPS,1);
%nr_sv_GPS0=0;
nr_sv_GPS2=0;

%%%%%%%%%%%%%%%%%%%% GPS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(obs_GPS)
    
    %sorting for prn number
    obs_GPS=sortrows(obs_GPS);
    
    %reception epoch
    t_obs=obs_GPS(1,2);
    
    %rejection old eph
    eph_GPS=eph_GPS(:,abs(eph_GPS(15,:)-t_obs)<=max_time_propagation_GPS);
    
    %intersection between observed sv and sv with ephemerides
    prn_GPS=intersect(eph_GPS(1,:),obs_GPS(:,3));
    
    %selection of only sv with ephemerides
    obs_GPS=obs_GPS(ismember(obs_GPS(:,3),prn_GPS),:);
    
    %cut-off eph without observations
    eph_GPS=eph_GPS(:,ismember(eph_GPS(1,:),prn_GPS));
    
    %sv nr before rejections
    nr_sv_GPS1=length(prn_GPS);
    
    if nr_sv_GPS1>0
        %check on prn and toe to consider only one ephemeris set for each satellite
        %(the criterium is choice the ephemeris nearest to the time of interest t_obs)
        eph_sel=nan(size(eph_GPS,1),nr_sv_GPS1);
        for i=1:nr_sv_GPS1
            eph_1sv=eph_GPS(:,eph_GPS(1,:)==prn_GPS(i));
            [~,i_mnm]=min(abs(t_obs-eph_1sv(15,:)));
            eph_sel(:,i)=eph_1sv(:,i_mnm); 
        end
        eph_GPS=eph_sel(:,~isnan(eph_sel(1,:)));
        
        %sv coordinates and velocity (ECEF)
        [position_ecef]=orbital_propagator_GPS0(eph_GPS,t_obs);
        Xs_GPS=position_ecef(1,:);
        Ys_GPS=position_ecef(2,:);
        Zs_GPS=position_ecef(3,:);
        
        %transformation of satellite coordinates and velocity from ECEF to ENU frame
        [Es_GPS,Ns_GPS,Us_GPS]=ecef2enu(Xs_GPS,Ys_GPS,Zs_GPS,x0(1),x0(2),x0(3),'pos');
        
        %trasformation from ENU to Altazimut coordinates
        [el_GPS,~] = enu2altaz(Es_GPS,Ns_GPS,Us_GPS);
        
        %cut-off low sv
        obs_GPS = obs_GPS(el_GPS>mask_angle,:);
        eph_GPS = eph_GPS(:,ismember(eph_GPS(1,:),obs_GPS(:,3)));
        
        nr_sv_GPS2=size(obs_GPS,1);
        
    end
    
    % SNR control
    if ~isnan(obs_GPS(:,6))
        SNR_GPS=obs_GPS(:,6);
        obs_GPS = obs_GPS(SNR_GPS>SNR_lim,:);
        eph_GPS = eph_GPS(:,ismember(eph_GPS(1,:),obs_GPS(:,3)));
        nr_sv_GPS2=size(obs_GPS,1);
    end
    
end


%output
nr_sv_excl=nr_sv_GPS0-nr_sv_GPS2; 
        
