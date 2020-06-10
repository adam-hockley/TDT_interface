%% Run TDT using API
% ahockley 07/11/19
% Ensure enitre TDT_Matlab_Interface folder is in the path
clear

%% Chose which stimulus files to be presented in this block, in order
filenames = {'RF_highres'};
% filenames = {'RF'}; % Chose which stimulus files to be presented in this block, in order
% filenames = {'RLF_Tone_50reps','Spont_180s'}; % Chose which stimulus files to be presented in this block, in order

%% Randomise the orders. 1/0 for each stimulus set (length must match filenames)
randit = [1];

%% System mode to run as: 2 (Preview), 3 (Block 1Record)
State = 3;

%% Choose folder containing stimulus parameter files
% folder = 'Z:\Adam\Matlab\Kresge Matlab\SingleUnit\TDT_ParamFiles\';
folder = '\\maize.umhsnas.med.umich.edu\khri-ses-lab\Mike\Analysis\MatlabCode\TDT_Matlab_Parameters\';
% folder = 'Z:\RobertsLab\TDT_ParamFiles\';

%% Choose calibration file
calfile = load('C:\TDT\Synapse\CalFiles\5431_200205_SU.txt'); % Choose the calibration file to use

%% Choose hardware
AudioHardware = 'RZ6(2)'; %Device producing audio (RZ6; check the number in brackets matches synapse)
EStimHardware = 'RX8(1)'; % Device prducing EStim (RX8; check the number in brackets matches synapse)

%% Run TDT function
Run_TDT(folder,filenames,State,randit,calfile,AudioHardware,EStimHardware)