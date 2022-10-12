function [sec_GPS,week]=Date2GPSTime(anno,mese,giorno,ora)

% la function Date2GPSTime converte la data in epoca GPS
%
%January 2007 Antonio Angrisano - "Parthenope" Navigation Group

ANNO_RIF=1980;
NR_ANNI_INT=anno-ANNO_RIF;
NR_BISESTILI=0;
for i=ANNO_RIF:4:anno-1
    if rem(i,4)==0
       if rem(i,100)~=0
          NR_BISESTILI=NR_BISESTILI+1;
       elseif rem(i,100)==0
          if rem(i,400)==0
             if rem(i,4000)~=0
                NR_BISESTILI=NR_BISESTILI+1;
             end
          end
       end
    end
end

feb=28;
if rem(anno,4)==0
   if rem(anno,100)~=0
      feb=29;
   elseif rem(anno,100)==0
      if rem(anno,400)==0
         if rem(anno,4000)~=0
            feb=29;
         end
      end
   end
end

NR_GIORNI=NR_BISESTILI*366+(NR_ANNI_INT-NR_BISESTILI)*365;
if mese==1
   NR_GIORNI=NR_GIORNI+giorno-1-5;
elseif mese==2
   NR_GIORNI=NR_GIORNI+31+giorno-1-5;
elseif mese==3
   NR_GIORNI=NR_GIORNI+31+feb+giorno-1-5;
elseif mese==4
   NR_GIORNI=NR_GIORNI+31+feb+31+giorno-1-5;
elseif mese==5
   NR_GIORNI=NR_GIORNI+31+feb+31+30+giorno-1-5;
elseif mese==6
   NR_GIORNI=NR_GIORNI+31+feb+31+30+31+giorno-1-5;
elseif mese==7
   NR_GIORNI=NR_GIORNI+31+feb+31+30+31+30+giorno-1-5;
elseif mese==8
   NR_GIORNI=NR_GIORNI+31+feb+31+30+31+30+31+giorno-1-5;
elseif mese==9
   NR_GIORNI=NR_GIORNI+31+feb+31+30+31+30+31+31+giorno-1-5;
elseif mese==10
   NR_GIORNI=NR_GIORNI+31+feb+31+30+31+30+31+31+30+giorno-1-5;
elseif mese==11
   NR_GIORNI=NR_GIORNI+31+feb+31+30+31+30+31+31+30+31+giorno-1-5;
elseif mese==12
   NR_GIORNI=NR_GIORNI+31+feb+31+30+31+30+31+31+30+31+30+giorno-1-5;
end

week=fix(NR_GIORNI/7);
sec_GPS=(rem(NR_GIORNI,7)*24+ora)*60*60;
    
sec_GPS=round(sec_GPS);    
    
    
    
    
    
    
    
    
    
    
    

           