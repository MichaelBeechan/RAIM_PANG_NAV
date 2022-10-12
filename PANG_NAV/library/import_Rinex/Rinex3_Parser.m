%RINEX 3 parser


[filename_OBS,directory_OBS] = uigetfile('*.*','select RINEX obs');
filepath_OBS=[directory_OBS,filename_OBS];
[XYZ_station,leap_sec,observations,header,version_rinex]=Rinex3_obs_reader0(filepath_OBS,dt_data);

[filename_Nmix,directory_Nmix] = uigetfile([directory_OBS,'*.*'],'select RINEX mixed nav');
filepath_Nmix=[directory_Nmix,filename_Nmix];
[eph,DOY]=Rinex3_nav_reader_mixed_v003(filepath_Nmix);

[filename_Ngps,directory_Ngps] = uigetfile([directory_OBS,'*.*'],'select RINEX gps nav');
filepath_Ngps=[directory_Ngps,filename_Ngps];
[~,iono_corr_klo,~]=Rinex3_nav_reader_G(filepath_Ngps);

iono_corr.klo=iono_corr_klo;
