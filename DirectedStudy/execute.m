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
h_control = findojb('Tag','Controller');

%Get info from each object
analysis = get(h_analysis , 'String');
type = get(h_type,'String');
Ts = str2double( get(h_settle,'String'));
po = str2double( get(h_overshoot,'String'));
T = str2double( get(h_sample,'String'));
num = str2num( get(h_num,'String'));
den = str2num( get(h_den,'String'));

if(strcmp(type,'Lead'))
    Gs = tf(num,den);
    Gz = c2d(Gs,T);
    po = po/100;
    
    figure(1); step(Gz); title('Uncompensated Step Response');
    
    if(strcmp(type,'Bode'))
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

        %Evaluation of open-loop transfer function at the design point
        X=evalfr(Gz,zd);

        thc=PM-pi-angle(X);
        xd=real(zd);
        yd=imag(zd);

        [numz,denz]=tfdata(Gz,'v');
        figure(3);zplane(numz,denz);
        al = input('Enter the value for alpha: ');
        thz=angle(zd-al);
        thp=thz-thc;

        be=xd-yd/tan(thp);
        Dc=zpk(al,be,1,T);

        Y=evalfr(Dc,zd);

        K=1/(abs(X)*abs(Y));
        Dz=K*Dc;

        Gop=Dz*Gz;

        %compensated bode
        figure(4); bode(Gop); title('Compensated Bode Response');grid on;

        %Closed loop transfer function
        Gcl=minreal(Dz*Gz/(1+Dz*Gz));

        %Closed lop compensated step response
        figure(5); step(Gcl); grid on;
    elseif(strcmp(type,'Root Locus'))
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

        X = evalfr(Gz,zd);

        thc=pi-angle(X);

        xd=real(zd);
        yd=imag(zd);

        [numz,denz]=tfdata(Gz,'v');
        figure(3);zplane(numz,denz);
        al = input('Enter the value for alpha: ');
        thz=angle(zd-al);
        thp=thz-thc;

        be=xd-yd/tan(thp);
        Dc=zpk(al,be,1,T);

        Y=evalfr(Dc,zd);

        K=1/(abs(X)*abs(Y));
        Dz=K*Dc;

        Gop=Dz*Gz;
        Gcl=feedback(Gop,1);

        figure(4);rlocus(Gop);title('Compensated root locus');
        hold on
        line(real(zd),imag(zd),'Marker','^');
        hold off

        figure(5);step(Gcl);title('Step Response with lead Compensator');
        grid on;
    else
        
    end
    
end




end

