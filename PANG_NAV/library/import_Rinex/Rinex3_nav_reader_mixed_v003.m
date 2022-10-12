function [eph,DOY]=Rinex3_nav_reader_mixed_v003(ephemerisfile)
%


eph_gps=[];
eph_gal=[];
eph_glo=[];
eph_sba=[];
eph_com=[];
menoTauC_glo=nan;


fide = fopen(ephemerisfile);


head_lines = 0;
% il blocco while serve per saltare la testata(=header)
while 1  %
    head_lines = head_lines+1;
    % 
    line = fgetl(fide);
    
    t=findstr(line,'TIME SYSTEM CORR');
    if ~isempty(t) && line(2)=='L'
        menoTauC_glo=str2num(line(6:22));
    end
    
    answer = findstr(line,'END OF HEADER');
    
    if ~isempty(answer)
        break
    end
end


nr_eph_gps=0;
nr_eph_glo=0;
nr_eph_gal=0;
nr_eph_sba=0;
nr_eph_com=0;
nr_eph_qzs=0;


while ~feof(fide) 
    line = fgetl(fide);
    if ~isempty(line) %patch del 17 maggio 2019 per funzionare anche in presenza di righe vuote
        if line(1)=='R'
            nr_eph_glo=nr_eph_glo+1;
        elseif line(1)=='E'
            nr_eph_gal=nr_eph_gal+1;
        elseif line(1)=='G'
            nr_eph_gps=nr_eph_gps+1;
        elseif line(1)=='C'
            nr_eph_com=nr_eph_com+1;
        elseif line(1)=='S'
            nr_eph_sba=nr_eph_sba+1;
        elseif line(1)=='J'
            nr_eph_qzs=nr_eph_qzs+1;
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

if nr_eph_gal>0
    svprn_gal      = zeros(1,nr_eph_gal);
    year_toc_gal   = zeros(1,nr_eph_gal);
    month_toc_gal  = zeros(1,nr_eph_gal);
    day_toc_gal    = zeros(1,nr_eph_gal);
    hour_toc_gal   = zeros(1,nr_eph_gal);
    minute_toc_gal = zeros(1,nr_eph_gal);
    second_toc_gal = zeros(1,nr_eph_gal);
    week_toc_gal   = zeros(1,nr_eph_gal);
    toc_gal        = zeros(1,nr_eph_gal);
    af0_gal        = zeros(1,nr_eph_gal);
    af1_gal        = zeros(1,nr_eph_gal);
    af2_gal        = zeros(1,nr_eph_gal);
    iod_gal  	   = zeros(1,nr_eph_gal);
    toe_gal	       = zeros(1,nr_eph_gal);
    deltan_gal	   = zeros(1,nr_eph_gal);
    M0_gal	       = zeros(1,nr_eph_gal);
    ecc_gal	       = zeros(1,nr_eph_gal);
    roota_gal	   = zeros(1,nr_eph_gal);
    cic_gal	       = zeros(1,nr_eph_gal);
    crc_gal	       = zeros(1,nr_eph_gal);
    cis_gal	       = zeros(1,nr_eph_gal);
    crs_gal	       = zeros(1,nr_eph_gal);
    cuc_gal	       = zeros(1,nr_eph_gal);
    cus_gal	       = zeros(1,nr_eph_gal);
    Omega0_gal	   = zeros(1,nr_eph_gal);
    omega_gal	   = zeros(1,nr_eph_gal);
    i0_gal	       = zeros(1,nr_eph_gal);
    Omegadot_gal   = zeros(1,nr_eph_gal);
    idot_gal	   = zeros(1,nr_eph_gal);
    data_source_gal= zeros(1,nr_eph_gal);
    week_toe_gal   = zeros(1,nr_eph_gal);
    URA_gal        = zeros(1,nr_eph_gal);
    health_gal	   = zeros(1,nr_eph_gal);
    BGD_E5aE1_gal  = zeros(1,nr_eph_gal);
    BGD_E5bE1_gal  = zeros(1,nr_eph_gal);
    TTimeMsg_gal   = zeros(1,nr_eph_gal);
    spare1_gal     = zeros(1,nr_eph_gal);
    spare2_gal     = zeros(1,nr_eph_gal);
    spare3_gal     = zeros(1,nr_eph_gal);
    spare4_gal     = zeros(1,nr_eph_gal);
