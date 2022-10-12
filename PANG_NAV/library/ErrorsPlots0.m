function [e_H,e_U,Error_Table_Pos]=ErrorsPlots0( solution,X,UTM_zone,configuration,ColorLine )

%ErrorsPlots computes position and velocity ENU errors and generates plots
%
%
%in input:
%         - "solution" mx4 [epochs(s),lat(deg),long(deg),h(m)]
%         - "X"  4xm  [lat(rad),long(rad),h(m),cdt(m)] or 5xm  [lat(rad),long(rad),h(m),cdt(m),cdt_sys(m)]
%         - "UTM_zone"
%         - "configuration" GNSS systems (appears in the legend); example 'GPS'
%         - "ColorLine" plot color; example 'g' 
%
%in output:
%         - "e_H" mx1 horizontal error (m)
%         - "e_U" mx1 vertical error (m)
%         - "Error_Table_Pos" table of position error [mean Hor,mean Up, RMS Hor,RMS Up,max Hor,max Up]
%
%
%function called:
%         - PLH2UTM.m
%         - ENU_Errors.m
%         - ticklabelformat.m
%
%version 0.001 2014/08/28


%ECEF position transformation in UTM coordinates
[N_true,E_true,U_true] = PLH2UTM(deg2rad(solution(:,2)),deg2rad(solution(:,3)),solution(:,4),UTM_zone);
[N,E,U] = PLH2UTM(X(1,:),X(2,:),X(3,:),UTM_zone);

%ENU Position Errors
[e_H,e_U,Error_Table_Pos] = ENU_Errors( E,N,U, E_true,N_true,U_true );


%time increment for gpslabel input
time_increment=((solution(end,1)-solution(1,1))/60)/6; %periodo totale diviso in circa 6 intervalli 


%%%%%%%%%%%%%%%%%%%%%%%%%% Errors %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
g(1)=subplot(2,1,1);plot(solution(:,1),e_H,ColorLine),legend(configuration),gpslabel(0,' ',time_increment),title('Horizontal Error'),ylabel('m')
g(2)=subplot(2,1,2);plot(solution(:,1),e_U,ColorLine),legend(configuration),gpslabel(0,'UTC time',time_increment),title('Vertical Error'),ylabel('m')
linkaxes(g,'x')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
