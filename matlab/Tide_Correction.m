function dg = Tide_Correction(Longtitude,Latitude,date,tt)
% 固体潮校正值计算函数
% 参考《大比例尺重力勘探规范》
% 输入    Longtitude：经度（用度数表示）
%         Latitude：纬度（用度数表示）
%         date：年月日 
%         tt：具体的时刻（例如8.50表示8：30）
% 输出    dg： 固体潮改正值
% 例子   dg = Tide_Correction(112.930600000000,28.1694200000000,[2024,6,30],8.50)
Deltath=1.16;                    % 潮汐因子
tz=8.0;                          % 时差
Year=date(1); Month=date(2);Day=date(3);
Phi=Latitude;
Phip=Phi-0.193296*sin(2*Phi*pi/180.0);
Longtitude=Longtitude*pi/180.0;
Latitude=Latitude*pi/180.0;

Phi = Latitude;
Phip=Phip*pi/180.0;

t=tt;
T0=Julian(Year,Month,Day);
T=(T0-2415020.0+(t-tz)/24.0)/36525.0;
S=270.43659+481267.89057*T+0.00198*T*T+0.000002*T*T*T;
h=279.69668+36000.76892*T+0.00030*T*T;
p=334.32956+4069.03403*T-0.01032*T*T-0.00001*T*T*T;
N=259.18328-1934.14201*T+0.00208*T*T+0.000002*T*T*T;
ps=281.22083+1.71902*T+0.00045*T*T+0.000003*T*T*T;
e=23.45229-0.01301*T-0.000002*T*T;

S=S*pi/180.0;    h=h*pi/180.0;   p=p*pi/180.0;
N=N*pi/180.0;    ps=ps*pi/180.0; e=e*pi/180.0;
%*******求月亮的c/r及cosZ*******%
crm=1+0.0545*cos(S-p)+0.0030*cos(2*(S-p))+0.01*cos(S-2*h+p)+0.0082*cos(2*(S-h))...
    +0.0006*cos(2*S-3*h+ps)+0.0009*cos(3*S-2*h-p);
Lambdam=S+0.0222*sin(S-2*h+p)+0.1098*sin(S-p)+0.0115*sin(2*S-2*h)+0.0037*sin(2*S-2*p)...
    -0.0032*sin(h-ps)-0.001*sin(2*h-2*p)+0.001*sin(S-3*h+p+ps)+0.0007*sin(S-h-p+ps)...
    -0.0006*sin(S-h)-0.0005*sin(S+h-p-ps)+0.0008*sin(2*S-3*h+ps)-0.002*sin(2*S-2*N)...
    +0.0009*sin(3*S-2*h-p);
Beltam=0.003*sin(S-2*h+N)+0.0895*sin(S-N)+0.0049*sin(2*S-p-N)-0.0048*sin(p-N)-0.0008*sin(2*h-p-N)...
    +0.001*sin(2*S-2*h+p-N)+0.0006*sin(3*S-2*h-N);
Delta=sin(e)*sin(Lambdam)*cos(Beltam)+cos(e)*sin(Beltam);
Theta=((t-tz)*(15*pi/180.0))+h+Longtitude-pi;
H=cos(Beltam)*cos(Lambdam)*cos(Theta)+sin(Theta)*(cos(e)*cos(Beltam)*sin(Lambdam)-sin(e)*sin(Beltam));
Zm=sin(Phip)*Delta+cos(Phip)*H;   %% Zm=cos(Zm);
%%*******求太阳的c/r及cosZ*******%%
crs=1+0.0168*cos(h-ps)+0.0003*cos(2*h-2*ps);
Lambdas=h+0.0335*sin(h-ps)+0.0004*sin(2*h-2*ps);
Zs=sin(Phip)*sin(e)*sin(Lambdas)+cos(Phip)*(cos(Lambdas)*cos(Theta)+sin(Theta)*cos(e)*sin(Lambdas)); %%Zs=cos(Zs);

F=0.998327+0.001676*cos(2*Phi);
Gt=-165.17*F*crm*crm*crm*(Zm*Zm-1.0/3.0)-1.37*F*F*crm*crm*crm*crm*Zm*(5*Zm*Zm-3)-76.08*F*crs*crs*crs*(Zs*Zs-1.0/3.0);
Deltafc=-4.83+15.73*sin(Phip)*sin(Phip)-1.59*sin(Phip)*sin(Phip)*sin(Phip)*sin(Phip);
dg=-(Deltath*Gt-Deltafc)/1000;
end

% 儒略日计算函数
function dl=Julian(y,m,d)
yy=y-1900;
mm=m-1;
dd=d;

w=floor(yy/4);
if(y==4*w&&mm<2)
    dd=dd-1;
end
if(mm==0)
    dl=(yy*365+w-0.5+mm+dd);
elseif(mm==1)
    mm=31;
    dl=(yy*365+w-0.5+mm+dd);
else
    mm=floor(mm*365/12)-floor(10/(4+mm));
    dl=(yy*365+w-0.5+mm+dd);
end
dl=dl+2415020.0;
end