end

if nr_eph_glo>0
    slot_sv_glo           = zeros(1,nr_eph_glo);
    year_toe_glo          = zeros(1,nr_eph_glo);
    month_toe_glo         = zeros(1,nr_eph_glo);
    day_toe_glo           = zeros(1,nr_eph_glo);
    hour_toe_glo          = zeros(1,nr_eph_glo);
    min_toe_glo           = zeros(1,nr_eph_glo);
    sec_toe_glo           = zeros(1,nr_eph_glo);
    week_glo              = zeros(1,nr_eph_glo);
    toe_glo               = zeros(1,nr_eph_glo);
    sv_clock_bias_glo     = zeros(1,nr_eph_glo);
    sv_rel_freq_bias_glo  = zeros(1,nr_eph_glo);
    m_f_t_glo             = zeros(1,nr_eph_glo);
    X_glo                 = zeros(1,nr_eph_glo);
    Xdot_glo              = zeros(1,nr_eph_glo);
    Xacc_glo              = zeros(1,nr_eph_glo);
    health_glo            = zeros(1,nr_eph_glo);
    Y_glo                 = zeros(1,nr_eph_glo);
    Ydot_glo              = zeros(1,nr_eph_glo);
    Yacc_glo              = zeros(1,nr_eph_glo);
    freq_num_glo          = zeros(1,nr_eph_glo);
    Z_glo                 = zeros(1,nr_eph_glo);
    Zdot_glo              = zeros(1,nr_eph_glo);
    Zacc_glo              = zeros(1,nr_eph_glo);
    age_oper_info_glo     = zeros(1,nr_eph_glo);
end

if nr_eph_sba>0
    slot_sv_sba           = zeros(1,nr_eph_sba);
    year_toe_sba          = zeros(1,nr_eph_sba);
    month_toe_sba         = zeros(1,nr_eph_sba);
    day_toe_sba           = zeros(1,nr_eph_sba);
    hour_toe_sba          = zeros(1,nr_eph_sba);
    min_toe_sba           = zeros(1,nr_eph_sba);
    sec_toe_sba           = zeros(1,nr_eph_sba);
    week_sba              = zeros(1,nr_eph_sba);
    toe_sba               = zeros(1,nr_eph_sba);
    sv_clock_bias_sba     = zeros(1,nr_eph_sba);
    sv_rel_freq_bias_sba  = zeros(1,nr_eph_sba);
    m_f_t_sba             = zeros(1,nr_eph_sba);
    X_sba                 = zeros(1,nr_eph_sba);
    Xdot_sba              = zeros(1,nr_eph_sba);
    Xacc_sba              = zeros(1,nr_eph_sba);
    health_sba            = zeros(1,nr_eph_sba);
    Y_sba                 = zeros(1,nr_eph_sba);
    Ydot_sba              = zeros(1,nr_eph_sba);
    Yacc_sba              = zeros(1,nr_eph_sba);
    freq_num_sba          = zeros(1,nr_eph_sba);
    Z_sba                 = zeros(1,nr_eph_sba);
    Zdot_sba              = zeros(1,nr_eph_sba);
    Zacc_sba              = zeros(1,nr_eph_sba);
    age_oper_info_sba     = zeros(1,nr_eph_sba);
    menoTauC_sba          = 0;
end

