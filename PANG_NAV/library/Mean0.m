function mean_x = Mean0(x)
%Mean0 computes the mean of the elements of vector x, even in case of nan

m=sum(~isnan(x));

mean_x=sum(x(~isnan(x)))/m;

end

