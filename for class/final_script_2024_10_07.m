%% Independent study presentation
% *Due:* 4/23/24
% 
% *Last updated:* 4/23/24
% 
% *Question*: _Is it possible to assess when someone is pinching based on the 
% EEG data using ML?_
% Workflow:
%% 
% # Import mat data from matfiles (as Fz Finger only) of an entire participant's 
% data (i.e., Pre Post FU). 
% # Import EEG files of Pre Post FU sessions. 
% # Cut the Mat data or EEG data to match up with the first trigger that occurs. 
% # Resample the data to 1000Hz to match the EEG data
% Set paths, make file dirs

% path
mainPath = '/Users/DOB223/Library/CloudStorage/OneDrive-MedicalUniversityofSouthCarolina/Documents/lab/ac/class/1year/2Spring_2024/HRS 725 - Independent Study/MATLAB/model/allFiles';

% create lists of files in the folder with each extension
eegFile = dir(fullfile(mainPath,'*.eeg'));
vhdrDir = dir(fullfile(mainPath,'*.vhdr'));
matDir = dir(fullfile(mainPath,'*.mat'));
%% Import Mat Data (Fz_finger, raw trigger)
% Both sampled at 500Hz originally. Resampling to 1000Hz (matching EEG data) 
% occurs within the loop. 

matData = [];
matData(:,:) = [];
EEGall = [];
EEGall(:,:) = [];

for k = 1:length(matDir)
    temp_matData = load(fullfile(mainPath,matDir(k).name),'loadcell_finger','triggerLabVIEWForce')
    temp_matData = struct2table(temp_matData);
    
    % organzie the temp mat table
    temp_matData = splitvars(temp_matData, 'loadcell_finger');
    temp_matData.Properties.VariableNames(1) = "Fx_finger";
    temp_matData.Properties.VariableNames(2) = "Fy_finger";
    temp_matData.Properties.VariableNames(3) = "Fz_finger";
    temp_matData.Properties.VariableNames(4) = "Mx_finger";
    temp_matData.Properties.VariableNames(5) = "My_finger";
    temp_matData.Properties.VariableNames(6) = "Mz_finger";
    temp_matData = removevars(temp_matData, ["Fx_finger","Fy_finger","Mx_finger","My_finger","Mz_finger"]);

    % upsample the force and trigger data in the temp_matData variable
    temp_matData = table2timetable(temp_matData,"SampleRate",500);
    temp_matData = retime(temp_matData,'Regular','Linear','SampleRate',1000);
    temp_matData = timetable2table(temp_matData);

    temp_matData = removevars(temp_matData,'Time');
%% Import EEG data
% Originally sampled at 1000Hz. Made the Force and Trigger data 1000Hz to match 
% EEG.

    vhdrLoadName = vhdrDir(k).name
    EEG = pop_loadbv([],vhdrLoadName);
    EEGstruct = EEG;
    chan = transpose(double(EEG.data));
    chan = array2table(chan);
%% Cut the EEG or LabView data at the beginning or end depending on whether the EEG trigger or LabView trigger came first
% Now that the EEG, Force, and trigger data are sampled at the same rate, must 
% align them to start at the exact same time

Tstart = find(diff(temp_matData.triggerLabVIEWForce)>0); % get the start trigger times from the initial Force mat file in ms (start = when pt was shown pinch & open cue)
Tstop = find(diff(temp_matData.triggerLabVIEWForce)<0); % get the stop trigger times from initial Force mat file in ms (stop = when pt was shown rest cue)               % figure out how to address the table var triggerLabVIEWForce

    % indexExcel = find(contains(NamingSum,matFileName)); % find goes through every entry in the NamingSum variable and looks for whetehr
    % %the trial name is contained in a cell. should only output 1 cell (for right now, until there is a batch patch)

    %%%%%% set start trigger values %%%%%%
    firstEEGtrig = EEGstruct.event(3).latency;
    firstLabVIEWTrig = Tstart(1);

    %%%%%% set last trigger values %%%%%%
    % lastEEGTrig = EEGstruct(k).event(122).latency;
    % lastLabVIEWTrig = Tstart(120);

    %%%%%% address the start of the recordings %%%%%%  
    if firstEEGtrig > firstLabVIEWTrig
       EEGoffset = firstEEGtrig - firstLabVIEWTrig; % EEGoffset is time difference between first EEG trigger and first labView trigger
       chan = chan(EEGoffset + 1:end,:); % for all values of EEG.data, if the first EEG trigger happened after the first labview trigger, cut the extra EEG data
    else
        %if EMG data is longer at the start cut the EMG data at the start.
        labVIEWoffset = firstLabVIEWTrig - firstEEGtrig;
        % vars in imported mat file have adjusted lengths based on
        % whether EEG or EMG data were longer
        temp_matData.Fz_finger = temp_matData.Fz_finger(EMGoffset + 1:end,:);
                % data.loadcell_thumb = data.loadcell_thumb(EMGoffset+1:end,:);
                % data.dataEMG = data.dataEMG(EMGoffset+1:end,:);
        temp_matData.triggerLabVIEWForce = temp_matData.triggerLabVIEWForce(EMGoffset + 1:end,:);
    end
       
            % % if EEG longer than labView data
            % if  lastEEGTrig > lastLabVIEWTrig
            %     labViewOffset = lastEEGTrig - lastLabVIEWTrig;
            %     chan = chan(1:labViewOffset + 1,:);
            % else
            %     labViewOffset = lastLabVIEWTrig - lastEEGTrig;
            %     temp_matData.Fz_finger = temp_matData.Fz_finger(1:labViewOffset + 1,:)
            %     temp_matData.triggerLabVIEWForce = temp_matData.triggerLabVIEWForce(1:labViewOffset + 1,:)
            % end
            % % 
            % % 
            % % 
    if  height(chan.chan1) > height(temp_matData.Fz_finger)
        longOffset = height(chan) - height(temp_matData);   % difference between height of EEG data and height of Force data
        chan = chan(1:end - longOffset,:);          % make the EEG data begin at normal time but cut off the last part of it because it's too long
    else
        %If labView data is longer at the end, cut the extra labView data.
        otherOffset = height(temp_matData) - height(chan);
        temp_matData = temp_matData(1:end - otherOffset,:);
                % data.loadcell_thumb = data.loadcell_thumb(1:size(EEG.data,2),:);
                % data.dataEMG = data.dataEMG(1:size(EEG.data,2),:);
        %temp_matData.triggerLabVIEWForce = temp_matData.triggerLabVIEWForce(1:end - otherOffset,2);
        % temp_matData.triggerLabVIEWForce = temp_matData.triggerLabVIEWForce(1:height(chan.chan1),:);
        %temp_matData.triggerLabVIEWForce = double(temp_matData.triggerLabVIEWForce(:,longOffset+1:end));
    end
    
    % compile data from each session together so they end up matched
    % together in true time
   
    EEGall = [EEGall;chan];
    matData = [matData;temp_matData];  
    allData = [matData,EEGall];
    % allData = [allData;allData];

