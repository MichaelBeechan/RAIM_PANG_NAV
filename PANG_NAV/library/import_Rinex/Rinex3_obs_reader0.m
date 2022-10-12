function [XYZ_station,leap_sec,observations,header,version_rinex]=Rinex3_obs_reader0(file_name,dt_data)


fid=fopen(file_name,'r');
linea=fgetl(fid);

version_rinex=str2num(linea(6));

Y_first=[];
Y_last=[];
leap_sec=[];

num_oss_gps=[];
num_oss_glo=[];
num_oss_gal=[];
num_oss_com=[];
num_oss_sba=[];

while (~feof(fid) && isempty(strfind(linea, 'END OF HEADER')))
    
    linea=fgetl(fid);
    
    
    %% Coordinate della stazione in sistema geocentrico
    if(~isempty(strfind(linea, 'APPROX POSITION XYZ')))
        X_staz=str2double(linea(1:14));
        Y_staz=str2double(linea(16:28));
        Z_staz=str2double(linea(30:42));
        XYZ_station=[X_staz,Y_staz,Z_staz];
    end
    
    %leap seconds (leap_sec)
    D=findstr(linea,'LEAP SECONDS'); %#ok<*FSTR>
    if ~isempty(D)
        leap_sec=str2num(linea(1:6)); %#ok<*ST2NM>
    end
    
    E=findstr(linea,'TIME OF FIRST OBS');
    if ~isempty (E)
        Y_first=str2num(linea(1:7));
        M_first=str2num(linea(11:12));
        D_first=str2num(linea(17:18));
        H_first=str2num(linea(23:24));
        Min_first=str2num(linea(29:30));
        Sec_first=str2num(linea(34:43));
    end
    
    F=findstr(linea,'TIME OF LAST OBS');
    if ~isempty (F)
        Y_last=str2num(linea(1:7));
        M_last=str2num(linea(11:12));
        D_last=str2num(linea(17:18));
        H_last=str2num(linea(23:24));
        Min_last=str2num(linea(29:30));
        Sec_last=str2num(linea(34:43));
    end
    
    G=findstr(linea,'INTERVAL');
    if ~isempty (G)
        dt_data=str2num(linea(5:10));
    end
    if(~isempty(strfind(linea, 'SYS / # / OBS TYPES')))
        
        switch( linea(1))
            case 'G'
                %disp 'GPS'
                num_oss_gps=str2double(linea(4:6));
                oss_gps=cell(1,num_oss_gps);
                oss1=regexp(linea(8:end-19),'....','match');
                
                if num_oss_gps < 13
                    oss_gps(1:num_oss_gps)=oss1(1:num_oss_gps);
                else
                    oss_gps(1:13)=oss1;
                    linea=fgetl(fid);
                    oss2=regexp(linea(8:end-19),'....','match');
                    oss_gps(14:num_oss_gps)=oss2(1:num_oss_gps-13);
                end
                header.gps=['week','epoch','flag','prn',oss_gps];
                
            case 'R'
                %disp 'GLONASS'
                num_oss_glo=str2double(linea(4:6));
                oss_glo=cell(1,num_oss_glo);
                oss1=regexp(linea(8:end-19),'....','match');
                
                if num_oss_glo < 13
                    oss_glo(1:num_oss_glo)=oss1(1:num_oss_glo);
                else
                    oss_glo(1:13)=oss1;
                    linea=fgetl(fid);
                    oss2=regexp(linea(8:end-19),'....','match');
                    oss_glo(14:num_oss_glo)=oss2(1:num_oss_glo-13);
                end
                header.glo=['week','epoch','flag','prn',oss_glo];
                
            case 'S'
                %disp 'SBAS'
                num_oss_sba=str2double(linea(4:6));
                oss_sba=cell(1,num_oss_gal);
                oss1=regexp(linea(8:end-19),'....','match');
                if num_oss_sba < 13
                    oss_sba(1:num_oss_sba)=oss1(1:num_oss_sba);
                else
                    oss_sba(1:13)=oss1;
                    linea=fgetl(fid);
                    oss2=regexp(linea(8:end-19),'....','match');
                    oss_sba(14:num_oss_gal)=oss2(1:num_oss_gal-13);
                end
                header.sba=['week','epoch','flag','prn',oss_sba];
                
            case 'E'
                %disp 'Galileo'
                num_oss_gal=str2double(linea(4:6));
                oss_gal=cell(1,num_oss_gal);
                oss1=regexp(linea(8:end-19),'....','match');
                if num_oss_gal < 13
                    oss_gal(1:num_oss_gal)=oss1(1:num_oss_gal);
                else
                    oss_gal(1:13)=oss1;
                    linea=fgetl(fid);
                    oss2=regexp(linea(8:end-19),'....','match');
                    oss_gal(14:num_oss_gal)=oss2(1:num_oss_gal-13);
                end
                header.gal=['week','epoch','flag','prn',oss_gal];
                
            case 'C'
                %disp 'BDS'
                num_oss_com=str2double(linea(4:6));
                oss_com=cell(1,num_oss_com);
                oss1=regexp(linea(8:end-19),'....','match');
                
                if num_oss_com < 13
                    oss_com(1:num_oss_com)=oss1(1:num_oss_com);
                else
                    oss_com(1:13)=oss1;
                    linea=fgetl(fid);
                    oss2=regexp(linea(8:end-19),'....','match');
                    oss_com(14:num_oss_com)=oss2(1:num_oss_com-13);
                end
                header.com=['week','epoch','flag','prn',oss_com];
