function PLs_Plot(time_vector,PLs)

%ErrorsPlots computes position and velocity ENU errors and generates plots
%
%
%in input:
%         - "time_vector" mx1 epochs(s)
%         - "Pos"  4xm  [lat(rad),long(rad),h(m)]
%         - "UTM_zone"
%         - "configuration" GNSS systems (appears in the legend); example 'GPS'
%         - "ColorLine" plot color; example 'g' 
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

%%%%%%%%%%%%%%%%%%%%%%%% Protection Levels %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
subplot(2,1,1),plot(time_vector,PLs(1,:)),title('HPL')
gpslabel(0,' ',time_increment)
ylabel('m')
ticklabelformat(gca,'y','%9.0f')
subplot(2,1,2),plot(time_vector,PLs(2,:)),title('VPL')
gpslabel(0,'UTC time',time_increment)
ylabel('m')
ticklabelformat(gca,'y','%9.0f')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


