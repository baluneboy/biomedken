function y = fade(x,pct)
%
% FADE fades the [audio sampled] vector x
%
% Example:
% x = randn(111,1);
% y = fade(x,5); % ramp first/last 5% (tails) of x
% figure, plot(x),hold on, plot(y,'r'), hold off

% number of pts to tail off
N = floor(length(x)*pct/100);

% make input vector a column
x = x(:); 

% create ramp vector (we could use other windows to taper like hanning)
r = linspace(0, 1, N);
r = r(:);

% multiply signal with the ramp vector to fade tails
y = x;
y(1:N) = r .* y(1:N);
y(end-N+1:end) = flipud(r) .* y(end-N+1:end);