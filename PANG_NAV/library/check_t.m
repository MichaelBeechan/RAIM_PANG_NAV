function tt = check_t(t)
%
% CHECK_T repairs over- and underflow of GPS time

%in input:
%         - "t" GPS time to be repaired [sec]
%
%in output:
%         - "t" GPS time repaired [sec]
%


half_week = 302400;

tt = t;
if t >  half_week
    tt = t-2*half_week;
end

if t < -half_week
    tt = t+2*half_week; 
end

