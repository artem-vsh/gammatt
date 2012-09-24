function Structure = loadpower( EEG, Person, Trial, ...
                                IntervalsStart, IntervalWidth, ...
                                IntervalStep, IntervalsFinish, ...
                                FrequencyStart, FrequencyStep, ...
                                FrequencyFinish )
%LOADPOWS Computes powers of a set at given epochs and intervals
%   Computes powers of a set at given epochs and intervals
%
%   DEPENDS ON: eeglab

if isempty(IntervalWidth) && isempty(IntervalStep)
    IntervalWidth = IntervalFinish - IntervalStart;
    IntervalStep  = 0;
end

%% convert inputs from seconds to sampling offsets
StartOffset  = IntervalsStart  * EEG.srate;
Width        = IntervalWidth   * EEG.srate;
Step         = IntervalStep    * EEG.srate;
FinishOffset = IntervalsFinish * EEG.srate;

%% compute basic inputs
EEG           = pop_epoch(EEG, {}, [IntervalsStart IntervalsFinish]);
RawIntervals  = [((0:Step:(FinishOffset-StartOffset-Width)) + 1)' ...
                 (Width:Step:(FinishOffset-StartOffset))'             ];
Frequencies   = FrequencyStart:FrequencyStep:FrequencyFinish;

%% compute average power
% TODO: maybe, it should be split to the separate function?
Power = zeros(size(EEG.data, 1), ...  % electrodes
                     size(EEG.data, 3));     % epochs
for ElectrodeOffset = 1:size(EEG.data, 1)
    for EpochOffset = 1:size(EEG.data, 3)
        for IntervalOffset = 1:size(RawIntervals, 1)
            Interval = RawIntervals(IntervalOffset, 1) : ...
                       RawIntervals(IntervalOffset, 2);
            LocalData = EEG.data(ElectrodeOffset, ...
                                 Interval, ...
                                 EpochOffset);
            FrequencyByPower = signalpower(LocalData, EEG.srate, ...
                                           'Hann', FrequencyStart);
            
            SumPowerAtGivenFrequencies = 0;
            for Frequency = Frequencies
                SumPowerAtGivenFrequencies = SumPowerAtGivenFrequencies + ...
                    signalpoweratfreq(FrequencyByPower, Frequency);
            end
            
            Power(ElectrodeOffset, EpochOffset, IntervalOffset) = ...
                SumPowerAtGivenFrequencies / length(LocalData);
        end
    end
end

%% preallocate output structure
Structure = struct('data', [], 'person', [], ...
                   'trial', [], 'type', [],  ...
                   'electrode', [], 'interval', []);
Structure.person    = {};
Structure.type      = {};
Structure.electrode = {};

%% process each epoch to gather its data into our unified form
for EpochOffset = 1:length(EEG.epoch)
    epoch   = EEG.epoch(EpochOffset);
    % determine main event position by finding event with 0 offset
    EventLatencies = epoch.eventlatency;
    if iscell(EventLatencies)
        EventLatencies = cell2mat(EventLatencies);
    end
    CentralEvent = EventLatencies == 0;
    
    % process raw data, it should fit our format
    % first we take our epoch and cleanse redundant axis
    Data          = squeeze(Power(:,EpochOffset,:));
    lData         = size(Data); % 1 -> electrodes, 2 -> intervals
    % then we unite different electrodes measurement to one row
    DataShaped    = reshape(Data', 1, []);
    lDataShaped   = length(DataShaped);
    
    % main event type
    Type = epoch.eventtype(CentralEvent);
    
    % gather required data into one united matrix group
    % for each ith element of data ith element of other structures
    % will describe some side of the observation, such as its main event
    % type
    Structure.data   = [Structure.data   DataShaped];
    Structure.person = [Structure.person repmat(Person, 1, lDataShaped)];
    Structure.trial  = [Structure.trial  repmat(Trial,  1, lDataShaped)];
    Structure.type   = [Structure.type   repmat(Type,   1, lDataShaped)];
    
    % for epoch we have to 
    for ielectrode = 1:lData(1)
        Structure.electrode = [ ...
            Structure.electrode ...
            repmat({EEG.chanlocs(ielectrode).labels}, 1, ...
                    lData(2)) ];
    end
    Structure.interval = [ ...
        Structure.interval ...
        repmat(1:lData(2), 1, lData(1)) ];
end

% cleaning up the data to save memory
EEG.data = [];

end

