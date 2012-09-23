function [ PowerByFrequency ] = signalpower( signal, Fs )
%POWER Compute classical square power periodogram

%% compute periodogram
[ Power, W ] = periodogram(signal); % where W in rad/sample

%% perform unit conversion
% see http://en.wikipedia.org/w/index.php?oldid=498928359
% for more information concerning rad vs hz relation
%
% see http://en.wikipedia.org/w/index.php?oldid=511747566
% for more information on rad/sample -> cycles/sec aka hz converting
%
% W : rad/sample, Fs : samples/sec => W*Fs = rad/sec
% as 1 Hz = 2π rad, n Hz = n rad * 2π and n rad = (n / 2π) Hz
Frequency = (W * Fs) / (2 * pi);

%% return
PowerByFrequency = [ Frequency Power ];

end