% 2/c Cole Gingrich
% Exam 3
% Proportional Integral (PI) Controller Design

clear all; clc;
disp('Welcome to Proportional Integral Controller Design!');
type = input('Would you like to do (B)ode or (R)oot Locus analysis? ','s');
num = input('Enter the numerator in matrix form: ');
den = input('Enter the denominator in matrix form: ');

Gs = tf(num,den);

T = input('Enter the sampling time in seconds: ');

Ts = input('Enter the specified settling time: ');
po = input('Enter the specified percent overshoot in percentage points: ');
po = po/100;

Gz = c2d(Gs,T);

figure(1); step(Gz); title('Uncompensated Step Response');

if( strcmp(type,'B') || strcmp(type,'b'))
    phi=atan(-pi/log(po));
    zeta=cos(phi);
    wn=4/(zeta*Ts);
    % calculate phase margin
    PM=atan(2*zeta/sqrt(-2*zeta^2+sqrt(1+4*zeta^4)));
    pm=PM*180/pi;
    % calculate gain crossover frequency
    wgc=2*zeta*wn/tan(PM);
    % find continuous time design point
    sd=j*wgc;
    % find discrete time design point
    zd=exp(sd*T);
    
    figure(2); bode(Gz); title('Uncompensated Bode Response');
    
    X=evalfr(Gz,zd);
    xm=abs(X);

    thc=PM-pi-angle(X);

    xd=real(zd);
    yd=imag(zd);

    thp=angle(zd-1);
    thz=thc+thp;

    al=xd-yd/tan(thz);

    Dz=zpk(al,1,1,T);

    Y=evalfr(Dz,zd);

    K=1/(abs(X)*abs(Y));

    Dz=K*Dz;

    Gop=Dz*Gz;
    Gcl=feedback(Gop,1);
    
    figure(3); bode(Gop); title('Compensated Bode Response'); grid on;

    figure(4); step(Gcl); title('Step Response');grid on;
elseif( strcmp(type,'R') || strcmp(type,'r'))
    phi=atan(-pi/log(po));
    zeta=cos(phi);
    wn=4/(zeta*Ts);
    sigmad=zeta*wn;
    wd=wn*sqrt(1-zeta^2);

    % Continuous and discrete time design points
    sd=-sigmad+j*wd;
    zd=exp(sd*T);
    figure(2);
    rlocus(Gz); title('Uncompensated Root Locus');
    hold on;
    line(real(zd),imag(zd),'Marker','^');
    hold off;
    
    X=evalfr(Gz,zd);

    thc=pi-angle(X);
    xd=real(zd);
    yd=imag(zd);
    thp=angle(zd-1);
    thz1=thc+thp;

    al=xd-yd/tan(thz1);

    Dz=zpk(al,1,1,T);

    Y=evalfr(Dz,zd);

    K=1/(abs(X)*abs(Y));

    Dz=K*Dz;
    Gop=Dz*Gz;
    Gcl=feedback(Gop,1);
    
    figure(3);rlocus(Gop);title('Compensated root locus');
    hold on
    line(real(zd),imag(zd),'Marker','^');
    hold off

    figure(4);step(Gcl);title('Step Response with PI Compensator');
    grid on;
else
    disp('Not a valid option. The program is ended.');
end