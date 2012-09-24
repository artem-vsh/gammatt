function [ PowerByFrequency ] = signalpower( signal, Fs, WindowName )
%POWER Compute classical square power periodogram
lSignal = length(signal);
if nargin < 3
    WindowName = 'Hann';
end

%% compute periodogram
Welch = spectrum.welch(WindowName);
Hmss = msspectrum(Welch, signal, 'NFFT', lSignal, 'Fs', Fs);

%% return
PowerByFrequency = [ Hmss.Frequencies Hmss.Data ];

end