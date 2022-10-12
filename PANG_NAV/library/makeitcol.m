function a=makeitcol(b)
%
% MAKEITCOL function makes a generic vector a column vector
%
%in input:
%         - "b" generic vector (row or column)
%
%in output:
%         - "a" column vector
%
%version 0.001 2013/08/27

if size(b,2)==1
   
   a=b;
   
else
  
   a=b';
   
end