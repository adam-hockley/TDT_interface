function [fspan] = octspace(fmin, fmax, nPerOctave, varargin)
%OCTSPACE creates logarithmic spacing with 1/n octave bands over a range.
% 
% -------------------------------------------DESCRIPTION--------------------------------------------
% This function creates log spacing for 1/n Octave frequency bands for the range of frequencies
% containing [fmin, fmax]. By default, the reference center-band frequency is set at 1 kHz and
% calculations are preformed using a Base 2 method, but can be changed using the variable input.
% 
% The reference center-band frequency can be specified as any numerical value.
% Available calculation methods are Base 2 and Base 10.
% 
% REFERENCES TO ANSI, IEC, AND JIS STANDARDS.
% 
%     * ANSI S1.11-2004: Specification for octave-band and fractional-octave band analog digital
%         filters, class 1.
%     * IEC 1260 (1995 - 07): Electroacoustics - Octave-band and fractional-octave-band filters,
%         class 1.
%     * JIS C 1514:2002: Electroacoustics - Octave-band and fractional-octave-band filters, class 1.
% 
% Base 2 Method  - center = 2^(1/N);
%                  upper = center*2^(1/2N);
%                  lower = center/2^(1/2N);
% 
% Base 10 Method - center = 10^(3/10N)    OR    2^(3/(10N*log2))
%                  upper = center*10^(3/20N);
%                  lower = center/10^(3/20N);
% 
% --------------------------------------DEVELOPER INFORMATION---------------------------------------
% AUTHORED BY: Allen Beavers
% DATE AUTHORED: 31-Oct-2016
% 
% CURRENT VERSION: 1.2 (R2018b) Allen Beavers, 01-Mar-2019
% -----------------------------------------REVISION HISTORY-----------------------------------------
% Version 1.0 - (R2015b) Original version.
% 
% Version 1.1 - (R2015b) Allen Beavers, 04-Jan-2017
%   - Made corrections to the frequency calculations for even numbered octave-band spacing.
%   - Simplfied code by removing for loops on frequency calculations and vectorizing the trimming
%     process for excess frequencies.
% 
% Version 1.2 - (R2018b) Allen Beavers, 01-Mar-2019
%   - Simplifed code for parsing of the varargin input.
% 
% ------------------------------REQUIRED USER DEFINED FUNCTIONS/FILES-------------------------------
% octspace.m
% 
% --------------------------------------------VARIABLES---------------------------------------------
% INPUT VARIABLE(S)
% fmin - The lower frequency limit to evaluate. [Hz]
% fmax - The upper frequency limit to evaluate. [Hz]
% nPerOctave - The number of frequency bands between octaves.
% varargin - Optional handle and value pair that provides additional functionality.
%  'reference' - Allows the reference center frequency to be specified by providing a numerical
%                value. 1 Hz is typical for seismic analysis, but 1000 Hz is the default.
%       'base' - Allows the logarithmic calculation method to be set to 'base2' (default) or
%               'base10'.
% 
% OUTPUT VARIABLE(S)
% fspan - A structure of vectors containing the minimum, center, and maximum frequencies for each
%         1/n octave band within the specfied frequency range.
%     'fmin' - Minimum band frequencies. [Hz]
%   'center' - Center band frequencies.  [Hz]
%     'fmax' - Maximum band frequencies. [Hz]
% 
% ---------------------------------------------EXAMPLES---------------------------------------------
% % Create 1/6th octave band between 0.1 to 50 Hz and center reference frequency at 1 Hz.
% fspan = octspace(0.1,50,6,'ref',1,'base',10);
% 
% % Generate plot with RS profiles
% Freq = [0.1,1.3,8.3,33.3,50];
% Horz = [0.48,4.8,4.8,3.6,3.6];
% Vert = [0.201,2.01,2.01,0.81,0.81];
% figure
% loglog(Freq,Horz,'-*',Freq,Vert,'-*','LineWidth',2)
% legend({'RS-Horizontal Motion','RS-Vertical Motion'},'AutoUpdate','off','Location','se')
% title('Response Spectra showing 1/6th Octave Band Spacing')
% xlabel('Frequency (Hz)')
% ylabel('Response Acceleration (g)')
% xlim([0.1,50])
% ylim([0.1,10])
% 
% % Create patches for everyother frequency band
% for i=1:2:length(fspan.center)
%     patch('Vertices',[fspan.low(i),0.1;fspan.low(i),10;fspan.high(i),10;fspan.high(i),0.1],...
%         'Faces',1:4,'FaceColor',[1,0,0],'FaceAlpha',0.1)
% end
% set(gca,'children',flipud(get(gca,'children'))) % Reverse order of axes children
% 
%% -----------------------------------------BEGIN FUNCTION------------------------------------------
% Initialize defaults variables
v.reference = 1000; % Reference frequency for band center, (Hz)
v.base = 'base2'; % Logarithmic method
    
% Parse varargin inputs to structure 'v'.
if ~isempty(varargin)
    p = inputParser;
    validBase = @(x) any(strcmpi(x,{'base2','base10','2','10'})) || ismember(x,[2,10]);
    addParameter(p,'reference',v.reference,@isnumeric);
    addParameter(p,'base',v.base,validBase);
    try
        parse(p,varargin{:})
    catch e
        disp(e)
    end
    v = p.Results;
    clearvars p
end
% Approximate the min and max band frequency limits
min = floor(log2(fmin/v.reference))*nPerOctave;
max = ceil(log2(fmax/v.reference))*nPerOctave;
% Calculate based on method selection
switch v.base
    case {'base2','2',2}
        i = (min:max)';
        freqs = v.reference*2.^(i/nPerOctave);
        fd = 2^(1/(2*nPerOctave));
    case {'base10','10',10}
        i = (min:max)';
        freqs = v.reference*10.^(0.3*(i/nPerOctave));
        fd = 10^(3/(20*nPerOctave));
end
% Create array with lower, center, and upper band frequencies
freqs = [freqs/fd,freqs,freqs*fd];
% Trim frequency bands that are beyond the range of fmin and fmax
freqs = freqs(nnz(freqs(:,1)<=fmin):end,:); % Trims less than fmin
freqs = freqs(1:nnz(freqs(:,1)<=fmax),:); % Trims higher than fmax
% Construct fspan structure
fspan.low = freqs(:,1);
fspan.center = freqs(:,2);
fspan.high = freqs(:,3);
end
% -------------------------------------------END FUNCTION-------------------------------------------
% -------------------------------------Written by Allen Beavers-------------------------------------

