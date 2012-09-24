function [ PowerByFrequency ] = signalpower( signal, Fs, WindowName, DowntoFrequency )
%POWER Compute classical square power periodogram
lSignal = length(signal);
if nargin < 3
    WindowName = 'Hann';
end
if nargin < 4
    DowntoFrequency = Fs / lSignal;
end

%% compute periodogram
Welch = spectrum.welch(WindowName, Fs / DowntoFrequency);
Hmss = msspectrum(Welch, signal, 'NFFT', lSignal, 'Fs', Fs);

%% return
PowerByFrequency = [ Hmss.Frequencies Hmss.Data ];

end