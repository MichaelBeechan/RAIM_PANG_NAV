function VisibilityDOPs_Plot(time_vector,nr_sat,DOPs,RAIM_flag)

%VisibilityDOPs_Plot plots number of visible satellites and DOPs
%
%
%in input:
%         - "time_vector" mx1 epochs(s)
%         - "nr_sat"  2xm  [number of visible SV pre RAIM, number of visible SV post RAIM]
%         - "DOPs" 2xm [PDOP pre RAIM, PDOP post RAIM]
%         - "RAIM_flag", flag about the RAIM status (0=no RAIM, 1=yes RAIM)
%
%in output:
%        
%
%
%function called:
%         - PLH2UTM.m
%         - ticklabelformat.m
%
%version 0.001 2018/11/29



%time increment for gpslabel input
time_increment=((time_vector(end,1)-time_vector(1,1))/60)/6; %periodo totale diviso in circa 6 intervalli 
time_increment=max([time_increment,1]);

if RAIM_flag==1
    
    %%%%%%%%%%%%%%%%%%%%%%%% Visibilità %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure
    plot(time_vector,nr_sat),title('Visibility')
    legend('nr SV pre RAIM','nr SV post RAIM')
    gpslabel(0,'UTC time',time_increment)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% DOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure
    plot(time_vector,DOPs),title('PDOP'),gpslabel(0,' ',120)
    legend('PDOP pre RAIM','PDOP post RAIM')
    gpslabel(0,'UTC time',time_increment)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
else
    
    %%%%%%%%%%%%%%%%%%%%%%%% Visibilità %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure
    plot(time_vector,nr_sat(1,:)),title('Visibility')
    legend('nr SV')
    gpslabel(0,'UTC time',time_increment)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% DOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure
    plot(time_vector,DOPs(1,:)),title('PDOP'),gpslabel(0,' ',120)
    legend('PDOP')
    gpslabel(0,'UTC time',time_increment)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end

    