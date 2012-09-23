function [ PowerByFrequency ] = signalpower( signal, Fs, window )
%POWER Compute classical square power periodogram
lSignal = length(signal);
if nargin < 3
    window = [];
end

%% prepare window
if ischar(window)
    switch window
        case 'Hann'
            window = hann(lSignal);
    end
elseif isnumeric(window) && length(window) == length(signal)
    % NOOP, use that window
else
    window = hann(lSignal); % default to Hann if none specified
end

%% compute periodogram
[ PowerPerHz, Frequency ] = periodogram(signal, window, lSignal, Fs);

%% convert power/hz to power
Power = PowerPerHz .* Frequency;

%% return
PowerByFrequency = [ Frequency Power ];

end