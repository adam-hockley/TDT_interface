%%% Edit / create TDT stimulus parameter files
% ahockley 07/11/19
clear
clc

folder = 'Z:\Adam\Matlab\TDT_ParamFiles\';


filename = 'RF';
newfilename = 'RF';

load([folder filename]) % Load old parameter file to check previous setting for this thing

%% Set parameters, either one line at a time if editing, or all lines to create new

param.period = 5000;
param.reps = 2;

% Ch1 auditory parameters
param.on1 = 1;
if param.on1 == 1
    param.on1 = 10;         % 10 volts from RZ6...should always be 10
    param.type1 = 0;        % Stimulus type (0noise, 1tone, 2noiseAM, 3toneAM)
    param.lev1 = 6:10:76;        % Stimulus levels
    
%     temp = octspace(4000,64000,10); % upper, lower, and n per octave
%     param.frq1 = temp.center;  % stimulus frequencies
%     param.frq1 = [4000 8000 12000 16000 20000 24000]; % stimulus frequencies
    param.frq1 = [30000];    % stimulus frequencies
    
    param.delay1 = 50;     % delay time before stimulus onset
    param.dur1 = 4900;        % stimulus duration
    param.mdp1 = [0];         % modulation depth
    param.mfr1 = [0];         % modulation frequency
else
    param.on1 = 10;
    param.type1 = 1;
    param.lev1 = -50;
    param.frq1 = 30000;
    param.delay1 = 20;
    param.dur1 = 1;
    param.mdp1 = 0;
    param.mfr1 = 0;
end

% Ch2 auditory parameters
param.on2 = 0;
if param.on2 == 1
    param.on2 = 10;
    param.type2 = 0; %Stimulus type (0noise, 1tone, 2noiseAM, 3toneAM)
    param.lev2 = 80;
    temp = octspace(2000,24000,10); % upper, lower, and n per octave
    param.frq2 = temp.center;
    param.frq2 = 200;
    param.delay2 = 100;
    param.dur2 = 50;
    param.mdp2 = 0;
    param.mfr2 = 0;
else
    param.on2 = 10;
    param.type2 = 1;
    param.lev2 = -50;
    param.frq2 = 30000;
    param.delay2 = 20;
    param.dur2 = 1;
    param.mdp2 = 0;
    param.mfr2 = 0;
end

% Ch3 estim parameters
param.eon = 1;
if param.eon == 1
    param.eamp = 5;          % voltage output from RX8
    param.etype = 2; % (2 monophasic; 3 biphasic)
    % for current step
    %     param.eamp(1:100) = 1;          % voltage output from RX8
    %     param.eamp(101:200) = 2;          % voltage output from RX8
    %     param.eamp(201:300) = 3;          % voltage output from RX8
    %     param.eamp(301:400) = 4;          % voltage output from RX8
    %     param.eamp(401:500) = 5;          % voltage output from RX8
    %     param.eamp(501:600) = 6;          % voltage output from RX8
    %     param.eamp(601:700) = 7;          % voltage output from RX8
    %     param.eamp(701:800) = 8;          % voltage output from RX8
    %     param.eamp(801:900) = 9;          % voltage output from RX8
    
    %     param.eamp(1:1000) = 1; %%% ETEST
    
    param.edelay = 100;          % time of the e-stimulus
    param.edur = 50;             % duration fo the e-stimulus
    param.epulsefreq = 20;    %(Hz) Should be 1000
    param.epulsewidth = 25000;    %(us) Should be 100
    param.phasedirup = 1;
    param.IPgap = 0;
else
    param.eon = 0;
    param.etype = 0; % (2 monophasic; 3 biphasic)
    param.eamp = 0;
    param.edelay = 150;
    param.edur = 0;
    param.epulsefreq = 0; %(Hz)
    param.epulsewidth = 0; %(us)
    param.phasedirup = 1;
    param.IPgap = 0;
%     param.laser = 1.804;
%     param.lpower = [1000 2000];
end


% if param.laser == 1
%     
% end
% lasercalfile =
% load('Z:\7ElectrophysiologySoftware\TDT_Matlab_Interface\Cal\Laser_Calibration_Full.txt');

%% Create epoch matrix and save

if (param.delay1+param.dur1 > param.period) || (param.delay2+param.dur2 > param.period) || (param.edelay+param.edur > param.period)
    error('Stimuli longer than period')
end

% Plot the stimuli created (doesnt show frequency or levels, just on/off timings
figure
hold on
ylim([-0.5 1.5])
xlabel('Time (ms)')
ylabel('on/off')
if param.lev1(1) > -50
    plotline(1:param.period) = 0;
    plotline(param.delay1:param.delay1+param.dur1) = 1;
    plot(1:param.period,plotline,'DisplayName','Audio 1')
end
if param.lev2(1) >-50
    plotline(1:param.period) = 0;
    plotline(param.delay2:param.delay2+param.dur2) = 1;
    plot(1:param.period,plotline,'DisplayName','Audio 2')
end
if param.eamp(1) > 0
    plotline(1:param.period) = 0;
    plotline(param.edelay:param.edelay+param.edur) = 1;
    plot(1:param.period,plotline,'DisplayName','Estim')
end
legend show
title(newfilename)

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

save([folder newfilename '.mat'],'param')
