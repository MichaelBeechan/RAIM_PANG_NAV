function DOY=Date2DayOfYear(anno,mese,giorno)

% Date2DayOfYear.m function to converte date to day of the year


%verifica se l'anno è bisestile e quindi sui giorni di febbraio
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


if mese==1
   DOY=giorno;
elseif mese==2
   DOY=31+giorno;
elseif mese==3
   DOY=31+feb+giorno;
elseif mese==4
   DOY=31+feb+31+giorno;
elseif mese==5
   DOY=31+feb+31+30+giorno;
elseif mese==6
   DOY=31+feb+31+30+31+giorno;
elseif mese==7
   DOY=31+feb+31+30+31+30+giorno;
elseif mese==8
   DOY=31+feb+31+30+31+30+31+giorno;
elseif mese==9
   DOY=31+feb+31+30+31+30+31+31+giorno;
elseif mese==10
   DOY=31+feb+31+30+31+30+31+31+30+giorno;
elseif mese==11
   DOY=31+feb+31+30+31+30+31+31+30+31+giorno;
elseif mese==12
   DOY=31+feb+31+30+31+30+31+31+30+31+30+giorno;
end

    
    
    
    
    
    
    
    
    
    
    
    

           