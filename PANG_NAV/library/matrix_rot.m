function R=matrix_rot(teta,verso,asse)
%
% matrix_rot computes the basic rotation matrix 
%
%in input:
%         - "teta" angle [radians]
%         - "verso" clockwise or counterclockwise rotation ('O' clockwise) ('A' counterclockwise)
%         - "asse" rotation axis ('x' axis x) ('y' axis y) ('z' axis z)
%
%in output:
%         - "R" rotation matrix
%
%
%version 0.001 2013/07/30


if verso=='A'
    teta=-teta;
elseif verso=='O'
else
    error('errore inserimento verso rotazione')
end

if asse=='x'
   R=[1 0 0;0 cos(teta) -sin(teta);0 sin(teta) cos(teta)];
elseif asse=='y'
   R=[cos(teta) 0 sin(teta);0 1 0;-sin(teta) 0 cos(teta)];
elseif asse=='z'
   R=[cos(teta) -sin(teta) 0;sin(teta) cos(teta) 0;0 0 1];
else
   error('errore inserimento asse rotazione') 
end