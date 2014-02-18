function execute()
%{
   Execute function for controller design GUI
%}

%Find handles for all objects
h_analysis = findobj('Tag','AnalysisBox');
h_type = findobj('Tag','TypeBox');
h_settle = findobj('Tag','SettleTime');
h_overshoot = findobj('Tag','PO');
h_sample = findobj('Tag','SampleTime');
h_num = findobj('Tag','NumBox');
h_den = findobj('Tag','DenBox');
h_control = findobj('Tag','Controller');

%Get info from each object
analysis = get(h_analysis , 'String');
type = get(h_type,'String');
Ts = str2double( get(h_settle,'String'));
po = str2double( get(h_overshoot,'String'));
T = str2double( get(h_sample,'String'));
num = str2num( get(h_num,'String'));
den = str2num( get(h_den,'String'));

Gs = tf(num,den);
Gz = c2d(Gs,T);
po = po/100;

phi=atan(-pi/log(po));
zeta=cos(phi);
wn=4/(zeta*Ts);
figure(1); step(Gz); title('Uncompensated Step Response');
if(strcmp(analysis,'Bode'))
    % calculate phase margin
    PM=atan(2*zeta/sqrt(-2*zeta^2+sqrt(1+4*zeta^4)));
    % calculate gain crossover frequency
    wgc=2*zeta*wn/tan(PM);
    % find continuous time design point
    sd=j*wgc;
    % find discrete time design point
    zd=exp(sd*T);

    figure(2); bode(Gz); title('Uncompensated Bode Response');

    X=evalfr(Gz,zd);
    
    thc=PM-pi-angle(X);
    
else % Root Locus Design
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
end

if(strcmp(type,'PI'))
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
        
    [z,p,k,Ts] = zpkdata(Dz);
    str=[k(1) '(z-' z(1) ')/(z-1)'];
    set(h_control, 'String', str);
elseif(strcmp(type,'PD'))
    xd=real(zd);
    yd=imag(zd);
    
    thp=angle(zd);
    thz=thc+thp;

    al=xd-yd/tan(thz);

    Dz=zpk(al,0,1,T);

    Y=evalfr(Dz,zd);
    K=1/(abs(X)*abs(Y));

    Dz=K*Dz;
    Gop=Dz*Gz;
    Gcl=feedback(Gop,1);

    %figure(3); bode(Gop); title('Compensated Bode Response'); grid on;

    figure(3); step(Gcl); title('Compensated Step Response');grid on;
        
    [z,p,k,Ts] = zpkdata(Dz);
    str=[k(1) '(z-' z(1) ')/z'];
    set(h_control, 'String', str);
else % Proportional
    K=1/abs(X);
    Gop=K*Gz;
    Gcl=minreal(K*Gz/(1+K*Gz));
    %figure(3); bode(Gop); title('Compensated Bode Response');
    figure(3); step(Gcl); title('Compensated Step Response');
        
    set(h_control, 'String', ['K= ' num2str(K)]);
end

if(strcmp(analysis,'Bode'))
    figure(4); bode(Gop); title('Compensated Bode Response');
else
    figure(4);rlocus(Gop);title('Compensated root locus');
    hold on
    line(real(zd),imag(zd),'Marker','^');
    hold off
end
end

