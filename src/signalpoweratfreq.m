function [ Power ] = signalpoweratfreq( FreqByPower, Freq )
%SIGNALPOWERATFREQ Find power at specified freq
%   If FreqByPower is of form [ ... ; f p ; ... ], return p
%   else iif FreqByPower is of form [ ... ; f-a p ; f+b q ; ... ], a,b > 0
%   return (p-q)/2

Exact = FreqByPower(:, 1) == Freq;
if any(Exact)
    Power = FreqByPower(Exact, 2);
else
    Deviations = FreqByPower(:, 1) - Freq;
    Left = Deviations == max(Deviations(Deviations < 0));
    Right = Deviations == min(Deviations(Deviations > 0));
    if ~any(Left)
        Power = FreqByPower(Right, 2); % returns [] on ~Left && ~Right
    elseif ~any(Right)
        Power = FreqByPower(Left, 2);
    else
        % use linear model to estimate power at fiven frequency
        % why lm and not average? consider xs = [1; 100], ys = [1; 100]
        % and given x = 5, if we average, we estimate 50.5, if we use
        % lm, we estimate 5, which is closer as closer neighbour
        % gains more influence
        % (Freq-Left) and (Freq-Right) tend to be small, so we can try
        % to use linear estimation even if the relationship is not linear
        XY = [FreqByPower(Left, :) ; FreqByPower(Right, :)];
        Model = LinearModel.fit(XY(:, 1), XY(:, 2));
        Power = Model.predict(Freq);
    end
end

end

