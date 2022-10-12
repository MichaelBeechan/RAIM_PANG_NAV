function gpslabel(UTC_offset, x_axis_label, time_increment, y_offset, FontSize)
% gpslabel(UTC_offset, x_axis_label, time_increment, y_offset, FontSize)
%
% Generates a label which includes both GPS week seconds and local
% time (HH:MM) on the x-axis.  Will work for bottom row of subplots.
% This routine works best immediately after plotting the figure.  Results
% are unpredictable if the routine is run again before replotting.
%
% UTC_offset - Number of hours between UTC and local time (W is negative)
% x_axis_label - label to place on x-axis (such as "GPS Time")
% time_increment - increment in minutes between x-axis ticks and labels
% y_offset(optional) - additional offset for x-axis labeling (default is 0)
% FontSize(optional) - sets size of labelling font (defaults is 12)
%
% Written by John Raquet, 1995

if nargin<4
  y_offset=0;
end

if nargin<5
   FontSize=10;
end

h=gca;

% resize as necessary to put extra labeling into figure
sp=get(gcf,'Children');
Inches_To_Reclaim=.1+(FontSize-12)*0.02;
m=length(sp);
share=Inches_To_Reclaim/m;
for j=1:m
   k=m+1-j;
   set(sp(k),'Units','inches');
   Pos=get(sp(k),'Position');
   MoveUp=(j-1)*share;
   Shrink=share;
   set(sp(k),'Position',[Pos(1),Pos(2)+MoveUp+Shrink,Pos(3),Pos(4)-Shrink]);
   set(sp(k),'Units','normalized');
end;

% Adjust time increments
increment=time_increment*60;
current_limits=get(h,'XLim');
count=0;
for j=current_limits(1):increment:current_limits(2)
   count=count+1;
   XTickNew(count)=j;
end
set(h,'XTick',XTickNew);
relabel1('x','%6.0f')

times=get(h,'XTick');
n=length(times);

% Compensate for local time offset from UTC
times=times+ones(1,n)*UTC_offset*3600;

% Calculate y position for labels
TimeOffset=.2;
LabelOffset=.4;
set(h,'Units','inches');
Position=get(h,'Position');
YLim=get(h,'YLim');
DY=diff(YLim);
UnitsPerInch=DY/Position(4);
TimeYValue=YLim(1)-TimeOffset*UnitsPerInch-y_offset-(FontSize-12)*0.02*UnitsPerInch;
LabelYValue=YLim(1)-LabelOffset*UnitsPerInch-y_offset-(FontSize-12)*0.03*UnitsPerInch;
set(h,'Units','normalized');

for j=1:n

   % Get hour/minute string
   sec_since_midnight=fix(rem(times(j),86400));
   % check for negative time
   if sec_since_midnight<0
      sec_since_midnight = sec_since_midnight + 86400.0;
   end
   hour=fix(sec_since_midnight/3600);
   if hour==0
      minute=round(sec_since_midnight)/60;
   else
      minute=round(rem(sec_since_midnight,hour*3600)/60);
   end
   if hour<10
      hour_string=['0',int2str(hour)];
   else
      hour_string=int2str(hour);
   end
   if minute<10
      minute_string=['0',int2str(minute)];
   else
      minute_string=int2str(minute);
   end
   time_string=[hour_string,':',minute_string];
   tlabel(j)=text(XTickNew(j),TimeYValue,time_string);
   set(tlabel(j),'HorizontalAlignment','center');
   set(tlabel(j),'VerticalAlignment','top');
   set(tlabel(j),'FontSize',FontSize);
end

% Display axis label
XLim=get(h,'XLim');
xlabel_text=text(mean(XLim),LabelYValue,x_axis_label);
set(xlabel_text,'HorizontalAlignment','center');
set(xlabel_text,'VerticalAlignment','top');
set(xlabel_text,'FontSize',FontSize);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function relabel1(ax,h,prec)
% REXPLAB(AX) removes the exponent from the axis specified
% by AX.  AX can be 'x', 'y', or 'z'.
%
% REXPLAB(AX,H) removes the exponent from the AX axis in the
% axes whose handle is H.
%
% REXPLAB(AX,PREC), REXPLAB(AX,H,PREC) allows you to specify the
% precision.  For example, '%4.2f'.  See help for sprintf for 
% precision formats.
%
% EXAMPLE:
%
%    plot(1:100:100000)
%    rexplab('y','%d')
%
% NOTE:  Requires the M-files mat2str.m.

% This M-file has not been tested by The MathWorks,Inc., and 
% therefore, it is not supported.

% Written by John L. Galenski III
% All Rights Reserved  05-11-94
% LDM081695jlg

% Parse the inputs
if nargin == 1
  h = gca;
  prec = '%6.2f';  % Default precision
end

if nargin == 2 % See if axes handle or precision is given
  if isstr(h)
    prec = h;
        h = gca;
  end
end

prec = [prec,'\n'];  % Append new-line

ax = lower(ax);
if strcmp(ax,'x') | strcmp(ax,'y') | strcmp(ax,'z')
  tic = eval(['get(h,''',ax,'Tick'')']);
  ticl = sprintf(prec,tic);
  ticl=to_array1(ticl);
  reset_cmd=['set(h,''',ax,'TickLabel'',ticl)'];
  eval(reset_cmd)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function array_out=to_array1(string_in)
% function array_out=to_array1(string_in)

s=double(string_in);
nrows=length(find(s==10));
num_cols_for_row=zeros(nrows+1,1);
max_cols=0;
n_cols=0;
current_row=1;
for j=1:length(s)
  if s(j)==10
    if n_cols > max_cols
      max_cols=n_cols;
    end
    num_cols_for_row(current_row)=n_cols;
    n_cols=0;
    current_row=current_row+1;
  else
    n_cols=n_cols+1;
  end
end

s_out=32*ones(nrows, max_cols);
current_row=1;
current_col=max_cols+1-num_cols_for_row(current_row);
for j=1:length(s)
  if s(j)==10
    current_row=current_row+1;
    current_col=max_cols+1-num_cols_for_row(current_row);
  else
    s_out(current_row, current_col)=s(j);
    current_col=current_col+1;
  end
end

%array_out=string(s_out);
array_out=char(s_out);







