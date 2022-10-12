function [eph,iono_corr,DOY]=Rinex3_nav_reader_G(ephemerisfile)
%

eph_gps=[];

iono_corr=[];

DOY=[];

fide = fopen(ephemerisfile);

%flag_iono_corr=0; %no iono corrections

head_lines = 0;
% il blocco while serve per saltare la testata(=header)
while 1  % We skip header
    head_lines = head_lines+1;
    % fgetl legge le righe del file cui si riferisce il suo argomento
    line = fgetl(fide);
    % individuazione dei parametri ionosferici nella testata
    ALFA=findstr(line,'GPSA');
    if ~isempty(ALFA)
        iono_corr_1=str2num(line(8:60));
    end
    BETA=findstr(line,'GPSB');
    if ~isempty(BETA)
        iono_corr_2=str2num(line(8:60));
        iono_corr = [iono_corr_1;iono_corr_2];
    end

    answer = findstr(line,'END OF HEADER');
    
    if ~isempty(answer)
        break
    end
end



nr_eph_gps=0;

while ~feof(fide) 
    line = fgetl(fide);
    if ~isempty(line) %patch del 17 maggio 2019 per funzionare anche in presenza di righe vuote
        if line(1)=='G'
            nr_eph_gps=nr_eph_gps+1;
        end
    end
end

frewind(fide); % riavvolge il file (quindi fgetl ricomincia e selezionare dalla prima riga del file)
% il ciclo for scorre tutte le righe della testata
for i = 1:head_lines
    line = fgetl(fide);
end

% inizializzazione delle variabili
if nr_eph_gps>0
    svprn_gps      = zeros(1,nr_eph_gps);
    year_toc_gps   = zeros(1,nr_eph_gps);
    month_toc_gps  = zeros(1,nr_eph_gps);
    day_toc_gps    = zeros(1,nr_eph_gps);
    hour_toc_gps   = zeros(1,nr_eph_gps);
    minute_toc_gps = zeros(1,nr_eph_gps);
    second_toc_gps = zeros(1,nr_eph_gps);
    week_toc_gps   = zeros(1,nr_eph_gps);
    toc_gps        = zeros(1,nr_eph_gps);
    af0_gps        = zeros(1,nr_eph_gps);
    af1_gps        = zeros(1,nr_eph_gps);
    af2_gps        = zeros(1,nr_eph_gps);
    tgd_gps        = zeros(1,nr_eph_gps);
    iodc_gps	   = zeros(1,nr_eph_gps);
    iode_gps	   = zeros(1,nr_eph_gps);
    deltan_gps	   = zeros(1,nr_eph_gps);
    M0_gps	       = zeros(1,nr_eph_gps);
    ecc_gps	       = zeros(1,nr_eph_gps);
    roota_gps	   = zeros(1,nr_eph_gps);
    toe_gps	       = zeros(1,nr_eph_gps);
    cic_gps	       = zeros(1,nr_eph_gps);
    crc_gps	       = zeros(1,nr_eph_gps);
    cis_gps	       = zeros(1,nr_eph_gps);
    crs_gps	       = zeros(1,nr_eph_gps);
    cuc_gps	       = zeros(1,nr_eph_gps);
    cus_gps	       = zeros(1,nr_eph_gps);
    Omega0_gps	   = zeros(1,nr_eph_gps);
    omega_gps	   = zeros(1,nr_eph_gps);
    i0_gps	       = zeros(1,nr_eph_gps);
    Omegadot_gps   = zeros(1,nr_eph_gps);
    idot_gps	   = zeros(1,nr_eph_gps);
    week_toe_gps   = zeros(1,nr_eph_gps);
    URA_gps        = zeros(1,nr_eph_gps);
    health_gps	   = zeros(1,nr_eph_gps);
    fit_gps	       = zeros(1,nr_eph_gps);
    TTimeMsg_gps   = zeros(1,nr_eph_gps);
    codes_gps      = zeros(1,nr_eph_gps);
    L2flag_gps     = zeros(1,nr_eph_gps);
    spare1_gps     = zeros(1,nr_eph_gps);
    spare2_gps     = zeros(1,nr_eph_gps);
end

i_gps=0;