if nr_eph_com>0
    svprn_com      = zeros(1,nr_eph_com);
    year_toc_com   = zeros(1,nr_eph_com);
    month_toc_com  = zeros(1,nr_eph_com);
    day_toc_com    = zeros(1,nr_eph_com);
    hour_toc_com   = zeros(1,nr_eph_com);
    minute_toc_com = zeros(1,nr_eph_com);
    second_toc_com = zeros(1,nr_eph_com);
    week_toc_com   = zeros(1,nr_eph_com);
    toc_com        = zeros(1,nr_eph_com);
    af0_com        = zeros(1,nr_eph_com);
    af1_com        = zeros(1,nr_eph_com);
    af2_com        = zeros(1,nr_eph_com);
    tgd_com        = zeros(1,nr_eph_com);
    iodc_com	   = zeros(1,nr_eph_com);
    iode_com	   = zeros(1,nr_eph_com);
    deltan_com	   = zeros(1,nr_eph_com);
    M0_com	       = zeros(1,nr_eph_com);
    ecc_com	       = zeros(1,nr_eph_com);
    roota_com	   = zeros(1,nr_eph_com);
    toe_com	       = zeros(1,nr_eph_com);
    cic_com	       = zeros(1,nr_eph_com);
    crc_com	       = zeros(1,nr_eph_com);
    cis_com	       = zeros(1,nr_eph_com);
    crs_com	       = zeros(1,nr_eph_com);
    cuc_com	       = zeros(1,nr_eph_com);
    cus_com	       = zeros(1,nr_eph_com);
    Omega0_com	   = zeros(1,nr_eph_com);
    omega_com	   = zeros(1,nr_eph_com);
    i0_com	       = zeros(1,nr_eph_com);
    Omegadot_com   = zeros(1,nr_eph_com);
    idot_com	   = zeros(1,nr_eph_com);
    week_toe_com   = zeros(1,nr_eph_com);
    URA_com        = zeros(1,nr_eph_com);
    health_com	   = zeros(1,nr_eph_com);
    fit_com	       = zeros(1,nr_eph_com);
    TTimeMsg_com   = zeros(1,nr_eph_com);
    codes_com      = zeros(1,nr_eph_com);
    L2flag_com     = zeros(1,nr_eph_com);
    spare1_com     = zeros(1,nr_eph_com);
    spare2_com     = zeros(1,nr_eph_com);
end

i_gps=0;
i_gal=0;
i_glo=0;
i_com=0;
i_sba=0;

