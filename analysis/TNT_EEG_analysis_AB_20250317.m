
% EEG analysis for 2024 MUSC SRD
% Preliminary analysis of TNT EEG data

% Created by AB on 2024-08-29
% Last modified on 2025-01-24

% summary of changes on 2025-01-24:
% 1. made code accept those with weird # of trial (e.g., multiple runs)

%% here we go
close all
clear vars

%% paths
pathData = pwd;
excelPath = '/Users/DOB223/Library/CloudStorage/OneDrive-MedicalUniversityofSouthCarolina/Documents/lab/studies/1eeg/TNTanalysis/step9excel';

% Denote region pairs (n = 28)

% change these to grab from the data instead of using these labels. take
% from excel file (or mat).
pairsCccChar={'PML-S1L';'PML-M1L';'PML-SML';'S1L-M1L';'S1L-SML';'M1L-SML'; ... % ab changed 6th value on 10/25/24 to match step9layout20240820.mat file. it was duplicate M1L-S1L
    'PML-PMN';'PML-S1N';'PML-M1N';'PML-SMN'; ...
    'S1L-PMN';'S1L-S1N';'S1L-M1N';'S1L-SMN'; ...
    'M1L-PMN';'M1L-S1N';'M1L-M1N';'M1L-SMN'; ...
    'SML-PMN';'SML-S1N';'SML-M1N';'SML-SMN'; ...
    'PMN-S1N';'PMN-M1N';'PMN-SMN';'S1N-M1N';'S1N-SMN';'M1N-SMN'};

%% get file names from path step9excel folder
excelFileNames = dir(fullfile(excelPath,'*.xlsm'));
excelFileNames = string(transpose(extractfield(excelFileNames,'name')));

% make list of all Pt ID's that will be analyzed
allPtID = [];
for L = 1:length(excelFileNames)
    tempID = extractBefore(excelFileNames(L),'_');
    allPtID = [allPtID;tempID];
end
clear tempID L

% get list of sheets from step9excel files
sheetsToRead = {'reason','CCC alpha NoVib','CCC beta NoVib','APB beta NoVib','FDI beta NoVib','FDS beta NoVib','EDC beta NoVib',...
    'APB gamma NoVib','FDI gamma NoVib','FDS gamma NoVib','EDC gamma NoVib','CCC alpha Vib','CCC beta Vib','APB beta Vib','FDI beta Vib',...
    'FDS beta Vib','EDC beta Vib','APB gamma Vib','FDI gamma Vib','FDS gamma Vib','EDC gamma Vib'};

%% import WMFT data
% ab updated 2024-10-23 to have new WMFT scores after blinded rater assessment
cd('..')
allDataTNT = readtable("TNT_WMFT_compiled_scores_2024_02_14_AB SRD.xlsx");
subjID = table(allDataTNT.Subject);
subjID.Properties.VariableNames(1) = "subjID";
wolfTime = table(allDataTNT.x_avgColumnAF_);
wolfTime.Properties.VariableNames(1) = "avgWolfTimes";
timePoint = table(allDataTNT.OriginalVideoName);
timePoint.Properties.VariableNames(1) = "timePoint";
% merge to have one table containing all subjID, timePoint, wolf data
wolfData = horzcat(subjID,timePoint,wolfTime);

% finish changing the naming convention of the subjID
for sirius=1:length(wolfData.subjID)
    currentID = wolfData.subjID(sirius);
    if length(wolfData.subjID{sirius}) == 6
        wolfData.subjID{sirius} = regexprep(currentID,'TNT0+','TNT');
    end
end
% rename the timepoints i want. Account for all the variability in file
% names.
for scabbers=1:length(wolfData.timePoint)
    currentID = wolfData.timePoint{scabbers};
    if contains(wolfData.timePoint{scabbers},"Baseline")
        wolfData.timePoint{scabbers} = "Baseline";
    elseif contains(wolfData.timePoint{scabbers},"BASELINE")
        wolfData.timePoint{scabbers} = "Baseline";
    elseif contains(wolfData.timePoint{scabbers},"B1")
        wolfData.timePoint{scabbers} = "Baseline";
    elseif contains(wolfData.timePoint{scabbers},"Post")
        wolfData.timePoint{scabbers} = "Post";
    elseif contains(wolfData.timePoint{scabbers},"POST")
        wolfData.timePoint{scabbers} = "Post";
    elseif contains(wolfData.timePoint{scabbers},"post")
        wolfData.timePoint{scabbers} = "Post";
    elseif contains(wolfData.timePoint{scabbers},"FU")
        wolfData.timePoint{scabbers} = "FU";
    elseif contains(wolfData.timePoint{scabbers},"FollowUp")
        wolfData.timePoint{scabbers} = "FU";
    elseif contains(wolfData.timePoint{scabbers},"Follow-Up")
        wolfData.timePoint{scabbers} = "FU";
    end
end
timeLabels = {'Pre','Post','Follow up'};
timeLabels2 = ["Baseline","Post","FU"];
wolfData.timePoint = cellstr(wolfData.timePoint);
clear Pre Post FU timePoint wolfTime subjID currentID sirius scabbers
%%
% initialize tables for later storage of all data across pts for each
% condition
allAlphaPrepNV = table(ones(3,28));
allAlphaExeNV = table(ones(3,28));
allBetaPrepNV = table(ones(3,28));
allBetaExeNV = table(ones(3,28));

% make array to tables for easy access
tableArray = {allAlphaPrepNV,allAlphaExeNV,allBetaPrepNV,allBetaExeNV};

% change column names of these tables
for q = 1:length(tableArray)
    currentTbl = tableArray{q};
    currentTbl = splitvars(currentTbl, 'Var1');
    currentTbl = renamevars(currentTbl,1:28,pairsCccChar);
    tableArray{q} = currentTbl;
end
clear currentTbl q

% overwrite the original tables in tableArray to the updated tables
allAlphaPrepNV = tableArray{1};
allAlphaExeNV = tableArray{2};
allBetaPrepNV = tableArray{3};
allBetaExeNV = tableArray{4};

masterAlphaPrep = [];
masterAlphaExe = [];
masterBetaPrep = [];
masterBetaExe = [];