% il ciclo for individua i parametri nel file rinex
for i = 1:nr_eph_gps
    line = fgetl(fide);	  %%
    %if ~isempty(line)
    
    if line(1)=='G'
        i_gps=i_gps+1;
        svprn_gps(i_gps) = str2double(line(2:3));
        
        year_toc_gps(i_gps) = str2double(line(5:8));
        month_toc_gps(i_gps) = str2double(line(10:11));
        day_toc_gps(i_gps) = str2double(line(13:14));
        hour_toc_gps(i_gps) = str2double(line(16:17));
        minute_toc_gps(i_gps) = str2double(line(19:20));
        second_toc_gps(i_gps) = str2double(line(22:23));
        [toc_gps(i_gps),week_toc_gps(i_gps)]=Date2GPSTime(year_toc_gps(i_gps),month_toc_gps(i_gps),day_toc_gps(i_gps),hour_toc_gps(i_gps)+minute_toc_gps(i_gps)/60+second_toc_gps(i_gps)/3600);
        
        af0_gps(i_gps) = str2num(line(24:42));
        af1_gps(i_gps) = str2num(line(43:61));
        af2_gps(i_gps) = str2num(line(62:80));
        
        line = fgetl(fide);	  %%
        
        iode_gps(i_gps) = str2num(line(5:23));
        crs_gps(i_gps) = str2num(line(24:42));
        deltan_gps(i_gps) = str2num(line(43:61));
        M0_gps(i_gps) = str2num(line(62:80));
        
        line = fgetl(fide);	  %%
        
        cuc_gps(i_gps) = str2num(line(5:23));
        ecc_gps(i_gps) = str2num(line(24:42));
        cus_gps(i_gps) = str2num(line(43:61));
        roota_gps(i_gps) = str2num(line(62:80));
        
        line=fgetl(fide);      %%
        
        toe_gps(i_gps) = str2num(line(2:23));
        cic_gps(i_gps) = str2num(line(24:42));
        Omega0_gps(i_gps) = str2num(line(43:61));
        cis_gps(i_gps) = str2num(line(62:80));
        
        line = fgetl(fide);	   %%
        
        i0_gps(i_gps) =  str2num(line(5:23));
        crc_gps(i_gps) = str2num(line(24:42));
        omega_gps(i_gps) = str2num(line(43:61));
        Omegadot_gps(i_gps) = str2num(line(62:80));
        
        line = fgetl(fide);	    %%
        line(81)='x';
        
        idot_gps(i_gps) = str2num(line(5:23));
        codes_gps(i_gps) = str2num(line(24:42));
        week_toe_gps(i_gps) = str2num(line(43:61));
        L2flag_gps(i_gps) = str2num(line(62:80));
        
        line = fgetl(fide);	    %%
        line(81)='x';
        URA_gps(i_gps) = str2num(line(5:23));
        health_gps(i_gps) = str2num(line(24:42));
        tgd_gps(i_gps) = str2num(line(43:61));
        iodc_gps(i_gps) = str2num(line(62:80));
        
        line = fgetl(fide);	    %%
        line(81)='x';
        TTimeMsg_gps(i_gps) = str2num(line(5:23));
        if isempty(str2num(line(24:42)))
            fit_gps(i_gps)=nan;
        else
            fit_gps(i_gps) = str2num(line(24:42));
        end
        if ~isempty(str2num(line(43:61)))
            spare1_gps(i_gps) = str2num(line(43:61));
            spare2_gps(i_gps) = str2num(line(62:80));
        end

    end

end
% fclose chiude il file con identificatore fide, aperto da fopen
fclose(fide) ;


if nr_eph_gps>0
    eph_gps(1,:)  = svprn_gps;
    eph_gps(2,:)  = week_toc_gps;
    eph_gps(3,:)  = toc_gps;
    eph_gps(4,:)  = af0_gps;
    eph_gps(5,:)  = af1_gps;
    eph_gps(6,:)  = af2_gps;
    eph_gps(7,:)  = iode_gps;
    eph_gps(8,:)  = crs_gps;
    eph_gps(9,:)  = deltan_gps;
    eph_gps(10,:) = M0_gps;
    eph_gps(11,:) = cuc_gps;
    eph_gps(12,:) = ecc_gps;
    eph_gps(13,:) = cus_gps;
    eph_gps(14,:) = roota_gps;
    eph_gps(15,:) = toe_gps;
    eph_gps(16,:) = cic_gps;
    eph_gps(17,:) = Omega0_gps;
    eph_gps(18,:) = cis_gps;
    eph_gps(19,:) = i0_gps;
    eph_gps(20,:) = crc_gps;
    eph_gps(21,:) = omega_gps;
    eph_gps(22,:) = Omegadot_gps;
    eph_gps(23,:) = idot_gps;
    eph_gps(24,:) = codes_gps;
    eph_gps(25,:) = week_toe_gps;
    eph_gps(26,:) = L2flag_gps;
    eph_gps(27,:) = URA_gps;
    eph_gps(28,:) = health_gps;
    eph_gps(29,:) = tgd_gps;
    eph_gps(30,:) = iodc_gps;
    eph_gps(31,:) = TTimeMsg_gps;
    eph_gps(32,:) = fit_gps;
end


%day of the year
if nr_eph_gps>0
    DOY=Date2DayOfYear(year_toc_gps(end),month_toc_gps(end),day_toc_gps(end));
end

eph.gps=eph_gps;