% il ciclo for individua i parametri nel file rinex
for i = 1:(nr_eph_gps+nr_eph_gal+nr_eph_glo+nr_eph_sba+nr_eph_com+nr_eph_qzs)
    line = fgetl(fide);	  %%
    
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

    
    elseif line(1)=='E'
        i_gal=i_gal+1;
        svprn_gal(i_gal) = str2double(line(2:3));
        
        year_toc_gal(i_gal) = str2double(line(5:8));
        month_toc_gal(i_gal) = str2double(line(10:11));
        day_toc_gal(i_gal) = str2double(line(13:14));
        hour_toc_gal(i_gal) = str2double(line(16:17));
        minute_toc_gal(i_gal) = str2double(line(19:20));
        second_toc_gal(i_gal) = str2double(line(22:23));
        [toc_gal(i_gal),week_toc_gal(i_gal)]=Date2GPSTime(year_toc_gal(i_gal),month_toc_gal(i_gal),day_toc_gal(i_gal),hour_toc_gal(i_gal)+minute_toc_gal(i_gal)/60+second_toc_gal(i_gal)/3600);
        
        af0_gal(i_gal) = str2num(line(24:42));
        af1_gal(i_gal) = str2num(line(43:61));
        af2_gal(i_gal) = str2num(line(62:80));
        
        line = fgetl(fide);	  %%
        
        iod_gal = str2num(line(5:23));
        crs_gal(i_gal) = str2num(line(24:42));
        deltan_gal(i_gal) = str2num(line(43:61));
        M0_gal(i_gal) = str2num(line(62:80));
        
        line = fgetl(fide);	  %%
        
        cuc_gal(i_gal) = str2num(line(5:23));
        ecc_gal(i_gal) = str2num(line(24:42));
        cus_gal(i_gal) = str2num(line(43:61));
        roota_gal(i_gal) = str2num(line(62:80));
        
        line=fgetl(fide);      %%
        
        toe_gal(i_gal) = str2num(line(2:23));
        cic_gal(i_gal) = str2num(line(24:42));
        Omega0_gal(i_gal) = str2num(line(43:61));
        cis_gal(i_gal) = str2num(line(62:80));
        
        line = fgetl(fide);	   %%
        
        i0_gal(i_gal) =  str2num(line(5:23));
        crc_gal(i_gal) = str2num(line(24:42));
        omega_gal(i_gal) = str2num(line(43:61));
        Omegadot_gal(i_gal) = str2num(line(62:80));
        
        line = fgetl(fide);	    %%
        line(81)='x';
        
        idot_gal(i_gal) = str2num(line(5:23));
        data_source_gal(i_gal) = str2num(line(24:42));
        week_toe_gal(i_gal) = str2num(line(43:61));
        if isempty(str2num(line(62:80)))
            spare1_gal(i_gal)=nan;
        else
            spare1_gal(i_gal) = str2num(line(62:80));
        end
        
        line = fgetl(fide);	    %%
        line(81)='x';
        URA_gal(i_gal) = str2num(line(5:23));
        health_gal(i_gal) = str2num(line(24:42));
        BGD_E5aE1_gal(i_gal) = str2num(line(43:61));
        
        if isempty(str2num(line(62:80)))
            BGD_E5bE1_gal(i_gal)=nan;
        else
            BGD_E5bE1_gal(i_gal) = str2num(line(62:80));
        end
        line = fgetl(fide);	    %%
        line(81)='x';
        TTimeMsg_gal(i_gal) = str2num(line(5:23));
        if ~isempty(str2num(line(24:42)))
            spare2_gal(i_gal) = str2num(line(24:42));
            spare3_gal(i_gal) = str2num(line(43:61));
            spare4_gal(i_gal) = str2num(line(62:80));
        end

    
    elseif line(1)=='R'
        i_glo=i_glo+1;
        slot_sv_glo(i_glo)=str2num(line(2:3));
        year_toe_glo(i_glo)=str2num(line(5:8));
        month_toe_glo(i_glo)=str2num(line(10:11));
        day_toe_glo(i_glo)=str2num(line(13:14));
        hour_toe_glo(i_glo)=str2num(line(16:17));
        min_toe_glo(i_glo)=str2num(line(19:20));
        sec_toe_glo(i_glo)=str2num(line(22:23));
        [toe_glo(i_glo),week_glo(i_glo)]=Date2GPSTime(year_toe_glo(i_glo),month_toe_glo(i_glo),day_toe_glo(i_glo),hour_toe_glo(i_glo)+min_toe_glo(i_glo)/60+sec_toe_glo(i_glo)/3600);
        sv_clock_bias_glo(i_glo)=str2num(line(24:42));
        sv_rel_freq_bias_glo(i_glo)=str2num(line(43:61));
        m_f_t_glo(i_glo)=str2num(line(62:80));
        line = fgetl(fide);%%%
        X_glo(i_glo)=str2num(line(5:23));
        Xdot_glo(i_glo)=str2num(line(24:42));
        Xacc_glo(i_glo)=str2num(line(43:61));
        health_glo(i_glo)=str2num(line(62:80));
        line = fgetl(fide);%%%
        Y_glo(i_glo)=str2num(line(5:23));
        Ydot_glo(i_glo)=str2num(line(24:42));
        Yacc_glo(i_glo)=str2num(line(43:61));
        freq_num_glo(i_glo)=str2num(line(62:80));
        line = fgetl(fide);%%%
        Z_glo(i_glo)=str2num(line(5:23));
        Zdot_glo(i_glo)=str2num(line(24:42));
        Zacc_glo(i_glo)=str2num(line(43:61));
        age_oper_info_glo(i_glo)=str2num(line(62:80));
    
    
    elseif line(1)=='S'
        i_sba=i_sba+1;
        slot_sv_sba(i_sba)=str2num(line(2:3));
        year_toe_sba(i_sba)=str2num(line(5:8));
        month_toe_sba(i_sba)=str2num(line(10:11));
        day_toe_sba(i_sba)=str2num(line(13:14));
        hour_toe_sba(i_sba)=str2num(line(16:17));
        min_toe_sba(i_sba)=str2num(line(19:20));
        sec_toe_sba(i_sba)=str2num(line(22:23));
        [toe_sba(i_sba),week_sba(i_sba)]=Date2GPSTime(year_toe_sba(i_sba),month_toe_sba(i_sba),day_toe_sba(i_sba),hour_toe_sba(i_sba)+min_toe_sba(i_sba)/60+sec_toe_sba(i_sba)/3600);
        sv_clock_bias_sba(i_sba)=str2num(line(24:42));
        sv_rel_freq_bias_sba(i_sba)=str2num(line(43:61));
        m_f_t_sba(i_sba)=str2num(line(62:80));
        line = fgetl(fide);%%%
        X_sba(i_sba)=str2num(line(5:23));
        Xdot_sba(i_sba)=str2num(line(24:42));
        Xacc_sba(i_sba)=str2num(line(43:61));
        health_sba(i_sba)=str2num(line(62:80));
        line = fgetl(fide);%%%
        Y_sba(i_sba)=str2num(line(5:23));
        Ydot_sba(i_sba)=str2num(line(24:42));
        Yacc_sba(i_sba)=str2num(line(43:61));
        freq_num_sba(i_sba)=str2num(line(62:80));
        line = fgetl(fide);%%%
        Z_sba(i_sba)=str2num(line(5:23));
        Zdot_sba(i_sba)=str2num(line(24:42));
        Zacc_sba(i_sba)=str2num(line(43:61));
        age_oper_info_sba(i_sba)=str2num(line(62:80));
    
        
    elseif line(1)=='C'
        i_com=i_com+1;
        svprn_com(i_com) = str2double(line(2:3));
        
        year_toc_com(i_com) = str2double(line(5:8));
        month_toc_com(i_com) = str2double(line(10:11));
        day_toc_com(i_com) = str2double(line(13:14));
        hour_toc_com(i_com) = str2double(line(16:17));
        minute_toc_com(i_com) = str2double(line(19:20));
        second_toc_com(i_com) = str2double(line(22:23));
        [toc_com(i_com),week_toc_com(i_com)]=Date2GPSTime(year_toc_com(i_com),month_toc_com(i_com),day_toc_com(i_com),hour_toc_com(i_com)+minute_toc_com(i_com)/60+second_toc_com(i_com)/3600);
        
        af0_com(i_com) = str2num(line(24:42));
        af1_com(i_com) = str2num(line(43:61));
        af2_com(i_com) = str2num(line(62:80));
        
        line = fgetl(fide);	  %%
        
        iode_com(i_com) = str2num(line(5:23));
        crs_com(i_com) = str2num(line(24:42));
        deltan_com(i_com) = str2num(line(43:61));
        M0_com(i_com) = str2num(line(62:80));
        
        line = fgetl(fide);	  %%
        
        cuc_com(i_com) = str2num(line(5:23));
        ecc_com(i_com) = str2num(line(24:42));
        cus_com(i_com) = str2num(line(43:61));
        roota_com(i_com) = str2num(line(62:80));
        
        line=fgetl(fide);      %%
        
        toe_com(i_com) = str2num(line(2:23));
        cic_com(i_com) = str2num(line(24:42));
        Omega0_com(i_com) = str2num(line(43:61));
        cis_com(i_com) = str2num(line(62:80));
        
        line = fgetl(fide);	   %%
        
        i0_com(i_com) =  str2num(line(5:23));
        crc_com(i_com) = str2num(line(24:42));
        omega_com(i_com) = str2num(line(43:61));
        Omegadot_com(i_com) = str2num(line(62:80));
        
        line = fgetl(fide);	    %%
        line(81)='x';
        
        idot_com(i_com) = str2num(line(5:23));
        codes_com(i_com) = str2num(line(24:42));
        week_toe_com(i_com) = str2num(line(43:61));
        L2flag_com(i_com) = str2num(line(62:80));
        
        line = fgetl(fide);	    %%
        line(81)='x';
        URA_com(i_com) = str2num(line(5:23));
        health_com(i_com) = str2num(line(24:42));
        tgd_com(i_com) = str2num(line(43:61));
        iodc_com(i_com) = str2num(line(62:80));
        
        line = fgetl(fide);	    %%
        line(81)='x';
        TTimeMsg_com(i_com) = str2num(line(5:23));
        fit_com(i_com) = str2num(line(24:42));
        if ~isempty(str2num(line(43:61)))
            spare1_com(i_com) = str2num(line(43:61));
            spare2_com(i_com) = str2num(line(62:80));
        end
        
        
    elseif line(1)=='J'
        line = fgetl(fide);	    %%
        line = fgetl(fide);	    %%
        line = fgetl(fide);	    %%
        line = fgetl(fide);	    %%
        line = fgetl(fide);	    %%
        line = fgetl(fide);	    %%
        line = fgetl(fide);	    %%
        
    else
       disp('unknown gnss') 
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