%             otherwise
%                 disp 'ERRORE SYSTEMA NON RICONOSCIUTO'
        end
    end
end
%%

nr_sat_mean=30;
if ~isempty (Y_first) && ~isempty(Y_last)
    [sec_start,settimana_start]=Date2GPSTime(Y_first,M_first,D_first,H_first+Min_first/60+Sec_first/3600);
    [sec_end,settimana_end]=Date2GPSTime(Y_last,M_last,D_last,H_last+Min_last/60+Sec_last/3600);
    nr_Epoch=((settimana_end-settimana_start)*86400*7+(sec_end-sec_start))/dt_data;
    nr_row=nr_Epoch*nr_sat_mean;
else
    nr_Epoch=86400/dt_data;
    nr_row=nr_Epoch*nr_sat_mean;
end


nr_col_gps=num_oss_gps+4;
nr_col_glo=num_oss_glo+4;
nr_col_gal=num_oss_gal+4;
nr_col_com=num_oss_com+4;
nr_col_sba=num_oss_sba+4;

obs_gps=nan(nr_row,nr_col_gps);
obs_glo=nan(nr_row,nr_col_glo);
obs_gal=nan(nr_row,nr_col_gal);
obs_com=nan(nr_row,nr_col_com);
obs_sba=nan(nr_row,nr_col_sba);
num_sat_gps=0;
num_sat_gal=0;
num_sat_glo=0;
num_sat_com=0;
num_sat_sba=0;

