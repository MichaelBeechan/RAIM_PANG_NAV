function TrajectoryPlot(time_vector,Pos,UTM_zone,configuration,ColorLine )

%TrajectoryPlot function plots horizontal trajectory and altitude behaviour
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
%         - PLH2UTM
%         - ticklabelformat
%
%version 0.001 2018/11/29


%ECEF position transformation in UTM coordinates
[N,E,U] = PLH2UTM(Pos(1,:),Pos(2,:),Pos(3,:),UTM_zone);


%time increment for gpslabel input
time_increment=((time_vector(end,1)-time_vector(1,1))/60)/6; %periodo totale diviso in circa 6 intervalli 
time_increment=max([time_increment,1]);

%%%%%%%%%%%%%%%%%%%%%%%%%% Position %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%horizontal trajectory
figure
plot(E,N,'Marker','*','LineWidth',4,'LineStyle','none','Color',ColorLine)%,hold on
axis equal
legend(configuration)
title('Horizontal Position','fontsize',20)
xlabel('m'),ylabel('m')
ticklabelformat(gca,'x','%9.0f')
ticklabelformat(gca,'y','%9.0f')
set(gca,'fontsize',20)

%altitude
figure
plot(time_vector,U,ColorLine),hold on
gpslabel(0,'UTC time',time_increment)
ylabel('m')
legend(configuration)
title('Altitude')
ticklabelformat(gca,'y','%9.0f')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

