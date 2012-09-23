function Structure = unitesets( Sets )
%UNITESETS Unite sets of different persons into one set
%   Unite sets of different persons into one set, tahat is a structure
%   with fields data, person, trial, type and electrode

Structure = struct(  ...
    'data',      [], ...
    'person',    [], ...
    'trial',     [], ...
    'type',      [], ...
    'electrode', []      );

for isets = 1:length(Sets)
    for itrial = 1:length(Sets{isets}.trial)
        fprintf(1, 'Set %d, trial %d\n', isets, itrial);
        Structure.data      = [Structure.data      Sets{isets}.trial{itrial}.data     ];
        Structure.person    = [Structure.person    Sets{isets}.trial{itrial}.person   ];
        Structure.trial     = [Structure.trial     Sets{isets}.trial{itrial}.trial    ];
        Structure.type      = [Structure.type      Sets{isets}.trial{itrial}.type     ];
        Structure.electrode = [Structure.electrode Sets{isets}.trial{itrial}.electrode];
    end
end

end

