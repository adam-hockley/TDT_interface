%% Bulk edit all stimulus parameter files in a directory, be careful!!
% ahockley 17/02/19
clear
clc

folder = 'Z:\Adam\Matlab\Kresge Matlab\SingleUnit\TDT_ParamFiles\';

files = dir(folder);
files = files(~[files.isdir]);
files = {files.name};

for fi = 1:length(files)
    
    load([folder files{fi}]) % Load old parameter file to check previous setting for this thing
%         
%     if param.lev1 == -50
%         param.on1 = 10;
%         param.type1 = 1;
%         param.frq1 = 30000;
%         param.delay1 = 20;
%         param.dur1 = 1;
%         param.rf1 = 0;
%         param.mdp1 = 0;
%         param.mfr1 = 0;
%     end
%     
%     if param.lev2 == -50
%         param.on2 = 10;
%         param.type2 = 1;
%         param.frq2 = 30000;
%         param.delay2 = 20;
%         param.dur2 = 1;
%         param.rf2 = 0;
%         param.mdp2 = 0;
%         param.mfr2 = 0;
%     end
%     
%     if  param.eamp == 0;
%         param.eon = 1;
%         param.etype = 1; % (2 monophasic; 3 biphasic) 
%         param.edelay = 20;
%         param.edur = 1;
%         param.epulsefreq = 0; %(Hz)
%         param.epulsewidth = 0; %(us)
%         param.phasedirup = 1;
%         param.IPgap = 0;
%     end
    
    %% Create epoch matrix and save
    
    if (param.delay1+param.dur1 > param.period) || (param.delay2+param.dur2 > param.period) || (param.edelay+param.edur > param.period)
        error('Stimuli longer than period')
    end
    
    % Convert parameter values to a table of sweeps (epochs)
    FNs = fieldnames(param);
    for i = 1:length(FNs)-1 % Get the length of all fields, to determine which parameters have multiple inputs to loop around
        sizes(i) = length(param.(FNs{i}));
    end
    
    sizes(sizes==1) = nan;
    multlocs = find(sizes>0);
    nPeriods = prod(sizes,'omitnan');
    
    % These loops are messy but work up to 2 orders of permutation
    tempEpochs = table;
    for i = 1:length(FNs)-1 %
        if ~ismember(i,multlocs) % if there's only one parameter value for this
            tempEpochs.(FNs{i})(1:nPeriods,1) = param.(FNs{i});
        elseif i == multlocs(1)
            loopfac = length(param.(FNs{i}));
            for ii = 1:loopfac:nPeriods
                tempEpochs.(FNs{i})(ii:ii+loopfac-1) = param.(FNs{i});
            end
        elseif i == multlocs(2)
            loopfac = nPeriods/length(param.(FNs{i}));
            count = 1;
            for ii = 1:loopfac:nPeriods
                tempEpochs.(FNs{i})(ii:ii+loopfac-1) = param.(FNs{i})(count);
                count = count+1;
            end
        else
            disp('Looping around more than 2 different variables: not yet supported')
        end
    end
    
    % Repeats
    epochs = table;
    for i = 1:param.reps
        epochs = [epochs; tempEpochs];
    end
    
    param.epochs = epochs;
    save([folder files{fi}],'param')
    
end