%% start loop to compile data
for y = 1:length(excelFileNames)
    % name current excel file
    currentExcelFile = excelFileNames(y);
    % take pt ID from current excel file
    currentPt = string(extractBefore(currentExcelFile,'_'));
    % print ID to cmd window
    disp(['currently processing'  currentPt]);

    % figure out later - making import more efficient
    % for r=1:length(sheetToRead)
    %     currentTable = readtable(currentExcelFile,'Sheet',sheetToRead{r});
    %     currentTable =

    % getting data from step9 excels
    dataCCCAlphaNV(y) = {readtable(fullfile('step9excel',excelFileNames(y)),'Sheet','CCC Alpha NoVib')};
    dataCCCAlphaV(y) = {readtable(fullfile('step9excel',excelFileNames(y)),'Sheet','CCC Alpha Vib')};
    dataCCCBetaNV(y) = {readtable(fullfile('step9excel',excelFileNames(y)),'Sheet','CCC Beta NoVib')};
    dataCCCBetaV(y) = {readtable(fullfile('step9excel',excelFileNames(y)),'Sheet','CCC Beta Vib')};

    %% NEW ADDITION 2025-01-24
    % Extract filename column for NoVib trials
    filenameColNV = dataCCCAlphaNV{y}.Var1;
    % Find indices of "Post" and "FU" within NoVib filenames
    postIdxNV = find(contains(filenameColNV, 'Post', 'IgnoreCase', true), 1);
    fuIdxNV   = find(contains(filenameColNV, 'FU', 'IgnoreCase', true), 1);

    % Find # of trials for NV based on session (Pre Post or FU)
    % need to do this bc it is not 60 in some cases, like if there were >2 runs
    preTrialsAvailableNV  = postIdxNV - 4; % Adjust for first 3 non-trial rows
    postTrialsAvailableNV = fuIdxNV - postIdxNV;
    fuTrialsAvailableNV   = size(dataCCCAlphaNV{y}, 1) - fuIdxNV + 1;

    % now do the same for Vib
    filenameColV = dataCCCAlphaV{y}.Var1;
    % Find indices of "Post" and "FU" within Vib filenames
    postIdxV = find(contains(filenameColV, 'Post', 'IgnoreCase', true), 1);
    fuIdxV   = find(contains(filenameColV, 'FU', 'IgnoreCase', true), 1);

    preTrialsAvailableV  = postIdxV - 4; % Adjust for first 3 non-trial rows
    postTrialsAvailableV = fuIdxV - postIdxV;
    fuTrialsAvailableV   = size(dataCCCAlphaV{y}, 1) - fuIdxV + 1;

    %%
    %for
    % % apb
    % dataCMCBetaNV_APB(y) = {readtable(fullfile('step9excel',excelFileNames(y)),'Sheet','APB beta NoVib')};
    % dataCMCBetaV_APB(y) = {readtable(fullfile('step9excel',excelFileNames(y)),'Sheet','APB beta Vib')};
    % dataCMCGammaNV_APB(y) = {readtable(fullfile('step9excel',excelFileNames(y)),'Sheet','APB gamma NoVib')};
    % dataCMCGammaV_APB(y) = {readtable(fullfile('step9excel',excelFileNames(y)),'Sheet','APB gamma Vib')};
    %
    % % fdi
    % dataCMCBetaNV_FDI(y) = {readtable(fullfile('step9excel',excelFileNames(y)),'Sheet','FDI beta NoVib')};
    % dataCMCBetaV_FDI(y) = {readtable(fullfile('step9excel',excelFileNames(y)),'Sheet','FDI beta Vib')};
    % dataCMCGammaNV_FDI(y) = {readtable(fullfile('step9excel',excelFileNames(y)),'Sheet','FDI gamma NoVib')};
    % dataCMCGammaV_FDI(y) = {readtable(fullfile('step9excel',excelFileNames(y)),'Sheet','FDI gamma Vib')};
    %
    % % fds
    % dataCMCBetaNV_FDS(y) = {readtable(fullfile('step9excel',excelFileNames(y)),'Sheet','FDS beta NoVib')};
    % dataCMCBetaV_FDS(y) = {readtable(fullfile('step9excel',excelFileNames(y)),'Sheet','FDS beta Vib')};
    % dataCMCGammaNV_FDS(y) = {readtable(fullfile('step9excel',excelFileNames(y)),'Sheet','FDS gamma NoVib')};
    % dataCMCGammaV_FDS(y) = {readtable(fullfile('step9excel',excelFileNames(y)),'Sheet','FDS gamma Vib')};
    %
    % % edc
    % dataCMCBetaNV_EDC(y) = {readtable(fullfile('step9excel',excelFileNames(y)),'Sheet','EDC beta NoVib')};
    % dataCMCBetaV_EDC(y) = {readtable(fullfile('step9excel',excelFileNames(y)),'Sheet','EDC beta Vib')};
    % dataCMCGammaNV_EDC(y) = {readtable(fullfile('step9excel',excelFileNames(y)),'Sheet','EDC gamma NoVib')};
    % dataCMCGammaV_EDC(y) = {readtable(fullfile('step9excel',excelFileNames(y)),'Sheet','EDC gamma Vib')};

    %% Parse out the time segments (-5to-3, -4to-2, etc...) and exclusions
    % exclusions %%
    exclusion2NV = dataCCCAlphaNV{y}(4:end,5:6);
    % exclusion2V{y} = dataCCCAlphaV{y}(:,5:6);

    % change col names
    exclusion2NV.Properties.VariableNames(1) = "pinchIncludeTrial";
    exclusion2NV.Properties.VariableNames(2) = "openIncludeTrial";
    % exclusion2V{1, 1}.Properties.VariableNames(1) = "pinch";
    % exclusion2V{1, 1}.Properties.VariableNames(2) = "open";

    %% alpha CCC %%

    %%%% ab updated this 2/4/25 %%%%%

    %%%% Pre alpha NoVib CCC %%%
    % PrePinchNegFiveToThreeNV = dataCCCAlphaNV{y}(4:63,9:36);
    % PrePinchNegFiveToThreeNV.Properties.VariableNames = pairsCccChar;
    % PrePinchNegFourToTwoNV = dataCCCAlphaNV{y}(4:63,38:65);
    % PrePinchNegFourToTwoNV.Properties.VariableNames = pairsCccChar;
    % PrePinchNegThreeToOneNV = dataCCCAlphaNV{y}(4:63,67:94);
    % PrePinchNegThreeToOneNV.Properties.VariableNames = pairsCccChar;

    % Updated 2/4/25 by AB to start accounting for extra runs
    % need to make the same changes to the other segments
    PrePinchNegTwoToZeroNV = dataCCCAlphaNV{y}(4:3+preTrialsAvailableNV,96:123);
    PrePinchNegTwoToZeroNV.Properties.VariableNames = pairsCccChar;

    % PrePinchNegOneToOneNV = dataCCCAlphaNV{y}(4:63,125:152);
    % PrePinchNegOneToOneNV.Properties.VariableNames = pairsCccChar;

    PrePinchZeroToTwoNV = dataCCCAlphaNV{y}(4:3+preTrialsAvailableNV,154:181);
    PrePinchZeroToTwoNV.Properties.VariableNames = pairsCccChar;
    % PrePinchOnetoThreeNV = dataCCCAlphaNV{y}(4:63,183:210);
    % PrePinchOnetoThreeNV.Properties.VariableNames = pairsCccChar;
    % PrePinchTwoToFourNV = dataCCCAlphaNV{y}(4:63,212:239);
    % PrePinchTwoToFourNV.Properties.VariableNames = pairsCccChar;
    % PrePinchThreeToFiveNV = dataCCCAlphaNV{y}(4:63,241:268);
    % PrePinchThreeToFiveNV.Properties.VariableNames = pairsCccChar;

    % alpha Pre Vib CCC
    % PrePinchNegFiveToThreeV = dataCCCAlphaV{y}(4:63,9:36);
    % PrePinchNegFiveToThreeV.Properties.VariableNames = pairsCccChar;
    % PrePinchNegFourToTwoV = dataCCCAlphaV{y}(4:63,38:65);
    % PrePinchNegFourToTwoV.Properties.VariableNames = pairsCccChar;
    % PrePinchNegThreeToOneV = dataCCCAlphaV{y}(4:63,67:94);
    % PrePinchNegThreeToOneV.Properties.VariableNames = pairsCccChar;

    PrePinchNegTwoToZeroV = dataCCCAlphaV{y}(4:3+preTrialsAvailableV,96:123);
    PrePinchNegTwoToZeroV.Properties.VariableNames = pairsCccChar;

    % PrePinchNegOneToOneV = dataCCCAlphaV{y}(4:63,125:152);
    % PrePinchNegOneToOneV.Properties.VariableNames = pairsCccChar;

    PrePinchZeroToTwoV = dataCCCAlphaV{y}(4:3+preTrialsAvailableV,154:181);
    PrePinchZeroToTwoV.Properties.VariableNames = pairsCccChar;

    % PrePinchOnetoThreeV = dataCCCAlphaV{y}(4:63,183:210);
    % PrePinchOnetoThreeV.Properties.VariableNames = pairsCccChar;
    % PrePinchTwoToFourV = dataCCCAlphaV{y}(4:63,212:239);
    % PrePinchTwoToFourV.Properties.VariableNames = pairsCccChar;
    % PrePinchThreeToFiveV = dataCCCAlphaV{y}(4:63,241:268);
    % PrePinchThreeToFiveV.Properties.VariableNames = pairsCccChar;

    %%% check if there is post section. if yes, continue. otherwise, end %%

    % if height(dataCCCAlphaNV(y)) && height(dataCCCAlphaV(y)) < 60
    %     break;
    % else
    %     continue;
    % end

    %% Now the same for Post CCC alpha NoVib

    % alpha Post NoVib CCC
    % PostPinchNegFiveToThreeNV = dataCCCAlphaNV{y}(64:123,9:36);
    % PostPinchNegFiveToThreeNV.Properties.VariableNames = pairsCccChar;
    % PostPinchNegFourToTwoNV = dataCCCAlphaNV{y}(64:123,38:65);
    % PostPinchNegFourToTwoNV.Properties.VariableNames = pairsCccChar;
    % PostPinchNegThreeToOneNV = dataCCCAlphaNV{y}(64:123,67:94);
    % PostPinchNegThreeToOneNV.Properties.VariableNames = pairsCccChar;

    % ab updated 2/4/25 - update the others too
    PostPinchNegTwoToZeroNV = dataCCCAlphaNV{y}(postIdxNV:postIdxNV + postTrialsAvailableNV-1,96:123);
    PostPinchNegTwoToZeroNV.Properties.VariableNames = pairsCccChar;

    % PostPinchNegOneToOneNV = dataCCCAlphaNV{y}(64:123,125:152);
    % PostPinchNegOneToOneNV.Properties.VariableNames = pairsCccChar;

    % updated 2/4/25 ab
    PostPinchZeroToTwoNV = dataCCCAlphaNV{y}(postIdxNV:postIdxNV + postTrialsAvailableNV-1,154:181);
    PostPinchZeroToTwoNV.Properties.VariableNames = pairsCccChar;

    % PostPinchOnetoThreeNV = dataCCCAlphaNV{y}(64:123,183:210);
    % PostPinchOnetoThreeNV.Properties.VariableNames = pairsCccChar;
    % PostPinchTwoToFourNV = dataCCCAlphaNV{y}(64:123,212:239);
    % PostPinchTwoToFourNV.Properties.VariableNames = pairsCccChar;
    % PostPinchThreeToFiveNV = dataCCCAlphaNV{y}(64:123,241:268);
    % PostPinchThreeToFiveNV.Properties.VariableNames = pairsCccChar;

    %% alpha Post Vib CCC

    % PostPinchNegFiveToThreeV = dataCCCAlphaV{y}(64:123,9:36);
    % PostPinchNegFiveToThreeV.Properties.VariableNames = pairsCccChar;
    % PostPinchNegFourToTwoV = dataCCCAlphaV{y}(64:123,38:65);
    % PostPinchNegFourToTwoV.Properties.VariableNames = pairsCccChar;
    % PostPinchNegThreeToOneV = dataCCCAlphaV{y}(64:123,67:94);
    % PostPinchNegThreeToOneV.Properties.VariableNames = pairsCccChar;


    PostPinchNegTwoToZeroV = dataCCCAlphaV{y}(postIdxV:postIdxV + postTrialsAvailableV-1,96:123);
    PostPinchNegTwoToZeroV.Properties.VariableNames = pairsCccChar;


    % PostPinchNegOneToOneV = dataCCCAlphaV{y}(64:123,125:152);
    % PostPinchNegOneToOneV.Properties.VariableNames = pairsCccChar;


    PostPinchZeroToTwoV = dataCCCAlphaV{y}(postIdxV:postIdxV + postTrialsAvailableV-1,154:181);
    PostPinchZeroToTwoV.Properties.VariableNames = pairsCccChar;


    % PostPinchOnetoThreeV = dataCCCAlphaV{y}(64:123,183:210);
    % PostPinchOnetoThreeV.Properties.VariableNames = pairsCccChar;
    % PostPinchTwoToFourV = dataCCCAlphaV{y}(64:123,212:239);
    % PostPinchTwoToFourV.Properties.VariableNames = pairsCccChar;
    % PostPinchThreeToFiveV = dataCCCAlphaV{y}(64:123,241:268);
    % PostPinchThreeToFiveV.Properties.VariableNames = pairsCccChar;

    %%%% check if there is FU section. If yes, continue. otherwsie end %%%
    % if height(dataCCCAlphaNV(y)) && height(dataCCCAlphaV(y)) > 120
    %     continue
    % else
    %     break;
    % end

    %% FU CCC alpha NoVib

    % find # rows of entire sheet, use for locating FU trials
    lastRowNV = size(dataCCCAlphaNV{y},1);

    % alpha FU NoVib CCC
    % FUPinchNegFiveToThreeNV = dataCCCAlphaNV{y}(124:183,9:36);
    % FUPinchNegFiveToThreeNV.Properties.VariableNames = pairsCccChar;
    % FUPinchNegFourToTwoNV = dataCCCAlphaNV{y}(124:183,38:65);
    % FUPinchNegFourToTwoNV.Properties.VariableNames = pairsCccChar;
    % FUPinchNegThreeToOneNV = dataCCCAlphaNV{y}(124:183,67:94);
    % FUPinchNegThreeToOneNV.Properties.VariableNames = pairsCccChar;

    FUPinchNegTwoToZeroNV = dataCCCAlphaNV{y}(lastRowNV-fuTrialsAvailableNV+1:lastRowNV, 96:123);
    FUPinchNegTwoToZeroNV.Properties.VariableNames = pairsCccChar;

    % FUPinchNegOneToOneNV = dataCCCAlphaNV{y}(124:183,125:152);
    % FUPinchNegOneToOneNV.Properties.VariableNames = pairsCccChar;

    FUPinchZeroToTwoNV = dataCCCAlphaNV{y}(lastRowNV-fuTrialsAvailableNV+1:lastRowNV, 154:181);
    FUPinchZeroToTwoNV.Properties.VariableNames = pairsCccChar;

    % FUPinchOnetoThreeNV = dataCCCAlphaNV{y}(124:183,183:210);
    % FUPinchOnetoThreeNV.Properties.VariableNames = pairsCccChar;
    % FUPinchTwoToFourNV = dataCCCAlphaNV{y}(124:183,212:239);
    % FUPinchTwoToFourNV.Properties.VariableNames = pairsCccChar;
    % FUPinchThreeToFiveNV = dataCCCAlphaNV{y}(124:183,241:268);
    % FUPinchThreeToFiveNV.Properties.VariableNames = pairsCccChar;

    %% alpha FU Vib CCC
    lastRowV = size(dataCCCAlphaV{y},1);
    % FUPinchNegFiveToThreeV = dataCCCAlphaV{y}(124:183,9:36);
    % FUPinchNegFiveToThreeV.Properties.VariableNames = pairsCccChar;
    % FUPinchNegFourToTwoV = dataCCCAlphaV{y}(124:183,38:65);
    % FUPinchNegFourToTwoV.Properties.VariableNames = pairsCccChar;
    % FUPinchNegThreeToOneV = dataCCCAlphaV{y}(124:183,67:94);
    % FUPinchNegThreeToOneV.Properties.VariableNames = pairsCccChar;


    FUPinchNegTwoToZeroV = dataCCCAlphaV{y}(lastRowV-fuTrialsAvailableV+1:lastRowV,96:123);
    FUPinchNegTwoToZeroV.Properties.VariableNames = pairsCccChar;


    % FUPinchNegOneToOneV = dataCCCAlphaV{y}(124:183,125:152);
    % FUPinchNegOneToOneV.Properties.VariableNames = pairsCccChar;


    FUPinchZeroToTwoV = dataCCCAlphaV{y}(lastRowV-fuTrialsAvailableV+1:lastRowV,154:181);
    FUPinchZeroToTwoV.Properties.VariableNames = pairsCccChar;


    % FUPinchOnetoThreeV = dataCCCAlphaV{y}(124:183,183:210);
    % FUPinchOnetoThreeV.Properties.VariableNames = pairsCccChar;
    % FUPinchTwoToFourV = dataCCCAlphaV{y}(124:183,212:239);
    % FUPinchTwoToFourV.Properties.VariableNames = pairsCccChar;
    % FUPinchThreeToFiveV = dataCCCAlphaV{y}(124:183,241:268);
    % FUPinchThreeToFiveV.Properties.VariableNames = pairsCccChar;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Beta CCC %%

    % beta Pre NoVib CCC
    % betaPinchNegFiveToThreeNV = dataCCCBetaNV{y}(4:63,9:36);
    % betaPinchNegFiveToThreeNV.Properties.VariableNames = pairsCccChar;
    % betaPrePinchNegFourToTwoNV = dataCCCBetaNV{y}(4:63,38:65);
    % betaPrePinchNegFourToTwoNV.Properties.VariableNames = pairsCccChar;
    % betaPrePinchNegThreeToOneNV = dataCCCBetaNV{y}(4:63,67:94);
    % betaPrePinchNegThreeToOneNV.Properties.VariableNames = pairsCccChar;

    betaPrePinchNegTwoToZeroNV = dataCCCBetaNV{y}(4:3+preTrialsAvailableNV,96:123); %x
    betaPrePinchNegTwoToZeroNV.Properties.VariableNames = pairsCccChar;

    % betaPinchNegOneToOneNV = dataCCCBetaNV{y}(4:63,125:152);
    % betaPrePinchNegOneToOneNV.Properties.VariableNames = pairsCccChar;

    betaPrePinchZeroToTwoNV = dataCCCBetaNV{y}(4:3+preTrialsAvailableNV,154:181); %x
    betaPrePinchZeroToTwoNV.Properties.VariableNames = pairsCccChar;

    % betaPrePinchOnetoThreeNV = dataCCCBetaNV{y}(4:63,183:210);
    % betaPrePinchOnetoThreeNV.Properties.VariableNames = pairsCccChar;
    % betaPrePinchTwoToFourNV = dataCCCBetaNV{y}(4:63,212:239);
    % betaPrePinchTwoToFourNV.Properties.VariableNames = pairsCccChar;
    % betaPrePinchThreeToFiveNV = dataCCCBetaNV{y}(4:63,241:268);
    % betaPrePinchThreeToFiveNV.Properties.VariableNames = pairsCccChar;

    %% beta Pre Vib CCC
    % betaPrePinchNegFiveToThreeV = dataCCCBetaV{y}(4:63,9:36);
    % betaPrePinchNegFiveToThreeV.Properties.VariableNames = pairsCccChar;
    % betaPrePinchNegFourToTwoV = dataCCCBetaV{y}(4:63,38:65);
    % betaPrePinchNegFourToTwoV.Properties.VariableNames = pairsCccChar;
    % betaPrePinchNegThreeToOneV = dataCCCBetaV{y}(4:63,67:94);
    % betaPrePinchNegThreeToOneV.Properties.VariableNames = pairsCccChar;

    betaPrePinchNegTwoToZeroV = dataCCCBetaV{y}(4:3+preTrialsAvailableV,96:123);
    betaPrePinchNegTwoToZeroV.Properties.VariableNames = pairsCccChar;

    % betaPrePinchNegOneToOneV = dataCCCBetaV{y}(4:63,125:152);
    % betaPrePinchNegOneToOneV.Properties.VariableNames = pairsCccChar;
    betaPrePinchZeroToTwoV = dataCCCBetaV{y}(4:3+preTrialsAvailableV,154:181);
    betaPrePinchZeroToTwoV.Properties.VariableNames = pairsCccChar;

    % betaPrePinchOnetoThreeV = dataCCCBetaV{y}(4:63,183:210);
    % betaPrePinchOnetoThreeV.Properties.VariableNames = pairsCccChar;
    % betaPrePinchTwoToFourV = dataCCCBetaV{y}(4:63,212:239);
    % betaPrePinchTwoToFourV.Properties.VariableNames = pairsCccChar;
    % betaPrePinchThreeToFiveV = dataCCCBetaV{y}(4:63,241:268);
    % betaPrePinchThreeToFiveV.Properties.VariableNames = pairsCccChar;

    %%% check if there is post section. if yes, continue. otherwise, end %%

    % if height(dataCCCAlphaNV(y)) && height(dataCCCAlphaV(y)) < 60
    %     break;
    % else
    %     continue;
    % end

    %% beta Post NoVib CCC
    % betaPostPinchNegFiveToThreeNV = dataCCCBetaNV{y}(64:123,9:36);
    % betaPostPinchNegFiveToThreeNV.Properties.VariableNames = pairsCccChar;
    % betaPostPinchNegFourToTwoNV = dataCCCBetaNV{y}(64:123,38:65);
    % betaPostPinchNegFourToTwoNV.Properties.VariableNames = pairsCccChar;
    % betaPostPinchNegThreeToOneNV = dataCCCBetaNV{y}(64:123,67:94);
    % betaPostPinchNegThreeToOneNV.Properties.VariableNames = pairsCccChar;

    betaPostPinchNegTwoToZeroNV = dataCCCBetaNV{y}(postIdxNV:postIdxNV + postTrialsAvailableNV-1,96:123);
    betaPostPinchNegTwoToZeroNV.Properties.VariableNames = pairsCccChar;

    % betaPostPinchNegOneToOneNV = dataCCCBetaNV{y}(64:123,125:152);
    % betaPostPinchNegOneToOneNV.Properties.VariableNames = pairsCccChar;

    betaPostPinchZeroToTwoNV = dataCCCBetaNV{y}(postIdxNV:postIdxNV + postTrialsAvailableNV-1,154:181);
    betaPostPinchZeroToTwoNV.Properties.VariableNames = pairsCccChar;

    % betaPostPinchOnetoThreeNV = dataCCCBetaNV{y}(64:123,183:210);
    % betaPostPinchOnetoThreeNV.Properties.VariableNames = pairsCccChar;
    % betaPostPinchTwoToFourNV = dataCCCBetaNV{y}(64:123,212:239);
    % betaPostPinchTwoToFourNV.Properties.VariableNames = pairsCccChar;
    % betaPostPinchThreeToFiveNV = dataCCCBetaNV{y}(64:123,241:268);
    % betaPostPinchThreeToFiveNV.Properties.VariableNames = pairsCccChar;

    %% beta Post Vib CCC
    % betaPostPinchNegFiveToThreeV = dataCCCBetaV{y}(64:123,9:36);
    % betaPostPinchNegFiveToThreeV.Properties.VariableNames = pairsCccChar;
    % betaPostPinchNegFourToTwoV = dataCCCBetaV{y}(64:123,38:65);
    % betaPostPinchNegFourToTwoV.Properties.VariableNames = pairsCccChar;
    % betaPostPinchNegThreeToOneV = dataCCCBetaV{y}(64:123,67:94);
    % betaPostPinchNegThreeToOneV.Properties.VariableNames = pairsCccChar;

    betaPostPinchNegTwoToZeroV = dataCCCBetaV{y}(postIdxV:postIdxV + postTrialsAvailableV-1,96:123);
    betaPostPinchNegTwoToZeroV.Properties.VariableNames = pairsCccChar;

    % betaPostPinchNegOneToOneV = dataCCCBetaV{y}(64:123,125:152);
    % betaPostPinchNegOneToOneV.Properties.VariableNames = pairsCccChar;

    betaPostPinchZeroToTwoV = dataCCCBetaV{y}(postIdxV:postIdxV + postTrialsAvailableV-1,154:181);
    betaPostPinchZeroToTwoV.Properties.VariableNames = pairsCccChar;

    % betaPostPinchOnetoThreeV = dataCCCBetaV{y}(64:123,183:210);
    % betaPostPinchOnetoThreeV.Properties.VariableNames = pairsCccChar;
    % betaPostPinchTwoToFourV = dataCCCBetaV{y}(64:123,212:239);
    % betaPostPinchTwoToFourV.Properties.VariableNames = pairsCccChar;
    % betaPostPinchThreeToFiveV = dataCCCBetaV{y}(64:123,241:268);
    % betaPostPinchThreeToFiveV.Properties.VariableNames = pairsCccChar;

    %%%% check if there is FU section. If yes, continue. otherwsie end %%%
    % if height(dataCCCAlphaNV(y)) && height(dataCCCAlphaV(y)) > 120
    %     continue
    % else
    %     break;
    % end

    %% beta FU NoVib CCC
    % betaFUPinchNegFiveToThreeNV = dataCCCBetaNV{y}(124:183,9:36);
    % betaFUPinchNegFiveToThreeNV.Properties.VariableNames = pairsCccChar;
    % betaFUPinchNegFourToTwoNV = dataCCCBetaNV{y}(124:183,38:65);
    % betaFUPinchNegFourToTwoNV.Properties.VariableNames = pairsCccChar;
    % betaFUPinchNegThreeToOneNV = dataCCCBetaNV{y}(124:183,67:94);
    % betaFUPinchNegThreeToOneNV.Properties.VariableNames = pairsCccChar;

    betaFUPinchNegTwoToZeroNV = dataCCCBetaNV{y}(lastRowNV-fuTrialsAvailableNV+1:lastRowNV,96:123);
    betaFUPinchNegTwoToZeroNV.Properties.VariableNames = pairsCccChar;

    % betaFUPinchNegOneToOneNV = dataCCCBetaNV{y}(124:183,125:152);
    % betaFUPinchNegOneToOneNV.Properties.VariableNames = pairsCccChar;

    betaFUPinchZeroToTwoNV = dataCCCBetaNV{y}(lastRowNV-fuTrialsAvailableNV+1:lastRowNV,154:181);
    betaFUPinchZeroToTwoNV.Properties.VariableNames = pairsCccChar;

    % betaFUPinchOnetoThreeNV = dataCCCBetaNV{y}(124:183,183:210);
    % betaFUPinchOnetoThreeNV.Properties.VariableNames = pairsCccChar;
    % betaFUPinchTwoToFourNV = dataCCCBetaNV{y}(124:183,212:239);
    % betaFUPinchTwoToFourNV.Properties.VariableNames = pairsCccChar;
    % betaFUPinchThreeToFiveNV = dataCCCBetaNV{y}(124:183,241:268);
    % betaFUPinchThreeToFiveNV.Properties.VariableNames = pairsCccChar;

    %% beta FU Vib CCC
    % betaFUPinchNegFiveToThreeV = dataCCCBetaV{y}(124:183,9:36);
    % betaFUPinchNegFiveToThreeV.Properties.VariableNames = pairsCccChar;
    % betaFUPinchNegFourToTwoV = dataCCCBetaV{y}(124:183,38:65);
    % betaFUPinchNegFourToTwoV.Properties.VariableNames = pairsCccChar;
    % betaFUPinchNegThreeToOneV = dataCCCBetaV{y}(124:183,67:94);
    % betaFUPinchNegThreeToOneV.Properties.VariableNames = pairsCccChar;

    betaFUPinchNegTwoToZeroV = dataCCCBetaV{y}(lastRowV-fuTrialsAvailableV+1:lastRowV,96:123);
    betaFUPinchNegTwoToZeroV.Properties.VariableNames = pairsCccChar;

    % betaFUPinchNegOneToOneV = dataCCCBetaV{y}(124:183,125:152);
    % betaFUPinchNegOneToOneV.Properties.VariableNames = pairsCccChar;

    betaFUPinchZeroToTwoV = dataCCCBetaV{y}(lastRowV-fuTrialsAvailableV+1:lastRowV,154:181);
    betaFUPinchZeroToTwoV.Properties.VariableNames = pairsCccChar;

    % betaFUPinchOnetoThreeV = dataCCCBetaV{y}(124:183,183:210);
    % betaFUPinchOnetoThreeV.Properties.VariableNames = pairsCccChar;
    % betaFUPinchTwoToFourV = dataCCCBetaV{y}(124:183,212:239);
    % betaFUPinchTwoToFourV.Properties.VariableNames = pairsCccChar;
    % betaFUPinchThreeToFiveV = dataCCCBetaV{y}(124:183,241:268);
    % betaFUPinchThreeToFiveV.Properties.VariableNames = pairsCccChar;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%  Merge two sets of tables (thus combining NoVib and Vib).
    %   Still have option for stratifying by condition (i.e., Vib/NoVib) by using the below tables
    %       and including the last 60 trials, since AB vertically concatenat
    %       the Vib trials onto the end of the NoVib trials.

    % for those with all data collected (Pre, Post, FU), the below tables should
    %   have 120row x 28col structure indicating the Coh for each trial of each run
    %   for NoVib, 1:60, then Vib 61:120.

    % % alpha prep CCC
    % alphaPrePinchPrep = vertcat(PrePinchNegTwoToZeroNV,PrePinchNegTwoToZeroV);
    % alphaPostPinchPrep = vertcat(PostPinchNegTwoToZeroNV,PostPinchNegTwoToZeroV);
    % alphaFUPinchPrep = vertcat(FUPinchNegTwoToZeroNV,FUPinchNegTwoToZeroV);
    %
    % % alpha exe CCC
    % alphaPrePinchExe = vertcat(PrePinchNegTwoToZeroNV,PrePinchNegTwoToZeroV);
    % alphaPostPinchExe = vertcat(PostPinchZeroToTwoNV,PostPinchZeroToTwoV);
    % alphaFUPinchExe = vertcat(FUPinchZeroToTwoNV,FUPinchZeroToTwoV);
    %
    % % beta prep CCC
    % betaPrePinchPrep = vertcat(betaPrePinchNegTwoToZeroNV,betaPrePinchNegTwoToZeroV);
    % betaPostPinchPrep = vertcat(betaPostPinchNegTwoToZeroNV,betaPostPinchNegTwoToZeroV);
    % betaFUPinchPrep = vertcat(betaFUPinchNegTwoToZeroNV,betaFUPinchNegTwoToZeroV);
    %
    % % beta exe CCC
    % betaPrePinchExe = vertcat(betaPrePinchNegTwoToZeroNV,betaPrePinchNegTwoToZeroV);
    % betaPostPinchExe = vertcat(betaPostPinchZeroToTwoNV,betaPostPinchZeroToTwoV);
    % betaFUPinchExe = vertcat(betaFUPinchZeroToTwoNV,betaFUPinchZeroToTwoV);

    %% combine all trials together, then add exclusions

    % combined NV trials
    alphaPrepAllNV = vertcat(PrePinchNegTwoToZeroNV,PostPinchNegTwoToZeroNV,FUPinchNegTwoToZeroNV);
    alphaExeAllNV = vertcat(PrePinchZeroToTwoNV,PostPinchZeroToTwoNV,FUPinchZeroToTwoNV);
    betaPrepAllNV = vertcat(betaPrePinchNegTwoToZeroNV,betaPostPinchNegTwoToZeroNV,betaFUPinchNegTwoToZeroNV);
    betaExeAllNV = vertcat(betaPrePinchZeroToTwoNV,betaPostPinchZeroToTwoNV,betaFUPinchZeroToTwoNV);

    % % vert cat to compile everything togerthetr.
    % alphaPrepAllV = vertcat(alphaPrePinchPrep,alphaPostPinchPrep,alphaFUPinchPrep);
    % alphaExeAllV = vertcat(alphaPrePinchExe,alphaPostPinchExe,alphaFUPinchExe);
    % betaPrepAllV = vertcat(betaPrePinchPrep,betaPostPinchPrep,betaFUPinchPrep);
    % betaExeAllV = vertcat(betaPrePinchExe,betaPostPinchExe,betaFUPinchExe);

    % add pinch exclusion2 from noVib and Vib exclusion lists
    % noVib exclusions (1:180)
    % exclusion2NV = vertcat(exclusion2NV{1,1}(4:end,'pinch')); %% add the following for adding Vib exclusions ,(exclusion2V{1,1}(4:end,'pinch')));

    % add the exclusionsAll var to the all alpha, beta data tables
    alphaPrepAllNVExc = horzcat(alphaPrepAllNV,exclusion2NV);
    alphaExeAllNVExc = horzcat(alphaExeAllNV,exclusion2NV);
    betaPrepAllNVExc = horzcat(betaPrepAllNV,exclusion2NV);
    betaExeAllNVExc = horzcat(betaExeAllNV,exclusion2NV);

    %% Clear vars not needed anymore (right now - 2024-09-04, edit the vars to clear them as needed)

    clear FUPinchNegFiveToThreeNV FUPinchNegFiveToThreeV FUPinchNegFourToTwoNV FUPinchNegFourToTwoV FUPinchNegOneToOneNV FUPinchNegOneToOneV FUPinchNegThreeToOneNV...
        FUPinchNegThreeToOneV FUPinchNegTwoToZeroNV FUPinchNegTwoToZeroV FUPinchOnetoThreeNV FUPinchOnetoThreeV FUPinchThreeToFiveNV FUPinchThreeToFiveV FUPinchTwoToFourNV FUPinchTwoToFourV...
        FUPinchZeroToTwoNV FUPinchZeroToTwoV PostPinchNegFiveToThreeNV PostPinchNegFiveToThreeV PostPinchNegFourToTwoNV PostPinchNegFourToTwoV PostPinchNegOneToOneNV...
        PostPinchNegOneToOneV PostPinchNegThreeToOneNV PostPinchNegThreeToOneV PostPinchNegTwoToZeroNV PostPinchNegTwoToZeroV PostPinchOnetoThreeNV PostPinchOnetoThreeV ...
        PostPinchThreeToFiveNV PostPinchThreeToFiveV PostPinchTwoToFourNV PostPinchTwoToFourV PostPinchZeroToTwoNV PostPinchZeroToTwoV PrePinchNegFiveToThreeNV PrePinchNegFiveToThreeV...
        PrePinchNegFourToTwoNV PrePinchNegFourToTwoV PrePinchNegOneToOneNV PrePinchNegOneToOneV PrePinchNegThreeToOneNV PrePinchNegThreeToOneV PrePinchNegTwoToZeroNV PrePinchNegTwoToZeroV...
        PrePinchOnetoThreeNV PrePinchOnetoThreeV PrePinchThreeToFiveNV PrePinchThreeToFiveV PrePinchTwoToFourNV PrePinchTwoToFourV PrePinchZeroToTwoNV PrePinchZeroToTwoV
    clear betaFUPinchNegFiveToThreeNV betaFUPinchNegFiveToThreeV betaFUPinchNegFourToTwoNV betaFUPinchNegFourToTwoV betaFUPinchNegOneToOneNV betaFUPinchNegOneToOneV...
        betaFUPinchNegThreeToOneNV betaFUPinchNegThreeToOneV betaFUPinchNegTwoToZeroNV betaFUPinchNegTwoToZeroV betaFUPinchOnetoThreeNV betaFUPinchOnetoThreeV ...
        betaFUPinchThreeToFiveNV betaFUPinchThreeToFiveV betaFUPinchTwoToFourNV betaFUPinchTwoToFourV betaFUPinchZeroToTwoNV betaFUPinchZeroToTwoV betaPinchNegFiveToThreeNV...
        betaPinchNegOneToOneNV betaPostPinchNegFiveToThreeNV betaPostPinchNegFiveToThreeV betaPostPinchNegFourToTwoNV betaPostPinchNegFourToTwoV betaPostPinchNegOneToOneNV...
        betaPostPinchNegOneToOneV betaPostPinchNegThreeToOneNV betaPostPinchNegThreeToOneV betaPostPinchNegTwoToZeroNV betaPostPinchNegTwoToZeroV betaPostPinchOnetoThreeNV...
        betaPostPinchOnetoThreeV betaPostPinchThreeToFiveNV betaPostPinchThreeToFiveV betaPostPinchTwoToFourNV betaPostPinchTwoToFourV betaPostPinchZeroToTwoNV betaPostPinchZeroToTwoV...
        betaPrePinchNegFiveToThreeV betaPrePinchNegFourToTwoNV betaPrePinchNegFourToTwoV betaPrePinchNegOneToOneNV betaPrePinchNegOneToOneV betaPrePinchNegThreeToOneNV...
        betaPrePinchNegThreeToOneV betaPrePinchNegTwoToZeroNV betaPrePinchNegTwoToZeroV betaPrePinchOnetoThreeNV betaPrePinchOnetoThreeV betaPrePinchThreeToFiveNV...
        betaPrePinchThreeToFiveV betaPrePinchTwoToFourNV betaPrePinchTwoToFourV betaPrePinchZeroToTwoNV betaPrePinchZeroToTwoV

    %% average the NoVib data for Pre Post and FU
    tableDir = {alphaPrepAllNVExc, alphaExeAllNVExc,betaPrepAllNVExc, betaExeAllNVExc};

    % initialize tables
    connAlphaPrePrepNV = [];
    connAlphaPreExeNV = [];
    connBetaPrePrepNV = [];
    connBetaPreExeNV = [];
    connAlphaPostPrepNV = [];
    connAlphaPostExeNV = [];
    connBetaPostPrepNV = [];
    connBetaPostExeNV = [];
    connAlphaFUPrepNV = [];
    connAlphaFUExeNV = [];
    connBetaFUPrepNV = [];
    connBetaFUExeNV = [];

    for iTable=1:length(tableDir)

        %% alpha Pre Prep CCC
        if iTable == 1
            currentTable = tableDir{1};

            tempMeanPre = [];
            tempMeanPost = [];
            tempMeanFU = [];
            tempValsPre = [];
            tempValsPost = [];
            tempValsFU = [];

            % assign pre trials, account for exclusions
            for rowPre = 1:preTrialsAvailableNV 
                if currentTable{rowPre, "pinchIncludeTrial"} == 1
                    tempValsPre = vertcat(tempValsPre, currentTable{rowPre, 1:28});
                end
            end
            % do the same for Post, accounting for exclusions
            for rowPost = preTrialsAvailableNV+1:preTrialsAvailableNV + postTrialsAvailableNV
                if currentTable{rowPost,"pinchIncludeTrial"} == 1
                    tempValsPost = vertcat(tempValsPost,currentTable{rowPost,1:28});
                end
            end

            % now for FU, accounting for exclusions
            for rowFU = preTrialsAvailableNV + postTrialsAvailableNV + 1:preTrialsAvailableNV + postTrialsAvailableNV + fuTrialsAvailableNV
                if currentTable{rowFU,'pinchIncludeTrial'} == 1
                    tempValsFU = vertcat(tempValsFU,currentTable{rowFU,1:28});
                end
            end

            tempMeanPre = mean(tempValsPre,1);    % compute mean across x trials within each brain region pair for pre (results with 1 row (avg over trials) x 28 columns (pairs)
            tempMeanPost = mean(tempValsPost,1);  % do the same for post
            tempMeanFU = mean(tempValsFU,1);      % same fu

            % compile the temp values together
            connAlphaPrePrepNV = tempMeanPre; % rename
            connAlphaPostPrepNV = tempMeanPost;
            connAlphaFUPrepNV = tempMeanFU;

            %%% add the Vib trials here once ready

            %% alpha exe, NV CCC
        elseif iTable == 2
            currentTable = tableDir{2};

            tempMeanPre = [];
            tempMeanPost = [];
            tempMeanFU = [];
            tempValsPre = [];
            tempValsPost = [];
            tempValsFU = [];

            for rowPre = 1:preTrialsAvailableNV
                if currentTable{rowPre, "pinchIncludeTrial"} == 1
                    tempValsPre = vertcat(tempValsPre, currentTable{rowPre,1:28});
                end
            end

            for rowPost = preTrialsAvailableNV+1:preTrialsAvailableNV + postTrialsAvailableNV
                if currentTable{rowPost,"pinchIncludeTrial"} == 1
                    tempValsPost = vertcat(tempValsPost,currentTable{rowPost,1:28});
                end
            end

            for rowFU = preTrialsAvailableNV + postTrialsAvailableNV + 1:preTrialsAvailableNV + postTrialsAvailableNV + fuTrialsAvailableNV
                if currentTable{rowFU, "pinchIncludeTrial"} == 1
                    tempValsFU = vertcat(tempValsFU,currentTable{rowFU,1:28});
                end
            end

            tempMeanPre = mean(tempValsPre,1);
            tempMeanPost = mean(tempValsPost,1);
            tempMeanFU = mean(tempValsFU,1);

            % rename
            connAlphaPreExeNV = tempMeanPre;
            connAlphaPostExeNV = tempMeanPost;
            connAlphaFUExeNV = tempMeanFU;

            % vib can go here once it is investigated

            %% beta prep, NV CCC
        elseif iTable == 3
            currentTable = tableDir{3};

            tempMeanPre = [];
            tempMeanPost = [];
            tempMeanFU = [];
            tempValsPre = [];
            tempValsPost = [];
            tempValsFU = [];

            for rowPre = 1:preTrialsAvailableNV
                if currentTable{rowPre, "pinchIncludeTrial"} == 1
                    tempValsPre = vertcat(tempValsPre, currentTable{rowPre,1:28});
                end
            end

            for rowPost = preTrialsAvailableNV+1:preTrialsAvailableNV + postTrialsAvailableNV
                if currentTable{rowPost,"pinchIncludeTrial"} == 1
                    tempValsPost = vertcat(tempValsPost,currentTable{rowPost,1:28});
                end
            end

            for rowFU = preTrialsAvailableNV + postTrialsAvailableNV + 1:preTrialsAvailableNV + postTrialsAvailableNV + fuTrialsAvailableNV
                if currentTable{rowFU, "pinchIncludeTrial"} == 1
                    tempValsFU = vertcat(tempValsFU,currentTable{rowFU,1:28});
                end
            end

            tempMeanPre = mean(tempValsPre,1);
            tempMeanPost = mean(tempValsPost,1);
            tempMeanFU = mean(tempValsFU,1);

            % rename
            connBetaPrePrepNV = tempMeanPre;
            connBetaPostPrepNV = tempMeanPost;
            connBetaFUPrepNV = tempMeanFU;


            %%% add vib stuff here too

            %% beta exe NV CCC
        elseif iTable == 4
            currentTable = tableDir{4};

            tempMeanPre = [];
            tempMeanPost = [];
            tempMeanFU = [];
            tempValsPre = [];
            tempValsPost = [];
            tempValsFU = [];

            for rowPre = 1:preTrialsAvailableNV
                if currentTable{rowPre, "pinchIncludeTrial"} == 1
                    tempValsPre = vertcat(tempValsPre, currentTable{rowPre,1:28});
                end
            end

            for rowPost = preTrialsAvailableNV+1:preTrialsAvailableNV + postTrialsAvailableNV
                if currentTable{rowPost, "pinchIncludeTrial"} == 1
                    tempValsPost = vertcat(tempValsPost,currentTable{rowPost,1:28});
                end
            end

            for rowFU = preTrialsAvailableNV + postTrialsAvailableNV + 1:preTrialsAvailableNV + postTrialsAvailableNV + fuTrialsAvailableNV
                if currentTable{rowFU, "pinchIncludeTrial"} == 1
                    tempValsFU = vertcat(tempValsFU,currentTable{rowFU,1:28});
                end
            end

            tempMeanPre = mean(tempValsPre,1);
            tempMeanPost = mean(tempValsPost,1);
            tempMeanFU = mean(tempValsFU,1);

            % rename
            connBetaPreExeNV = tempMeanPre;
            connBetaPostExeNV = tempMeanPost;
            connBetaFUExeNV = tempMeanFU;
        end
    end

    %%% add vib code here once ready

    clear dataCCCAlphaNV dataCCCAlphaV dataCCCBetaNV dataCCCBetaV tempMeanFU tempMeanPost...
        tempMeanPre tempValsFU tempValsPost tempValsPre wolfTime exclusion2NV currentTable rowPre rowPost rowFU

    %% Compile mean Conn of tables above within loop

    % concatenate the avg Pre, Post, FU points together to make a 3x28
    % matrix, avg coh measure acrosss pre trials within brain regions

    % alpha Pre
    connAlphaPrepNV = vertcat(connAlphaPrePrepNV,connAlphaPostPrepNV,connAlphaFUPrepNV);
    % alpha Exe
    connAlphaExeNV = vertcat(connAlphaPreExeNV,connAlphaPostExeNV,connAlphaFUExeNV);
    % beta Prep
    connBetaPrepNV = vertcat(connBetaPrePrepNV,connBetaPostPrepNV,connBetaFUPrepNV);
    % beta Exe
    connBetaExeNV = vertcat(connBetaPreExeNV,connBetaPostExeNV,connBetaFUExeNV);
    
    %% append avg of Pre, Post, FU coh values together across participants into 
    % 4 tables: masterAlphaPrep, masterAlphaExe, etc..
    subjectColumn = repmat(currentPt, 84, 1);
    timeColumn = repmat(["Pre"; "Post"; "FU"], 28, 1);
    pairColumn = repmat(pairsCccChar, 3, 1);

    % append coh values together in one column x number of pairs
    cohAlphaPrep = [connAlphaPrepNV(1, :)'; connAlphaPrepNV(2, :)'; connAlphaPrepNV(3, :)'];
    cohAlphaExe = [connAlphaExeNV(1, :)'; connAlphaExeNV(2, :)'; connAlphaExeNV(3, :)'];
    cohBetaPrep = [connBetaPrepNV(1, :)'; connBetaPrepNV(2, :)'; connBetaPrepNV(3, :)'];
    cohBetaExe = [connBetaExeNV(1, :)'; connBetaExeNV(2, :)'; connBetaExeNV(3, :)'];
    
    % make temp table to append to other subjects later
    tempMasterAlphaPrep = table(subjectColumn, timeColumn, pairColumn, cohAlphaPrep, ...
    'VariableNames', {'subjectID', 'timePoint', 'regionPair', 'cohAlphaPrep'});

    tempMasterAlphaExe = table(subjectColumn, timeColumn, pairColumn, cohAlphaExe, ...
    'VariableNames', {'subjectID', 'timePoint', 'regionPair', 'cohAlphaExe'});

    tempMasterBetaPrep = table(subjectColumn, timeColumn, pairColumn, cohBetaPrep, ...
    'VariableNames', {'subjectID', 'timePoint', 'regionPair', 'cohBetaPrep'});

    tempMasterBetaExe = table(subjectColumn, timeColumn, pairColumn, cohBetaExe, ...
    'VariableNames', {'subjectID', 'timePoint', 'regionPair', 'cohBetaExe'});

    
    if isempty(masterAlphaPrep)
        masterAlphaPrep = tempMasterAlphaPrep;
    else
        masterAlphaPrep = vertcat(masterAlphaPrep, tempMasterAlphaPrep);
    end
    if isempty(masterAlphaExe)
        masterAlphaExe = tempMasterAlphaExe;
    else
        masterAlphaExe = vertcat(masterAlphaExe, tempMasterAlphaExe);
    end
    if isempty(masterBetaPrep)
        masterBetaPrep = tempMasterBetaPrep;
    else
        masterBetaPrep = vertcat(masterBetaPrep, tempMasterBetaPrep);
    end
    if isempty(masterBetaExe)
        masterBetaExe = tempMasterBetaExe;
    else
        masterBetaExe = vertcat(masterBetaExe, tempMasterBetaExe);
    end

    clear betaPrepAllNVExc alphaExeAllNV betaExeAllNV betaPrepAllNV tempMasterAlphaPrep tempMasterAlphaExe ...
        tempMasterBetaPrep tempMasterBetaExe

    %% start plotting - indiviaul results
    timePoints = [1,2,3];
    t = tiledlayout(2,2); % tiled layout for each subject
    % set dimensions of fig window so legend is in good spot
    set(gcf, 'Position', [100, 100, 1058, 746]);
    cd("figures/");

    %% make temp wolf data
    wolfData.subjID = string(wolfData.subjID);
    wolfData.timePoint = string(wolfData.timePoint);

    for albus=1:height(wolfData)
        idx = contains(wolfData.timePoint,timeLabels2);
        tempWolf = wolfData(idx,:);
    end

    %% alpha Prep NV %%
    plotHandlesLeft = [];
    nexttile
    hold on
    for harry=1:(width(connAlphaPrepNV))
        if connAlphaPrepNV(2,harry) < connAlphaPrepNV(1,harry) % if Post < Pre in a given pair (Pre-Post change is primary analysis)
            c = plot(timePoints, connAlphaPrepNV(:,harry),'--o');
        else
            c = plot(timePoints, connAlphaPrepNV(:,harry),'-x');
        end
        plotHandlesLeft = [plotHandlesLeft,c];
    end

    % plot details, left y axis
    ylabel('LaggedCoh');
    % x axis details
    xticks(timePoints);
    xticklabels(timeLabels);

    yyaxis right
    for dumbledore=1:height(tempWolf)
        if tempWolf.subjID{dumbledore} == currentPt
            dataIdx = strcmp(tempWolf.subjID,currentPt);
            tempWolfData = double(tempWolf{dataIdx,3});
        end
    end
    plot(timePoints,tempWolfData,'-s','LineWidth',2,'Color',[0 0 0.75]); % plot the time points, make thicker black line.
    ylabel('WMFT time (s)');
    ax = gca;
    ax.YColor = [0 0 0.75]; % change color of WMFT axis to match WMFT line (darker blue)
    ylim([0,120]);
    title('Alpha Prep');
    %% alpha Exe NV %%%
    plotHandlesLeft = [];
    nexttile
    hold on
    % note to self:
    % make this a function when you have more time
    for harry=1:(width(connAlphaExeNV))
        if connAlphaExeNV(2,harry) < connAlphaExeNV(1,harry)
            c = plot(timePoints, connAlphaExeNV(:,harry),'--o');
        else
            c = plot(timePoints, connAlphaExeNV(:,harry),'-x');
        end
        plotHandlesLeft = [plotHandlesLeft,c];
    end
    % ylabel('LaggedCoh');
    xticks(timePoints);
    xticklabels(timeLabels);

    yyaxis right
    for dumbledore=1:height(tempWolf)
        if tempWolf.subjID{dumbledore} == currentPt
            dataIdx = strcmp(tempWolf.subjID,currentPt);
            tempWolfData = double(tempWolf{dataIdx,3});
        end
    end
    q = plot(timePoints,tempWolfData,'-s','LineWidth',2,'Color',[0 0 0.75]);

    ylabel('WMFT time (s)');
    ax = gca;
    ax.YColor = [0 0 0.75]; % change color of WMFT axis to match WMFT line (darker blue)
    ylim([0,120]);

    title('Alpha Exe');
    %% Beta Prep NV %%%
    plotHandlesLeft = [];
    c = [];
    nexttile
    hold on
    % note to self:
    % make this a function when you got more time
    for harry=1:(width(connBetaPrepNV))
        if connBetaPrepNV(2,harry) < connBetaPrepNV(1,harry)
            c = plot(timePoints, connBetaPrepNV(:,harry),'--o');
        else
            c = plot(timePoints, connBetaPrepNV(:,harry),'-x');
        end
        plotHandlesLeft = [plotHandlesLeft,c];
    end
    ylabel('LaggedCoh');
    xticks(timePoints);
    xticklabels(timeLabels);

    yyaxis right
    for dumbledore=1:height(tempWolf)
        if tempWolf.subjID{dumbledore} == currentPt
            dataIdx = strcmp(tempWolf.subjID,currentPt);
            tempWolfData = double(tempWolf{dataIdx,3});
        end
    end
    q = plot(timePoints,tempWolfData,'-s','LineWidth',2,'Color',[0 0 0.75]);
    ylabel('WMFT time (s)');
    ax = gca;
    ax.YColor = [0 0 0.75]; % change color of WMFT axis to match WMFT line (darker blue)
    ylim([0,120]);

    title('Beta Prep');
    %% beta Exe NV %%%
    plotHandlesLeft = [];
    c = [];
    q = [];
    nexttile
    hold on
    % note to self:
    % make this a function when you got more time
    for harry=1:(width(connBetaExeNV))
        if connBetaExeNV(2,harry) < connBetaExeNV(1,harry)
            c = plot(timePoints, connBetaExeNV(:,harry),'--o');
        else
            c = plot(timePoints, connBetaExeNV(:,harry),'-x');
        end
        plotHandlesLeft = [plotHandlesLeft,c];
    end
    % ylabel('LaggedCoh');
    xticks(timePoints);
    xticklabels(timeLabels);

    yyaxis right
    for dumbledore=1:height(tempWolf)
        if tempWolf.subjID{dumbledore} == currentPt
            dataIdx = strcmp(tempWolf.subjID,currentPt);
            tempWolfData = double(tempWolf{dataIdx,3});
        end
    end
    q = plot(timePoints,tempWolfData,'-s','LineWidth',2,'Color',[0 0 0.75]);
    ylabel('WMFT time (s)');
    ax = gca;
    ax.YColor = [0,0,0.75]; % change color of WMFT axis to match WMFT line (darker blue)
    ylim([0,120]);

    % subplot title
    title('Beta Exe');
    %%  plot detail stuff
    % title for the entire plot
    title(t,currentPt);
    % legend
    allPlotHandles = [plotHandlesLeft,q];
    legendNames = [pairsCccChar;{'WMFT'}];
    lgd = legend(allPlotHandles,legendNames,'Location','northoutside','orientation','horizontal'); % add the WMFT to legend.;
    lgd.NumColumns = 10;
    % Adjust position to center the legend horizontally
    lgd.Position = [0.5 - lgd.Position(3)/2, lgd.Position(2), lgd.Position(3), lgd.Position(4)];

    % add some white space to either side of Pre and FU. chatGPT helped
    % with the following loop:
    allAxes = findall(gcf,"Type","axes"); % find all axes from subplots
    for dobbie = 1:length(allAxes) % go trhough all axes from above
        ax = allAxes(dobbie); % make var for all axes as loop goes
        xLimits = xlim(ax); % denote lim of current axis
        % make var of pad amt by adding 10% extra white space to the difference between xLim2 and xLim1
        padding = 0.075* (xLimits(2) - xLimits(1));
        % set new axes based on aboline
        xlim(ax, [xLimits(1) - padding, xLimits(2) + padding]);
    end

    % save fig
    savefig(gcf,strcat(currentPt));
    saveas(gcf,strcat(currentPt,'.png'));
    cd ..;

    clear connAlphaFUExeNV connAlphaFUPrepNV connAlphaPostExeNV connAlphaPreExeNV connAlphaPostPrepNV connAlphaPrePrepNV...
        connBetaFUExeNV connBetaFUPrepNV connBetaPostExeNV connBetaPostPrepNV connBetaPreExeNV connBetaPrePrepNV dobbie...
        albus padding tableDir xLimits harry iTable legendNames allPlotHandles allAxes ax c lgd q t
    %% compile all the data plotted above across participants
    % convert array to tables
    connAlphaPrepNV = table(connAlphaPrepNV);
    connAlphaExeNV = table(connAlphaExeNV);
    connBetaPrepNV = table(connBetaPrepNV);
    connBetaExeNV = table(connBetaExeNV);

    % make currentPt table (for adding currentPt column to the data tables)
    currentPtTable = table(string(repmat({currentPt},3,1)));
    currentPtTable.Properties.VariableNames(1) = "subjectID";

    %% alpha Prep
    connAlphaPrepNV = splitvars(connAlphaPrepNV,'connAlphaPrepNV');
    connAlphaPrepNV = renamevars(connAlphaPrepNV,1:28,pairsCccChar);
    % horz cat subjID identifier
    tempAllAlphaPrepNV = [currentPtTable,connAlphaPrepNV];

    if currentPt == "TNT01"
        allAlphaPrepNV = addvars(allAlphaPrepNV,currentPtTable{:,1},'Before',1,'NewVariableNames','subjectID');
        allAlphaPrepNV = tempAllAlphaPrepNV;
    else
        allAlphaPrepNV = [allAlphaPrepNV;tempAllAlphaPrepNV];
    end

    %% alpha Exe
    connAlphaExeNV = splitvars(connAlphaExeNV,'connAlphaExeNV');
    connAlphaExeNV = renamevars(connAlphaExeNV,1:28,pairsCccChar);
    % horz cat subjID identifier
    tempAllAlphaExeNV = [currentPtTable,connAlphaExeNV];

    if currentPt == "TNT01"
        allAlphaExeNV = addvars(allAlphaExeNV,currentPtTable{:,1},'Before',1,'NewVariableNames','subjectID');
        allAlphaExeNV = tempAllAlphaExeNV;
    else
        allAlphaExeNV = [allAlphaExeNV;tempAllAlphaExeNV];
    end

    %% beta Prep
    connBetaPrepNV = splitvars(connBetaPrepNV,'connBetaPrepNV');
    connBetaPrepNV = renamevars(connBetaPrepNV,1:28,pairsCccChar);
    % horz cat subjID identifier
    tempAllBetaPrepNV = [currentPtTable,connBetaPrepNV];

    if currentPt == "TNT01"
        allBetaPrepNV = addvars(allBetaPrepNV,currentPtTable{:,1},'Before',1,'NewVariableNames','subjectID');
        allBetaPrepNV = tempAllBetaPrepNV;
    else
        allBetaPrepNV = [allBetaPrepNV;tempAllBetaPrepNV];
    end

    %% beta Exe
    connBetaExeNV = splitvars(connBetaExeNV,'connBetaExeNV');
    connBetaExeNV = renamevars(connBetaExeNV,1:28,pairsCccChar);
    % horz cat subjID identifier
    tempAllBetaExeNV = [currentPtTable,connBetaExeNV];

    if currentPt == "TNT01"
        allBetaExeNV = addvars(allBetaExeNV,currentPtTable{:,1},'Before',1,'NewVariableNames','subjectID');
        allBetaExeNV = tempAllBetaExeNV;
    else
        allBetaExeNV = [allBetaExeNV;tempAllBetaExeNV];
    end
end
%% back to the master subject tables

% sort rows by subject, region pair, timepoint
masterAlphaPrep = sortrows(masterAlphaPrep, {'subjectID', 'regionPair', 'timePoint'}, {'ascend', 'ascend', 'descend'});
masterAlphaExe = sortrows(masterAlphaExe, {'subjectID', 'regionPair','timePoint'}, {'ascend', 'ascend', 'descend'});
masterBetaPrep = sortrows(masterBetaPrep, {'subjectID', 'regionPair', 'timePoint'}, {'ascend', 'ascend', 'descend'});
masterBetaExe = sortrows(masterBetaExe, {'subjectID', 'regionPair', 'timePoint'}, {'ascend', 'ascend', 'descend'});

% clear some vars
clear idx dataIdx dumbledore tempAllAlphaPrepNV tempAllAlphaExeNV tempAllBetaPrepNV tempAllBetaExeNV currentPtTableconnBetaPrepNV connAlphaExeNV connAlphaPrepNV connBetaExeNV currentPtTable ...
    fuIdxNV fuIdxV tempAllAlphaExeNV tempAllBetaExeNV tempAllBetaPrepNV tempWolfData y cohAlphaPrep cohBetaExe cohBetaPrep connBetaPrepNV alphaExeAllNVExc  alphaPrepAllNV alphaPrepAllNVExc betaExeAllNVExc;
%% avg pairs across pts and time points now
% Define list of master tables and corresponding coherence variable names
masterDataList = {masterAlphaPrep, masterAlphaExe, masterBetaPrep, masterBetaExe};
cohVarNames = {'cohAlphaPrep', 'cohAlphaExe', 'cohBetaPrep', 'cohBetaExe'};

% Preallocate a cell array for storing the tables
avgCohTable = cell(1, length(masterDataList));

for dumbledore = 1:length(masterDataList)
    currentTable = masterDataList{dumbledore};

    % Compute mean coherence
    avgCohTable{dumbledore} = groupsummary(currentTable, {'regionPair', 'timePoint'}, 'mean', currentTable.Properties.VariableNames{4});

    % Rename the last column to the correct coherence variable name
    avgCohTable{dumbledore}.Properties.VariableNames{end} = cohVarNames{dumbledore};
end
% pull together all conditions/segmnets (ie alphaPrep, alphaExe, betaPrep,
% betaExe
outputCohAll = join(join(join(avgCohTable{1}, avgCohTable{2}, 'Keys', {'regionPair', 'timePoint'}), ...
    avgCohTable{3}, 'Keys', {'regionPair', 'timePoint'}), ...
    avgCohTable{4}, 'Keys', {'regionPair', 'timePoint'});
outputCohAll = removevars(outputCohAll, ["GroupCount_left","GroupCount_right","GroupCount_left_1","GroupCount_right_1"]);
outputCohAll = sortrows(outputCohAll, {'regionPair', 'timePoint'}, {'ascend', 'descend'});

%% compute pre post differences among pairs
% NOTE: used chatGPT heavily for this section.

% Unique combinations
uniqueGroups = unique(masterAlphaPrep(:, {'subjectID', 'regionPair'}));
nGroups = height(uniqueGroups);

% preallocate
PreCoh  = NaN(nGroups, 1);
PostCoh = NaN(nGroups, 1);
FUCoh   = NaN(nGroups, 1);

% Loop through each unique subject-region pair to build the separate lsits
% of coh values for subject
for i = 1:nGroups
    subj   = uniqueGroups.subjectID{i};
    region = uniqueGroups.regionPair{i};

    % For Pre
    idxPre = strcmp(masterAlphaPrep.subjectID, subj) & strcmp(masterAlphaPrep.timePoint, 'Pre') & strcmp(masterAlphaPrep.regionPair, region);
    if any(idxPre)
        PreCoh(i) = masterAlphaPrep.cohAlphaPrep(idxPre);
    end

    % For Post
    idxPost = strcmp(masterAlphaPrep.subjectID, subj) & strcmp(masterAlphaPrep.timePoint, 'Post') & strcmp(masterAlphaPrep.regionPair, region);
    if any(idxPost)
        PostCoh(i) = masterAlphaPrep.cohAlphaPrep(idxPost);
    end

    % For FU
    idxFU = strcmp(masterAlphaPrep.subjectID, subj) & strcmp(masterAlphaPrep.timePoint, 'FU') & strcmp(masterAlphaPrep.regionPair, region);
    if any(idxFU)
        FUCoh(i) = masterAlphaPrep.cohAlphaPrep(idxFU);
    end
end

% Now build the final table
resultTable1 = table(uniqueGroups.subjectID, uniqueGroups.regionPair, PreCoh, PostCoh, FUCoh, ...
    'VariableNames', {'subjectID', 'regionPair', 'PreCoh', 'PostCoh', 'FUCoh'});

% Compute difference scores and percent changes (using Pre as the base)
resultTable1.dPrePost = resultTable1.PostCoh - resultTable1.PreCoh;
resultTable1.dPreFU   = resultTable1.FUCoh - resultTable1.PreCoh;
resultTable1.dPrePostPct = (resultTable1.dPrePost ./ resultTable1.PreCoh) * 100;
resultTable1.dPreFUPct   = (resultTable1.dPreFU   ./ resultTable1.PreCoh) * 100;

%% same for alphaExe

% Get unique combinations of subjectID and regionPair
uniqueGroups = unique(masterAlphaExe(:, {'subjectID', 'regionPair'}));
nGroups = height(uniqueGroups);

% Preallocate arrays for the coherence values
PreCoh  = NaN(nGroups, 1);
PostCoh = NaN(nGroups, 1);
FUCoh   = NaN(nGroups, 1);

% Loop through each unique subject-region pair
for i = 1:nGroups
    subj   = uniqueGroups.subjectID{i};
    region = uniqueGroups.regionPair{i};

    % For Pre
    idxPre = strcmp(masterAlphaExe.subjectID, subj) & strcmp(masterAlphaExe.timePoint, 'Pre') & strcmp(masterAlphaExe.regionPair, region);
    if any(idxPre)
        PreCoh(i) = masterAlphaExe.cohAlphaExe(idxPre);
    end

    % For Post
    idxPost = strcmp(masterAlphaExe.subjectID, subj) & strcmp(masterAlphaExe.timePoint, 'Post') & strcmp(masterAlphaExe.regionPair, region);
    if any(idxPost)
        PostCoh(i) = masterAlphaExe.cohAlphaExe(idxPost);
    end

    % For FU
    idxFU = strcmp(masterAlphaExe.subjectID, subj) & strcmp(masterAlphaExe.timePoint, 'FU') & strcmp(masterAlphaExe.regionPair, region);
    if any(idxFU)
        FUCoh(i) = masterAlphaExe.cohAlphaExe(idxFU);
    end
end

% Now build the final table
resultTable2 = table(uniqueGroups.subjectID, uniqueGroups.regionPair, PreCoh, PostCoh, FUCoh, ...
    'VariableNames', {'subjectID', 'regionPair', 'PreCoh', 'PostCoh', 'FUCoh'});

% Compute difference scores and percent changes (using Pre as the base)
resultTable2.dPrePost = resultTable2.PreCoh - resultTable2.PostCoh;
resultTable2.dPreFU   = resultTable2.PreCoh - resultTable2.FUCoh;
resultTable2.dPrePostPct = (resultTable2.dPrePost ./ resultTable2.PreCoh) * 100;
resultTable2.dPreFUPct   = (resultTable2.dPreFU   ./ resultTable2.PreCoh) * 100;

%% same for betaPrep

% Get unique combinations of subjectID and regionPair
uniqueGroups = unique(masterBetaPrep(:, {'subjectID', 'regionPair'}));
nGroups = height(uniqueGroups);

% Preallocate arrays for the coherence values
PreCoh  = NaN(nGroups, 1);
PostCoh = NaN(nGroups, 1);
FUCoh   = NaN(nGroups, 1);

% Loop through each unique subject-region pair
for i = 1:nGroups
    subj   = uniqueGroups.subjectID{i};
    region = uniqueGroups.regionPair{i};

    % For Pre
    idxPre = strcmp(masterBetaPrep.subjectID, subj) & strcmp(masterBetaPrep.timePoint, 'Pre') & strcmp(masterBetaPrep.regionPair, region);
    if any(idxPre)
        PreCoh(i) = masterBetaPrep.cohBetaPrep(idxPre);
    end

    % For Post
    idxPost = strcmp(masterBetaPrep.subjectID, subj) & strcmp(masterBetaPrep.timePoint, 'Post') & strcmp(masterBetaPrep.regionPair, region);
    if any(idxPost)
        PostCoh(i) = masterBetaPrep.cohBetaPrep(idxPost);
    end

    % For FU
    idxFU = strcmp(masterBetaPrep.subjectID, subj) & strcmp(masterBetaPrep.timePoint, 'FU') & strcmp(masterBetaPrep.regionPair, region);
    if any(idxFU)
        FUCoh(i) = masterBetaPrep.cohBetaPrep(idxFU);
    end
end

% Now build the final table
resultTable3 = table(uniqueGroups.subjectID, uniqueGroups.regionPair, PreCoh, PostCoh, FUCoh, ...
    'VariableNames', {'subjectID', 'regionPair', 'PreCoh', 'PostCoh', 'FUCoh'});

% Compute difference scores and percent changes (using Pre as the base)
resultTable3.dPrePost = resultTable3.PreCoh - resultTable3.PostCoh;
resultTable3.dPreFU   = resultTable3.PreCoh - resultTable3.FUCoh;
resultTable3.dPrePostPct = (resultTable3.dPrePost ./ resultTable3.PreCoh) * 100;
resultTable3.dPreFUPct   = (resultTable3.dPreFU   ./ resultTable3.PreCoh) * 100;

%% same for betaExe

% Get unique combinations of subjectID and regionPair
uniqueGroups = unique(masterBetaPrep(:, {'subjectID', 'regionPair'}));
nGroups = height(uniqueGroups);

% Preallocate arrays for the coherence values
PreCoh  = NaN(nGroups, 1);
PostCoh = NaN(nGroups, 1);
FUCoh   = NaN(nGroups, 1);

% Loop through each unique subject-region pair
for i = 1:nGroups
    subj   = uniqueGroups.subjectID{i};
    region = uniqueGroups.regionPair{i};

    % For Pre
    idxPre = strcmp(masterBetaExe.subjectID, subj) & strcmp(masterBetaExe.timePoint, 'Pre') & strcmp(masterBetaExe.regionPair, region);
    if any(idxPre)
        PreCoh(i) = masterBetaExe.cohBetaExe(idxPre);
    end

    % For Post
    idxPost = strcmp(masterBetaExe.subjectID, subj) & strcmp(masterBetaExe.timePoint, 'Post') & strcmp(masterBetaExe.regionPair, region);
    if any(idxPost)
        PostCoh(i) = masterBetaExe.cohBetaExe(idxPost);
    end

    % For FU
    idxFU = strcmp(masterBetaExe.subjectID, subj) & strcmp(masterBetaExe.timePoint, 'FU') & strcmp(masterBetaExe.regionPair, region);
    if any(idxFU)
        FUCoh(i) = masterBetaExe.cohBetaExe(idxFU);
    end
end

% Now build the final table
resultTable4 = table(uniqueGroups.subjectID, uniqueGroups.regionPair, PreCoh, PostCoh, FUCoh, ...
    'VariableNames', {'subjectID', 'regionPair', 'PreCoh', 'PostCoh', 'FUCoh'});

% Compute difference scores and percent changes (using Pre as the base)
resultTable4.dPrePost = resultTable4.PreCoh - resultTable4.PostCoh;
resultTable4.dPreFU   = resultTable4.PreCoh - resultTable4.FUCoh;
resultTable4.dPrePostPct = (resultTable4.dPrePost ./ resultTable4.PreCoh) * 100;
resultTable4.dPreFUPct   = (resultTable4.dPreFU   ./ resultTable4.PreCoh) * 100;

%% average all the changes across participatns by pair and time point
alphaPrepMaster = groupsummary(resultTable1, 'regionPair', 'mean', ...
    {'PreCoh', 'PostCoh', 'FUCoh', 'dPrePost', 'dPreFU', 'dPrePostPct', 'dPreFUPct'});

alphaExeMaster = groupsummary(resultTable2, 'regionPair', 'mean', ...
    {'PreCoh', 'PostCoh', 'FUCoh', 'dPrePost', 'dPreFU', 'dPrePostPct', 'dPreFUPct'});

betaPrepMaster = groupsummary(resultTable3, 'regionPair', 'mean', ...
    {'PreCoh', 'PostCoh', 'FUCoh', 'dPrePost', 'dPreFU', 'dPrePostPct', 'dPreFUPct'});

betaExeMaster = groupsummary(resultTable4, 'regionPair', 'mean', ...
    {'PreCoh', 'PostCoh', 'FUCoh', 'dPrePost', 'dPreFU', 'dPrePostPct', 'dPreFUPct'});

writetable(alphaPrepMaster,'alphaPrepMaster.csv');
writetable(alphaExeMaster,'alphaExeMaster.csv');
writetable(betaPrepMaster,'betaPrepMaster.csv');
writetable(betaExeMaster,'betaExeMaster.csv');

%% other miscellanous tasks
allAlphaPrepNV.subjectID = convertCharsToStrings(allAlphaPrepNV.subjectID);

%% for loop for plotting frequency/ across subjects
% ab used for MUSC SRD 2024

tableArray = {allAlphaPrepNV,allAlphaExeNV,allBetaPrepNV,allBetaExeNV};

% call function for plotting alphaPrep across subjs
sub_SRDfiguresInterSubject(allAlphaPrepNV,allAlphaExeNV,allBetaPrepNV, ...
    allBetaExeNV,timePoints,plotHandlesLeft,timeLabels,tempWolf,allPtID,excelFileNames)