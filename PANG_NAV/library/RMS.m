function RMS_a  = RMS( a )
%
%RMS compute Root-Mean-Square of elements of input vector
%
%in input:
%         - "a" vector 
%
%in output:
%         - "RMS_a" Root Mean Square value of vector components in input
%
%note:
%         - "a" can contain nan elements and can be a row or a column
%
%function called:
%
%
%version 0.001 2013/08/29


real_length_a = sum(~isnan(a));
%RMS_a = sqrt((nansum(a.^2))/real_length_a);
RMS_a = sqrt((sum(~isnan(a.^2)))/real_length_a);

