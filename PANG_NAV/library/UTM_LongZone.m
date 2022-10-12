function LongZone = UTM_LongZone(Lat_deg)
%UTM_LongZone computes UTM longitude zone from longitude (in degrees)

LongZone=ceil((Lat_deg+180)/6);

end

