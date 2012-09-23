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
        Power = (FreqByPower(Left, 2) + FreqByPower(Right, 2)) / 2;
    end
end

end

