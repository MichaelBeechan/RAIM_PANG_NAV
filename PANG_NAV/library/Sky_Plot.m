function Sky_Plot( el,az,prn )
%SKY_PLOT Summary of this function goes here
%   Detailed explanation goes here

el=makeitcol(el);
az=makeitcol(az);

H=[cos(el).*sin(az),cos(el).*cos(az),sin(el),ones(size(el))];
GDOP_matrix=inv(H'*H);
GDOP=sqrt(trace(GDOP_matrix));
PDOP=sqrt(trace(GDOP_matrix(1:3,1:3)));
HDOP=sqrt(trace(GDOP_matrix(1:2,1:2)));
EDOP=sqrt(trace(GDOP_matrix(1,1)));
NDOP=sqrt(trace(GDOP_matrix(2,2)));
VDOP=sqrt(trace(GDOP_matrix(3,3)));
TDOP=sqrt(trace(GDOP_matrix(4,4)));

teta=0:0.01:2*pi;
x0=cos(teta); y0=sin(teta);
x30=cosd(30)*cos(teta); y30=cosd(30)*sin(teta);
x60=cosd(60)*cos(teta); y60=cosd(60)*sin(teta);
xhor=[-1,1]; yhor=[0,0];
xver=[0,0]; yver=[-1,1];
figure
plot(x0,y0,'r',x30,y30,'r',x60,y60,'r',xhor,yhor,'r',xver,yver,'r')
set(gca,'Color','k')
%
axis([-1.1 1.1 -1.1 1.1])
axis equal
set(gca,'XTick',[],'YTick',[])

x_sat=cos(el).*sin(az); y_sat=cos(el).*cos(az);
hold on
plot(x_sat,y_sat,'y.','markersize',25)
 

for i=1:length(prn)
    hold on
    text(x_sat(i)+0.05,y_sat(i),num2str(prn(i)),'color','w','fontsize',15)
end

GDOP_str=['GDOP=',num2str(GDOP),';  PDOP=',num2str(PDOP),';  HDOP=',num2str(HDOP),';  EDOP=',num2str(EDOP),';  NDOP=',num2str(NDOP),';  VDOP=',num2str(VDOP),';  TDOP=',num2str(TDOP)];
annotation('textbox',[0.27 0 0.1 0.1],'String',GDOP_str)

text(0,1.05,'N','fontsize',15,'color','w') 
text(0,-1.05,'S','fontsize',15,'color','w') 
text(1.01,0,'E','fontsize',15,'color','w') 
text(-1.09,0,'W','fontsize',15,'color','w') 
