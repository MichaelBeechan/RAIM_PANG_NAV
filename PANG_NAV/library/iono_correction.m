function DI=iono_correction(lat_u,long_u,el_s,az_s,alfa,beta,GPS_time,f)
%
%iono_correction calcola la correzione ionosferica per singola frequenza
%
%in input:
%         - "lat_u","long_u" user latitudine and longitudine [rad]
%         - "el_s","az_s" satellite elevation and azimut [rad]
%         - "alfa","beta" broadcast parameters for Kloubuchar model
%         - "GPS_time" reception epoch [sec]
%         - "f" (optional) signal frequency only if not equal to f1=1575.42 MHz [MHz]
%
%in output:
%         - "DI" ionosphere correction [meter]
%
%version 0.001 2013/08/01



global v_light

nr_sat=length(el_s);

%calcolo dell'angolo al centro della terra (in semicircle)
psi=0.0137./(el_s/pi+0.11)-0.022;

%calcolo della "latitudine subionosferica" (in semicircle)
lat_i=lat_u/pi+psi.*cos(az_s);
for i=1:nr_sat
    if lat_i(i)>0.416
       lat_i(i)=0.416;
    end
    if lat_i(i)<-0.416
       lat_i(i)=-0.416;
    end
end

%calcolo della "longitudine subionosferica" (in semicircle)
long_i=long_u/pi+(psi.*sin(az_s))./cos(lat_i*pi);

%calcolo "latitudine geomagnetica" (in semicircle)
lat_m=lat_i+0.064*cos((long_i-1.617)*pi);

%tempo local al punto sub-ionosferico (in secondi)
t=4.32*10^4*long_i+GPS_time;
t=mod(t,86400);

%fattore di obliquità
F=1+16*(0.53-el_s/pi).^3;

%calcolo del ritardo ionosferico (in secondi)
somma_beta=zeros(nr_sat,1);
somma_alfa=zeros(nr_sat,1);
for ii=0:3
    somma_beta=somma_beta+beta(ii+1).*lat_m.^ii;
    somma_alfa=somma_alfa+alfa(ii+1).*lat_m.^ii;
end
for i=1:nr_sat
    somma_beta(i)=max([somma_beta(i),72000]); %su ICD ma non su Parkinson/Kloubuchar
end

x=2*pi*(t-50400)./somma_beta;
DI=zeros(nr_sat,1);
for v=1:nr_sat
    if abs(x(v))>1.57
       DI(v)=F(v)*5*10^-9;
    else
       DI(v)=F(v)*(5*10^-9+somma_alfa(v)*(1-(x(v)^2)/2+(x(v)^4)/24));
    end
end

if nargin==8
    fL1_GPS=1575.42;
    %adapting to other frequency
    DI=((fL1_GPS./f).^2).*DI;
end

DI=DI*v_light;
