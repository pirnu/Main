function checkNoise( Noisy )

MaxLag = 500;
LagVector = -MaxLag:MaxLag;

for i = 1:32
    PN = PRN_Generator(i);
    XCorr = xcorr(PN,Noisy,MaxLag);
    XCorr = abs(XCorr);
    figure(i);
    plot(LagVector,XCorr); grid on;
    title(i);
    scale = [-MaxLag,MaxLag,-10,1024]; axis(scale);
end

end