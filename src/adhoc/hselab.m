%% preload packages
eeglab;

%% load and unite sets
sets = loadsets(path, '', '_', '.set', {'Fz', 'Cz', 'Pz'}, ...
    @(eeg, p, t) loadpower(eeg, p, t, -0.85, 0.85, 0.85, 0.85, 32, 8, 48));
united = unitesets(sets);

%% compute anova
[p table stat] = anovan(united.data, ...
    { united.type, united.interval, united.electrode, united.trial }, ...
    'varnames', { 'Тип', 'Интервал', 'Электрод', 'Серия' }, ...
    'model', 'full', 'sstype', 2);

%% compute persons' score
Scores = struct( 'person', [], 'score', [] );
for Set = sets
    Mask = strcmp(united.person, Set{1}.name);
    Score = sum(strcmp(united.type(Mask), '8')) / ...
            sum(strcmp(united.type(Mask), '4'));
    Scores.person = [ Scores.person Set{1}.name ];
    Scores.score  = [ Scores.score  Score       ];
end
ScoresMean = median(Scores.score);

%% differentiate by mean
LosersMask = Scores.score <= ScoresMean;
Losers = Scores.person(LosersMask);

LosersUnitedMask = strcmp(united.person, Losers{1});
for LoserOffset = 2:length(Losers)
    LosersUnitedMask = LosersUnitedMask | ...
        strcmp(united.person, Losers{LoserOffset});
end

[pLosers, tableLosers, statLosers] = anova1(united.data, LosersUnitedMask);