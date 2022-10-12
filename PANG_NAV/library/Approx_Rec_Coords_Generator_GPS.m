function LLH_Approx_Rec_Coords = Approx_Rec_Coords_Generator_GPS(eph_GPS,obs_GPS)
%
%Preliminary_Check_GPS.m performs a prelimary check on GPS measurement set
%(single epoch) to screen out low satellites (below a defined mask angle), 
%weak signals (below a defined S/N threshold) and cases where ephemeris or
%observations are missing
%
%in input:
%         - "eph_GPS" GPS ephemerides (multiple sv and epochs) 
%         - "obs_GPS" GPS observations (single epoch) 
%
%in output:
%         - "LLH_Approx_Rec_Coords" approximate receiver coordinates (Latitudie [rad], Longitude [rad], Height [meters])
%
%
%function called:
%         - orbital_propagator_GPS.m
%         - ecef2geo.m
%
%
%version 0.001 2013/08/29




%%%%%%%%%%%%%%%%%%%% GPS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LLH_Approx_Rec_Coords=[0,0,0];

if ~isempty(obs_GPS)
    
    %reception epoch
    t_obs=obs_GPS(1,2);
    
    %intersection between observed sv and sv with ephemerides
    prn_GPS=intersect(eph_GPS(1,:),obs_GPS(:,3));
    
    %cut-off eph without observations
    eph_GPS=eph_GPS(:,ismember(eph_GPS(1,:),prn_GPS));
    
    %sv nr before rejections
    nr_sv_GPS1=length(prn_GPS);
    
    if nr_sv_GPS1>0

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
        
        [Lat_sat_GPS,Lon_sat_GPS,~]=ecef2geo(Xs_GPS,Ys_GPS,Zs_GPS);
        
        LLH_Approx_Rec_Coords(1)=Mean0(Lat_sat_GPS);
        LLH_Approx_Rec_Coords(2)=Mean0(Lon_sat_GPS);
        LLH_Approx_Rec_Coords(3)=0;
               
    end
    
end

        