if nr_eph_gal>0
    eph_gal(1,:)  = svprn_gal;
    eph_gal(2,:)  = week_toc_gal;
    eph_gal(3,:)  = toc_gal;
    eph_gal(4,:)  = af0_gal;
    eph_gal(5,:)  = af1_gal;
    eph_gal(6,:)  = af2_gal;
    eph_gal(7,:)  = iod_gal;
    eph_gal(8,:)  = crs_gal;
    eph_gal(9,:)  = deltan_gal;
    eph_gal(10,:) = M0_gal;
    eph_gal(11,:) = cuc_gal;
    eph_gal(12,:) = ecc_gal;
    eph_gal(13,:) = cus_gal;
    eph_gal(14,:) = roota_gal;
    eph_gal(15,:) = toe_gal;
    eph_gal(16,:) = cic_gal;
    eph_gal(17,:) = Omega0_gal;
    eph_gal(18,:) = cis_gal;
    eph_gal(19,:) = i0_gal;
    eph_gal(20,:) = crc_gal;
    eph_gal(21,:) = omega_gal;
    eph_gal(22,:) = Omegadot_gal;
    eph_gal(23,:) = idot_gal;
    eph_gal(24,:) = data_source_gal;
    eph_gal(25,:) = week_toe_gal;
    eph_gal(26,:) = spare1_gal;
    eph_gal(27,:) = URA_gal;
    eph_gal(28,:) = health_gal;
    eph_gal(29,:) = BGD_E5aE1_gal;
    eph_gal(30,:) = BGD_E5bE1_gal;
    eph_gal(31,:) = TTimeMsg_gal;