end
% get absolute value of force data
allData.Fz_finger = abs(allData.Fz_finger);
%% Make binary 1/0 if force value > 1.5N
% If Fz_finger value >= 1.5N, give 1. Otherwise, give 0.

% initialize isPinch variable
isPinch = zeros(height(allData.Fz_finger),1);
Fz_finger = allData.Fz_finger;
%%
% loop through all rows of allData force values to determine when pinch was
% occurring

for w = 1:height(Fz_finger)
    if Fz_finger(w) > 1.5
        isPinch(w) = 5;
    else
        isPinch(w) = 0;
    end
end

% combine isPinch var to allData
allData = addvars(allData,isPinch);
clear isPinch temp_matData Tstart Tstop longOffset EEGoffset labVIEWoffset
%% Feature extraction

% make window, window overlap, and summary stat
Fs = 1000;
testSignalData = table2array(allData(:,9:10));
dataArr = table2array(allData);
%%
winSec = 1;
sumStat = "max";
sumStat2 = "min";
n = 2000;
nBlocks = floor(length(testSignalData) / n);
tempFFT= [];
resFFT = [];
% win = length(block);
resERP = [];
tempBP = [];
bp = [];
temp_meanPow = [];
meanPow = [];
%%
for r = 1:nBlocks
    startIdx = (r - 1) * n + 1;
    endIdx = r * n;
    block = testSignalData(startIdx:endIdx,1:2);
    tempFFT = fft(block);
    tempERP = max(block);
    tempBP = bandpower(block,Fs,[13,35]);
    resFFT = [resFFT;tempFFT];
    % for j=1:length(nBlocks)
    %     startIdx2 = (j-1) * n + 1;
    %     endIdx2 = j * n;
    %     block = resFFT(startIdx2:endIdx2,1:2);
    %     temp_meanPow = mean(block);
    %     meanPow = [meanPow;temp_meanPow];
    % end
    resERP = [resERP;tempERP];
    bp = [bp;tempBP];
end
%%

blockRes = [resERP,bp];
%%
l = length(testSignalData);
% xFFT = resFFT(1:l/2+1);
sizeFFT = size(testSignalData);
p2 = abs(resFFT / sizeFFT); % positive and negative vals
p1 = p2(1:sizeFFT / 2 + 1); % top half of results up to nyquist
p1(2:end-1) = 2 * p1(2:end - 1);

p1 = movmean(p1,10000);
% freq = Fs*(0:(sizeFFT/2))/sizeFFT;
freq = 0:Fs/length(testSignalData):Fs/2;
ref = freq;
ref(:) = -20;

plot(freq,p1);
% 
% 
% power = (1/(Fs*l)) * abs(xFFT).^2;
% power(2:end-1) = 2 * psd(2:end-1);

% 
% psd = movmean(psd,10000);
% 
% plot(freq,pow2db(psd));
xlabel('Frequency (Hz)')
%% 
% 

l2 = length(tempFFT);
tFFT = tempFFT(1:l2/2+1);
pTemp = (1/(Fs*l2)) * abs(tFFT).^2;
pTemp(2:end - 1) = 2 * pTemp(2:end - 1);
freq2 = 0:Fs / length(tempFFT):Fs / 2;

pTemp = movmean(pTemp,10);

plot(freq2,pTemp)
% ERP calculation

allData2 = table2timetable(allData,"SampleRate",1000);

resTable = retime(allData2,"regular",sumStat,"TimeStep",seconds(winSec));
resTable2 = retime(allData2,"regular",sumStat2,"TimeStep",seconds(winSec));
%resTable2 = retime(allData2,"regular",sumStat2,"TimeStep",seconds(winSec));
%%

resTable = timetable2table(resTable);
resTable2 = timetable2table(resTable2);
%% 
%