max_oss=max([num_oss_gps,num_oss_glo,num_oss_gal,num_oss_com]);
%%
%%%%lettura dati%%%%
k=0;
linea=fgetl(fid);
while (~feof(fid) )
    if (isempty(linea))
        linea=fgetl(fid);
        
    else
    k=k+1;
        if(linea(1)=='>')
            linea_data=str2num(linea(2:end));
            anno_epoca=linea_data(1);
            mese_epoca=linea_data(2);
            giorno_epoca=linea_data(3);
            ora_epoca=linea_data(4);
            minuto_epoca=linea_data(5);
            secondi_epoca=linea_data(6);
            ora=ora_epoca+minuto_epoca/60+secondi_epoca/3600;
            [sec_GPS,week]=Date2GPSTime(anno_epoca,mese_epoca,giorno_epoca,ora);
            epoch_flag=linea_data(7);
            num_sat_epoca=linea_data(8);
        end

        for indice_satelliti=1:num_sat_epoca
            linea=fgetl(fid);
            linea(max_oss*16+4)='+';

            switch( linea(1))
                case 'G'
                    num_sat_gps=num_sat_gps+1;
                    prn=1000+str2double(linea(2:3));
                    obs=nan(1,num_oss_gps);
                    a=regexp(linea(4:end),'................','match');
                    for i=1:num_oss_gps
                        if ~isempty(str2num(a{i}(1:14))) %%%%%correzione 04/12/2018
                            obs(i)=str2num(a{i}(1:14));
                        end
                    end
                    obs_gps(num_sat_gps,:)=[week,sec_GPS,epoch_flag,prn,obs];
                case 'E'
                    num_sat_gal=num_sat_gal+1;
                    prn=3000+str2double(linea(2:3));
                    obs=nan(1,num_oss_gal);
                    a=regexp(linea(4:end),'................','match');
                    for i=1:num_oss_gal
                        if ~isempty(str2num(a{i}(1:14))) %%%%%correzione 04/12/2018
                            obs(i)=str2num(a{i}(1:14));
                        end
                    end
                    obs_gal(num_sat_gal,:)=[week,sec_GPS,epoch_flag,prn,obs];
                case 'C'
                    num_sat_com=num_sat_com+1;
                    prn=4000+str2double(linea(2:3));
                    obs=nan(1,num_oss_com);
                    a=regexp(linea(4:end),'................','match');
                    for i=1:num_oss_com
                        if ~isempty(str2num(a{i}(1:14))) %%%%%correzione 04/12/2018
                            obs(i)=str2num(a{i}(1:14));
                        end
                    end
                    obs_com(num_sat_com,:)=[week,sec_GPS,epoch_flag,prn,obs];
                case 'R'
                    num_sat_glo=num_sat_glo+1;
                    prn=2000+str2double(linea(2:3));
                    obs=nan(1,num_oss_glo);
                    a=regexp(linea(4:end),'................','match');
                    for i=1:num_oss_glo
                        if ~isempty(str2num(a{i}(1:14))) %%%%%correzione 04/12/2018
                            obs(i)=str2num(a{i}(1:14));
                        end
                    end
                    obs_glo(num_sat_glo,:)=[week,sec_GPS,epoch_flag,prn,obs];
                case 'S'
                    num_sat_sba=num_sat_sba+1;
                    prn=5000+str2double(linea(2:3));
                    obs=nan(1,num_oss_sba);
                    a=regexp(linea(4:end),'................','match');
                    for i=1:num_oss_sba
                        if ~isempty(str2num(a{i}(1:14))) %%%%%correzione 04/12/2018
                            obs(i)=str2num(a{i}(1:14));
                        end
                    end
                    obs_sba(num_sat_sba,:)=[week,sec_GPS,epoch_flag,prn,obs];
            end
        end
        linea=fgetl(fid);
    end
end

if ~isempty(obs_gps)
    obs_gps=obs_gps(~isnan(obs_gps(:,1)),:);
    obs_gps(:,4)=obs_gps(:,4)-1000;
end
if ~isempty(obs_glo)
    obs_glo=obs_glo(~isnan(obs_glo(:,1)),:);
    obs_glo(:,4)=obs_glo(:,4)-2000;
end
if ~isempty(obs_gal)
    obs_gal=obs_gal(~isnan(obs_gal(:,1)),:);
    obs_gal(:,4)=obs_gal(:,4)-3000;
end
if ~isempty(obs_com)
    obs_com=obs_com(~isnan(obs_com(:,1)),:);
     obs_com(:,4)=obs_com(:,4)-4000;
end
if ~isempty(obs_sba)
    obs_sba=obs_sba(~isnan(obs_sba(:,1)),:);
    obs_sba(:,4)=obs_sba(:,4)-5000;
end

observations.gps=obs_gps;
observations.glo=obs_glo;
observations.gal=obs_gal;
observations.com=obs_com;
observations.sba=obs_sba;

fclose('all');