end

if nr_eph_glo>0
    eph_glo(1,:)=slot_sv_glo;
    eph_glo(2,:)=toe_glo;
    eph_glo(3,:)=sv_clock_bias_glo;
    eph_glo(4,:)=sv_rel_freq_bias_glo;
    eph_glo(5,:)=m_f_t_glo;
    eph_glo(6,:)=X_glo;
    eph_glo(7,:)=Xdot_glo;
    eph_glo(8,:)=Xacc_glo;
    eph_glo(9,:)=health_glo;
    eph_glo(10,:)=Y_glo;
    eph_glo(11,:)=Ydot_glo;
    eph_glo(12,:)=Yacc_glo;
    eph_glo(13,:)=freq_num_glo;
    eph_glo(14,:)=Z_glo;
    eph_glo(15,:)=Zdot_glo;
    eph_glo(16,:)=Zacc_glo;
    eph_glo(17,:)=age_oper_info_glo;
    eph_glo(18,:)=menoTauC_glo*ones(1,nr_eph_glo);
    eph_glo(19,:)=week_glo;
end

if nr_eph_sba>0
    eph_sba(1,:)=slot_sv_sba;
    eph_sba(2,:)=toe_sba;
    eph_sba(3,:)=sv_clock_bias_sba;
    eph_sba(4,:)=sv_rel_freq_bias_sba;
    eph_sba(5,:)=m_f_t_sba;
    eph_sba(6,:)=X_sba;
    eph_sba(7,:)=Xdot_sba;
    eph_sba(8,:)=Xacc_sba;
    eph_sba(9,:)=health_sba;
    eph_sba(10,:)=Y_sba;
    eph_sba(11,:)=Ydot_sba;
    eph_sba(12,:)=Yacc_sba;
    eph_sba(13,:)=freq_num_sba;
    eph_sba(14,:)=Z_sba;
    eph_sba(15,:)=Zdot_sba;
    eph_sba(16,:)=Zacc_sba;
    eph_sba(17,:)=age_oper_info_sba;
    eph_sba(18,:)=menoTauC_sba*ones(1,nr_eph_sba);
    eph_sba(19,:)=week_sba;
