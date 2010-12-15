function smiling_spectrogram

fs = 8192; % sample rate in samples/sec for this example
t = 0:1/fs:3; % Time axis in seconds
x = real(sqrt(1-(t-1.5).^2)); % Half circle in time/x space
y = zeros(size(t)); 
ind = find((t>.5)&(t<2.5));
y(ind) = vco(x(ind),[1000 4000],fs) + vco(-x(ind),[1000 4000],fs);
y(ind(1:200))= y(ind(1:200)).*((1:200)/200); % Trapazoidal window
n = length(ind);                             % to reduce transient
y(ind(n-200:n)) = y(ind(n-200:n)).*(201-(1:201))/200;
x = -real(sqrt(1-((t-1.5)*2).^2))/2; % Another half circle
ind= find((t>1)&(t<2));
y2 = vco(x(ind),[1000 3500],fs);
y2(1:200) = y2(1:200).*(1:200)/200;
n = length(y2);
y2(n-200:n) = y2(n-200:n).*(201-(1:201))/200;
y(ind) = y(ind) + y2;
y = y + exp(-(t-1.25).^2*100).*cos(2*pi*t*3000);
y = y + exp(-(t-1.75).^2*100).*cos(2*pi*t*3000);
y = y + exp(-(t-1.5).^2*800).*cos(2*pi*t*2500)+randn(size(t))*.0001;
% specgram(y); % deprecated function
nfft = 256;
spectrogram(y,nfft,nfft/2,nfft,fs,'yaxis');
xlabel('Time (s)')