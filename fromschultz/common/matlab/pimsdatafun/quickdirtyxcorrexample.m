% quick/dirty cross corr example
t = 0 : 1/1e3 : 10; % 1 kHz sample freq for 10 sec
d = 0 : 1/3 : 1; % repetition freq
y1 = pulstran(t,d,'rectpuls',0.2);
y2 = circshift(y1',2000);
y3 = circshift(y1',5432);
[c12,lag12] = xcorr(y1,y2);
[c13,lag13] = xcorr(y1,y3);
figure
plot(lag12,c12,'r',lag13,c13,'b')
xlabel('Samples')
ylabel('XCORR')
set(gca,'xtick',[-7000 -5432 -3000 -2000 -1000 0])
set(gca,'tickdir','out')
i = 1:length(y1);
figure
plot(i,y1,'g',i,y2,'r',i,y3,'b')
set(gca,'xtick',sort([0:1000:4000 5432 7000]))
xlabel('Samples')
ylabel('Dummy Synch Pulse Data')