end

if nr_eph_com>0
    eph_com(1,:)  = svprn_com;
    eph_com(2,:)  = week_toc_com;
    eph_com(3,:)  = toc_com;
    eph_com(4,:)  = af0_com;
    eph_com(5,:)  = af1_com;
    eph_com(6,:)  = af2_com;
    eph_com(7,:)  = iode_com;
    eph_com(8,:)  = crs_com;
    eph_com(9,:)  = deltan_com;
    eph_com(10,:) = M0_com;
    eph_com(11,:) = cuc_com;
    eph_com(12,:) = ecc_com;
    eph_com(13,:) = cus_com;
    eph_com(14,:) = roota_com;
    eph_com(15,:) = toe_com;
    eph_com(16,:) = cic_com;
    eph_com(17,:) = Omega0_com;
    eph_com(18,:) = cis_com;
    eph_com(19,:) = i0_com;
    eph_com(20,:) = crc_com;
    eph_com(21,:) = omega_com;
    eph_com(22,:) = Omegadot_com;
    eph_com(23,:) = idot_com;
    eph_com(24,:) = codes_com;
    eph_com(25,:) = week_toe_com;
    eph_com(26,:) = L2flag_com;
    eph_com(27,:) = URA_com;
    eph_com(28,:) = health_com;
    eph_com(29,:) = tgd_com;
    eph_com(30,:) = iodc_com;
    eph_com(31,:) = TTimeMsg_com;
    eph_com(32,:) = fit_com;
end


%day of the year
if nr_eph_gps>0
    DOY=Date2DayOfYear(year_toc_gps(end),month_toc_gps(end),day_toc_gps(end));
elseif nr_eph_gal>0
    DOY=Date2DayOfYear(year_toc_gal(end),month_toc_gal(end),day_toc_gal(end));
elseif nr_eph_glo>0
    DOY=Date2DayOfYear(year_toe_glo(end),month_toe_glo(end),day_toe_glo(end));
elseif nr_eph_sba>0
    DOY=Date2DayOfYear(year_toe_sba(end),month_toe_sba(end),day_toe_sba(end));
elseif nr_eph_com>0
    DOY=Date2DayOfYear(year_toc_com(end),month_toc_com(end),day_toc_com(end));
end

eph.gps=eph_gps;
eph.glo=eph_glo;
eph.gal=eph_gal;
eph.sba=eph_sba;
eph.com=eph_com;


