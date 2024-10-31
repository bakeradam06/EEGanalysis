
% EEG analysis for 2024 MUSC SRD
% Preliminary analysis of TNT EEG data

% Created by AB on 2024-08-29
% Last modified on 2024-10-25

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
excelFileNames = dir(fullfile('step9excel/*.xlsm'));
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
    % rename the things i want. Account for all the variability in file names.
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
    exclusion2NV.Properties.VariableNames(1) = "pinch";
    exclusion2NV.Properties.VariableNames(2) = "open";
    % exclusion2V{1, 1}.Properties.VariableNames(1) = "pinch";
    % exclusion2V{1, 1}.Properties.VariableNames(2) = "open";

    %% alpha CCC %% 
    %for
    % pre Alpha NoVib CCC
    % PrePinchNegFiveToThreeNV = dataCCCAlphaNV{y}(4:63,9:36);
    % PrePinchNegFiveToThreeNV.Properties.VariableNames = pairsCccChar;
    % PrePinchNegFourToTwoNV = dataCCCAlphaNV{y}(4:63,38:65);
    % PrePinchNegFourToTwoNV.Properties.VariableNames = pairsCccChar;
    % PrePinchNegThreeToOneNV = dataCCCAlphaNV{y}(4:63,67:94);
    % PrePinchNegThreeToOneNV.Properties.VariableNames = pairsCccChar;
    PrePinchNegTwoToZeroNV = dataCCCAlphaNV{y}(4:63,96:123);
    PrePinchNegTwoToZeroNV.Properties.VariableNames = pairsCccChar;
    % PrePinchNegOneToOneNV = dataCCCAlphaNV{y}(4:63,125:152);
    % PrePinchNegOneToOneNV.Properties.VariableNames = pairsCccChar;
    PrePinchZeroToTwoNV = dataCCCAlphaNV{y}(4:63,154:181);
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
    PrePinchNegTwoToZeroV = dataCCCAlphaV{y}(4:63,96:123);
    PrePinchNegTwoToZeroV.Properties.VariableNames = pairsCccChar;
    % PrePinchNegOneToOneV = dataCCCAlphaV{y}(4:63,125:152);
    % PrePinchNegOneToOneV.Properties.VariableNames = pairsCccChar;
    PrePinchZeroToTwoV = dataCCCAlphaV{y}(4:63,154:181);
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
    PostPinchNegTwoToZeroNV = dataCCCAlphaNV{y}(64:123,96:123);
    PostPinchNegTwoToZeroNV.Properties.VariableNames = pairsCccChar;
    % PostPinchNegOneToOneNV = dataCCCAlphaNV{y}(64:123,125:152);
    % PostPinchNegOneToOneNV.Properties.VariableNames = pairsCccChar;
    PostPinchZeroToTwoNV = dataCCCAlphaNV{y}(64:123,154:181);
    PostPinchZeroToTwoNV.Properties.VariableNames = pairsCccChar;
    % PostPinchOnetoThreeNV = dataCCCAlphaNV{y}(64:123,183:210);
    % PostPinchOnetoThreeNV.Properties.VariableNames = pairsCccChar;
    % PostPinchTwoToFourNV = dataCCCAlphaNV{y}(64:123,212:239);
    % PostPinchTwoToFourNV.Properties.VariableNames = pairsCccChar;
    % PostPinchThreeToFiveNV = dataCCCAlphaNV{y}(64:123,241:268);
    % PostPinchThreeToFiveNV.Properties.VariableNames = pairsCccChar;

    % alpha Post Vib CCC
    % PostPinchNegFiveToThreeV = dataCCCAlphaV{y}(64:123,9:36);
    % PostPinchNegFiveToThreeV.Properties.VariableNames = pairsCccChar;
    % PostPinchNegFourToTwoV = dataCCCAlphaV{y}(64:123,38:65);
    % PostPinchNegFourToTwoV.Properties.VariableNames = pairsCccChar;
    % PostPinchNegThreeToOneV = dataCCCAlphaV{y}(64:123,67:94);
    % PostPinchNegThreeToOneV.Properties.VariableNames = pairsCccChar;
    PostPinchNegTwoToZeroV = dataCCCAlphaV{y}(64:123,96:123);
    PostPinchNegTwoToZeroV.Properties.VariableNames = pairsCccChar;
    % PostPinchNegOneToOneV = dataCCCAlphaV{y}(64:123,125:152);
    % PostPinchNegOneToOneV.Properties.VariableNames = pairsCccChar;
    PostPinchZeroToTwoV = dataCCCAlphaV{y}(64:123,154:181);
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

    % alpha FU NoVib CCC
    % FUPinchNegFiveToThreeNV = dataCCCAlphaNV{y}(124:183,9:36);
    % FUPinchNegFiveToThreeNV.Properties.VariableNames = pairsCccChar;
    % FUPinchNegFourToTwoNV = dataCCCAlphaNV{y}(124:183,38:65);
    % FUPinchNegFourToTwoNV.Properties.VariableNames = pairsCccChar;
    % FUPinchNegThreeToOneNV = dataCCCAlphaNV{y}(124:183,67:94);
    % FUPinchNegThreeToOneNV.Properties.VariableNames = pairsCccChar;
    FUPinchNegTwoToZeroNV = dataCCCAlphaNV{y}(124:183,96:123);
    FUPinchNegTwoToZeroNV.Properties.VariableNames = pairsCccChar;
    % FUPinchNegOneToOneNV = dataCCCAlphaNV{y}(124:183,125:152);
    % FUPinchNegOneToOneNV.Properties.VariableNames = pairsCccChar;
    FUPinchZeroToTwoNV = dataCCCAlphaNV{y}(124:183,154:181);
    FUPinchZeroToTwoNV.Properties.VariableNames = pairsCccChar;
    % FUPinchOnetoThreeNV = dataCCCAlphaNV{y}(124:183,183:210);
    % FUPinchOnetoThreeNV.Properties.VariableNames = pairsCccChar;
    % FUPinchTwoToFourNV = dataCCCAlphaNV{y}(124:183,212:239);
    % FUPinchTwoToFourNV.Properties.VariableNames = pairsCccChar;
    % FUPinchThreeToFiveNV = dataCCCAlphaNV{y}(124:183,241:268);
    % FUPinchThreeToFiveNV.Properties.VariableNames = pairsCccChar;

    % alpha FU Vib CCC
    % FUPinchNegFiveToThreeV = dataCCCAlphaV{y}(124:183,9:36);
    % FUPinchNegFiveToThreeV.Properties.VariableNames = pairsCccChar;
    % FUPinchNegFourToTwoV = dataCCCAlphaV{y}(124:183,38:65);
    % FUPinchNegFourToTwoV.Properties.VariableNames = pairsCccChar;
    % FUPinchNegThreeToOneV = dataCCCAlphaV{y}(124:183,67:94);
    % FUPinchNegThreeToOneV.Properties.VariableNames = pairsCccChar;
    FUPinchNegTwoToZeroV = dataCCCAlphaV{y}(124:183,96:123);
    FUPinchNegTwoToZeroV.Properties.VariableNames = pairsCccChar;
    % FUPinchNegOneToOneV = dataCCCAlphaV{y}(124:183,125:152);
    % FUPinchNegOneToOneV.Properties.VariableNames = pairsCccChar;
    FUPinchZeroToTwoV = dataCCCAlphaV{y}(124:183,154:181);
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
    betaPrePinchNegTwoToZeroNV = dataCCCBetaNV{y}(4:63,96:123);
    betaPrePinchNegTwoToZeroNV.Properties.VariableNames = pairsCccChar;
    % betaPinchNegOneToOneNV = dataCCCBetaNV{y}(4:63,125:152);
    % betaPrePinchNegOneToOneNV.Properties.VariableNames = pairsCccChar;
    betaPrePinchZeroToTwoNV = dataCCCBetaNV{y}(4:63,154:181);
    betaPrePinchZeroToTwoNV.Properties.VariableNames = pairsCccChar;
    % betaPrePinchOnetoThreeNV = dataCCCBetaNV{y}(4:63,183:210);
    % betaPrePinchOnetoThreeNV.Properties.VariableNames = pairsCccChar;
    % betaPrePinchTwoToFourNV = dataCCCBetaNV{y}(4:63,212:239);
    % betaPrePinchTwoToFourNV.Properties.VariableNames = pairsCccChar;
    % betaPrePinchThreeToFiveNV = dataCCCBetaNV{y}(4:63,241:268);
    % betaPrePinchThreeToFiveNV.Properties.VariableNames = pairsCccChar;

    % beta Pre Vib CCC
    % betaPrePinchNegFiveToThreeV = dataCCCBetaV{y}(4:63,9:36);
    % betaPrePinchNegFiveToThreeV.Properties.VariableNames = pairsCccChar;
    % betaPrePinchNegFourToTwoV = dataCCCBetaV{y}(4:63,38:65);
    % betaPrePinchNegFourToTwoV.Properties.VariableNames = pairsCccChar;
    % betaPrePinchNegThreeToOneV = dataCCCBetaV{y}(4:63,67:94);
    % betaPrePinchNegThreeToOneV.Properties.VariableNames = pairsCccChar;
    betaPrePinchNegTwoToZeroV = dataCCCBetaV{y}(4:63,96:123);
    betaPrePinchNegTwoToZeroV.Properties.VariableNames = pairsCccChar;
    % betaPrePinchNegOneToOneV = dataCCCBetaV{y}(4:63,125:152);
    % betaPrePinchNegOneToOneV.Properties.VariableNames = pairsCccChar;
    betaPrePinchZeroToTwoV = dataCCCBetaV{y}(4:63,154:181);
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
    betaPostPinchNegTwoToZeroNV = dataCCCBetaNV{y}(64:123,96:123);
    betaPostPinchNegTwoToZeroNV.Properties.VariableNames = pairsCccChar;
    % betaPostPinchNegOneToOneNV = dataCCCBetaNV{y}(64:123,125:152);
    % betaPostPinchNegOneToOneNV.Properties.VariableNames = pairsCccChar;
    betaPostPinchZeroToTwoNV = dataCCCBetaNV{y}(64:123,154:181);
    betaPostPinchZeroToTwoNV.Properties.VariableNames = pairsCccChar;
    % betaPostPinchOnetoThreeNV = dataCCCBetaNV{y}(64:123,183:210);
    % betaPostPinchOnetoThreeNV.Properties.VariableNames = pairsCccChar;
    % betaPostPinchTwoToFourNV = dataCCCBetaNV{y}(64:123,212:239);
    % betaPostPinchTwoToFourNV.Properties.VariableNames = pairsCccChar;
    % betaPostPinchThreeToFiveNV = dataCCCBetaNV{y}(64:123,241:268);
    % betaPostPinchThreeToFiveNV.Properties.VariableNames = pairsCccChar;

    % beta Post Vib CCC
    % betaPostPinchNegFiveToThreeV = dataCCCBetaV{y}(64:123,9:36);
    % betaPostPinchNegFiveToThreeV.Properties.VariableNames = pairsCccChar;
    % betaPostPinchNegFourToTwoV = dataCCCBetaV{y}(64:123,38:65);
    % betaPostPinchNegFourToTwoV.Properties.VariableNames = pairsCccChar;
    % betaPostPinchNegThreeToOneV = dataCCCBetaV{y}(64:123,67:94);
    % betaPostPinchNegThreeToOneV.Properties.VariableNames = pairsCccChar;
    betaPostPinchNegTwoToZeroV = dataCCCBetaV{y}(64:123,96:123);
    betaPostPinchNegTwoToZeroV.Properties.VariableNames = pairsCccChar;
    % betaPostPinchNegOneToOneV = dataCCCBetaV{y}(64:123,125:152);
    % betaPostPinchNegOneToOneV.Properties.VariableNames = pairsCccChar;
    betaPostPinchZeroToTwoV = dataCCCBetaV{y}(64:123,154:181);
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
    betaFUPinchNegTwoToZeroNV = dataCCCBetaNV{y}(124:183,96:123);
    betaFUPinchNegTwoToZeroNV.Properties.VariableNames = pairsCccChar;
    % betaFUPinchNegOneToOneNV = dataCCCBetaNV{y}(124:183,125:152);
    % betaFUPinchNegOneToOneNV.Properties.VariableNames = pairsCccChar;
    betaFUPinchZeroToTwoNV = dataCCCBetaNV{y}(124:183,154:181);
    betaFUPinchZeroToTwoNV.Properties.VariableNames = pairsCccChar;
    % betaFUPinchOnetoThreeNV = dataCCCBetaNV{y}(124:183,183:210);
    % betaFUPinchOnetoThreeNV.Properties.VariableNames = pairsCccChar;
    % betaFUPinchTwoToFourNV = dataCCCBetaNV{y}(124:183,212:239);
    % betaFUPinchTwoToFourNV.Properties.VariableNames = pairsCccChar;
    % betaFUPinchThreeToFiveNV = dataCCCBetaNV{y}(124:183,241:268);
    % betaFUPinchThreeToFiveNV.Properties.VariableNames = pairsCccChar;
    %
    % beta FU Vib CCC
    % betaFUPinchNegFiveToThreeV = dataCCCBetaV{y}(124:183,9:36);
    % betaFUPinchNegFiveToThreeV.Properties.VariableNames = pairsCccChar;
    % betaFUPinchNegFourToTwoV = dataCCCBetaV{y}(124:183,38:65);
    % betaFUPinchNegFourToTwoV.Properties.VariableNames = pairsCccChar;
    % betaFUPinchNegThreeToOneV = dataCCCBetaV{y}(124:183,67:94);
    % betaFUPinchNegThreeToOneV.Properties.VariableNames = pairsCccChar;
    betaFUPinchNegTwoToZeroV = dataCCCBetaV{y}(124:183,96:123);
    betaFUPinchNegTwoToZeroV.Properties.VariableNames = pairsCccChar;
    % betaFUPinchNegOneToOneV = dataCCCBetaV{y}(124:183,125:152);
    % betaFUPinchNegOneToOneV.Properties.VariableNames = pairsCccChar;
    betaFUPinchZeroToTwoV = dataCCCBetaV{y}(124:183,154:181);
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
    alphaPrepAllNV = vertcat(PrePinchNegTwoToZeroNV,PostPinchNegTwoToZeroNV,FUPinchZeroToTwoNV);
    alphaExeAllNV = vertcat(PrePinchZeroToTwoNV,PostPinchZeroToTwoNV,FUPinchZeroToTwoNV);
    betaPrepAllNV = vertcat(betaPrePinchNegTwoToZeroNV,betaPostPinchNegTwoToZeroNV,betaFUPinchZeroToTwoNV);
    betaExeAllNV = vertcat(betaPrePinchZeroToTwoNV,betaPostPinchZeroToTwoNV,betaFUPinchZeroToTwoNV);
    
    % % vert cat to compile everything togerthetr. 
    % alphaPrepAll = vertcat(alphaPrePinchPrep,alphaPostPinchPrep,alphaFUPinchPrep);
    % alphaExeAll = vertcat(alphaPrePinchExe,alphaPostPinchExe,alphaFUPinchExe);
    % betaPrepAll = vertcat(betaPrePinchPrep,betaPostPinchPrep,betaFUPinchPrep);
    % betaExeAll = vertcat(betaPrePinchExe,betaPostPinchExe,betaFUPinchExe);

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

%% Average the values within the Pre, Post, FU prep and exe
    % tempMean = [];
    % 
    % connAlphaPrePrep = []; %1
    % connAlphaPreExe = []; %2
    % connBetaPrePrep = []; %3
    % connBetaPreExe = []; %4
    % connAlphaPostPrep = []; %5
    % connAlphaPostExe = []; %6
    % connBetaPostPrep= []; %7
    % connBetaPostExe = []; %8
    % connAlphaFUPrep = []; %9
    % connAlphaFUExe = []; %10
    % connBetaFUPrep = []; %11
    % connBetaFUExe = []; %12
    % 
    % tableDir = {alphaPrePinchPrep, alphaPrePinchExe, betaPrePinchPrep, betaPrePinchExe...
    %     , alphaPostPinchPrep, alphaPostPinchExe, betaPostPinchPrep, betaPostPinchExe,...
    %     alphaFUPinchPrep, alphaFUPinchExe, betaFUPinchPrep, betaFUPinchExe}; 
    % 
    % %%%% maybe do a subject specific NoVib/Vib tables? this would allow vert
    % %%%% concatenation without alternating within one table betwee vib/novib.
    % 
    % 
    % % below is averaging NoVib and Vib results (not preferred by njs as 
    % % of 9/5/24).
    % 
    % for iTable=1:length(tableDir)
    % 
    %         % alpha Pre Prep CCC
    %     if iTable == 1
    %         currentTable = tableDir{1};
    %         tempMean = mean(currentTable);
    %         connAlphaPrePrep = vertcat(tempMean,connAlphaPrePrep);
    %         % alpha Pre Exe CCC
    %     elseif iTable == 2
    %         currentTable = tableDir{2};
    %         tempMean = mean(currentTable);
    %         connAlphaPreExe = vertcat(tempMean,connAlphaPreExe);
    % 
    %         % beta Pre Prep CCC
    %     elseif iTable == 3
    %         currentTable = tableDir{3};
    %         tempMean = mean(currentTable);
    %         connBetaPrePrep = vertcat(tempMean,connBetaPrePrep);
    %         % beta Pre Exe CCC
    %     elseif iTable == 4 
    %         currentTable = tableDir{4};
    %         tempMean = mean(currentTable);
    %         connBetaPreExe = vertcat(tempMean,connBetaPreExe);
    % 
    %         % alpha Post Prep CCC
    %     elseif iTable == 5
    %         currentTable = tableDir{5};
    %         tempMean = mean(currentTable);
    %         connAlphaPostPrep = vertcat(tempMean,connAlphaPostPrep);
    %         % alpha Post Exe CCC   
    %     elseif iTable == 6
    %         currentTable = tableDir{6};
    %         tempMean = mean(currentTable);
    %         connAlphaPostExe = vertcat(tempMean,connAlphaPostExe);
    % 
    %         % beta Post Prep CCC
    %     elseif iTable == 7
    %         currentTable = tableDir{7};
    %         tempMean = mean(currentTable);
    %         connBetaPostPrep = vertcat(tempMean,connBetaPostPrep);
    %         % beta Post Exe CCC
    %     elseif iTable == 8
    %         currentTable = tableDir{8};
    %         tempMean = mean(currentTable);
    %         connBetaPostExe = vertcat(tempMean,connBetaPostExe);
    % 
    %        % alpha FU Prep CCC
    %     elseif iTable == 9
    %         currentTable = tableDir{9};
    %         tempMean = mean(currentTable);
    %         connAlphaFUPrep = vertcat(tempMean,connAlphaFUPrep);
    %         % alpha FU Exe CCC
    %     elseif iTable == 10
    %         currentTable = tableDir{10};
    %         tempMean = mean(currentTable);
    %         connAlphaFUExe = vertcat(tempMean,connAlphaFUExe);
    % 
    %         % beta FU Prep CCC
    %     elseif iTable == 11
    %         currentTable = tableDir{11};
    %         tempMean = mean(currentTable);
    %         connBetaFUPrep = vertcat(tempMean,connBetaFUPrep);
    %         % beta FU Exe CCC
    %     elseif iTable == 12
    %         currentTable = tableDir{12};
    %         tempMean = mean(currentTable);
    %         connBetaFUExe = vertcat(tempMean,connBetaFUExe);
    %     end
    % end

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
    tempValsPre = [];
    tempValsPost = [];
    tempValsFU = [];

    for iTable=1:length(tableDir)

        % alpha Pre Prep CCC
        if iTable == 1
            currentTable = tableDir{1};
            
            for rowPre = 1:60 % row 1:60 is Pre NV
                if currentTable{rowPre,"pinch"} == 1
                    tempValsPre = vertcat(tempValsPre,currentTable{rowPre,1:28});
                end
            end
            for rowPost = 61:120 % row 61:120 is Post NV
                if currentTable{rowPost,"pinch"} == 1
                    tempValsPost = vertcat(tempValsPost,currentTable{rowPost,1:28});
                end
            end
            for rowFU = 121:180 % row 121:180 is FU NV
                if currentTable{rowFU,"pinch"} == 1
                    tempValsFU = vertcat(tempValsFU,currentTable{rowFU,1:28});
                end
            end
            tempMeanPre = mean(tempValsPre,1);    
            tempMeanPost = mean(tempValsPost,1);
            tempMeanFU = mean(tempValsFU,1);

            connAlphaPrePrepNV = vertcat(tempMeanPre,connAlphaPrePrepNV);
            connAlphaPostPrepNV = vertcat(tempMeanPost,connAlphaPostPrepNV);
            connAlphaFUPrepNV = vertcat(tempMeanFU,connAlphaFUPrepNV);
        
            % alpha Pre Exe CCC
        elseif iTable == 2
            currentTable = tableDir{2};

            tempValsPre = [];
            tempValsPost = [];
            tempValsFU = [];

            for rowPre = 1:60 % Pre NV
                if currentTable{rowPre,"pinch"} == 1
                    tempValsPre = vertcat(tempValsPre,currentTable{rowPre,1:28});
                end
            end
            for rowPost = 61:120 % Post NV
                if currentTable{rowPost,"pinch"} == 1
                    tempValsPost = vertcat(tempValsPost,currentTable{rowPost,1:28});
                end
            end
            for rowFU = 121:180 % FU NV
                if currentTable{rowFU,"pinch"} == 1
                    tempValsFU = vertcat(tempValsFU,currentTable{rowFU,1:28});
                end
            end

            tempMeanPre = mean(tempValsPre,1);    
            tempMeanPost = mean(tempValsPost,1);
            tempMeanFU = mean(tempValsFU,1);
            
            connAlphaPreExeNV = vertcat(tempMeanPre,connAlphaPreExeNV);
            connAlphaPostExeNV = vertcat(tempMeanPost,connAlphaPostExeNV);
            connAlphaFUExeNV = vertcat(tempMeanFU,connAlphaFUExeNV);
        
            % beta Pre Prep CCC
        elseif iTable == 3
            currentTable = tableDir{3};

            tempValsPre = [];
            tempValsPost = [];
            tempValsFU = [];

            for rowPre = 1:60 % Pre NV
                if currentTable{rowPre,"pinch"} == 1
                    tempValsPre = vertcat(tempValsPre,currentTable{rowPre,1:28});
                end
            end
            for rowPost = 61:120 % Post NV
                if currentTable{rowPost,"pinch"} == 1
                    tempValsPost = vertcat(tempValsPost,currentTable{rowPost,1:28});
                end
            end
            for rowFU = 121:180 % FU NV
                if currentTable{rowFU,"pinch"} == 1
                    tempValsFU = vertcat(tempValsFU,currentTable{rowFU,1:28});
                end
            end

            tempMeanPre = mean(tempValsPre,1);    
            tempMeanPost = mean(tempValsPost,1);
            tempMeanFU = mean(tempValsFU,1);

            connBetaPrePrepNV = vertcat(tempMeanPre,connBetaPrePrepNV);
            connBetaPostPrepNV= vertcat(tempMeanPost,connBetaPostPrepNV);
            connBetaFUPrepNV = vertcat(tempMeanFU,connBetaFUPrepNV);

            % beta Exe CCC
        elseif iTable == 4
            currentTable = tableDir{4};
            
            tempValsPre = [];
            tempValsPost = [];
            tempValsFU = [];

            for rowPre = 1:60 % Pre NV
                if currentTable{rowPre,"pinch"} == 1
                    tempValsPre = vertcat(tempValsPre,currentTable{rowPre,1:28});
                end
            end
            for rowPost = 61:120 % Post NV
                if currentTable{rowPost,"pinch"} == 1
                    tempValsPost = vertcat(tempValsPost,currentTable{rowPost,1:28});
                end
            end
            for rowFU = 121:180 % FU NV
                if currentTable{rowFU,"pinch"} == 1
                    tempValsFU = vertcat(tempValsFU,currentTable{rowFU,1:28});
                end
            end

            tempMeanPre = mean(tempValsPre,1);    
            tempMeanPost = mean(tempValsPost,1);
            tempMeanFU = mean(tempValsFU,1);

            connBetaPreExeNV = vertcat(tempMeanPre,connBetaPreExeNV);
            connBetaPostExeNV = vertcat(tempMeanPost,connBetaPostExeNV);
            connBetaFUExeNV = vertcat(tempMeanFU,connBetaFUExeNV);
     
        end
    end

clear dataCCCAlphaNV dataCCCAlphaV dataCCCBetaNV dataCCCBetaV tempMeanFU tempMeanPost...
    tempMeanPre tempValsFU tempValsPost tempValsPre wolfTime exclusion2NV currentTable rowPre rowPost rowFU

  %% Compile mean Conn of tables above within loop
    % % combining the prep phase tables and the exe's respectively to have two
    % % 3x28 tables. This will allow for plotting of avg connectivity by region
    % % over time.
    % 
    % alpha Pre
    connAlphaPrepNV = vertcat(connAlphaPrePrepNV,connAlphaPostPrepNV,connAlphaFUPrepNV);
    % alpha Exe
    connAlphaExeNV = vertcat(connAlphaPreExeNV,connAlphaPostExeNV,connAlphaFUExeNV);
    % beta Prep
    connBetaPrepNV = vertcat(connBetaPrePrepNV,connBetaPostPrepNV,connBetaFUPrepNV);
    % beta Exe
    connBetaExeNV = vertcat(connBetaPreExeNV,connBetaPostExeNV,connBetaFUExeNV);
    
    clear betaPrepAllNVExc alphaExeAllNV alphaExeAllNVExc alphaPrepAllNV alphaPrepAllNVExc ...
    betaExeAllNV betaExeAllNVExc betaPrepAllNV
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
    %%
allAlphaPrepNV.subjectID = convertCharsToStrings(allAlphaPrepNV.subjectID);

clear tempAllAlphaPrepNV tempAllAlphaExeNV tempAllBetaPrepNV tempAllBetaExeNV currentPtTable

%% for loop for plotting frequency/ across subjects
% ab used for MUSC SRD 2024 

tableArray = {allAlphaPrepNV,allAlphaExeNV,allBetaPrepNV,allBetaExeNV};

% call function for plotting alphaPrep across subjs
sub_SRDfiguresInterSubject(allAlphaPrepNV,allAlphaExeNV,allBetaPrepNV, ...
    allBetaExeNV,timePoints,plotHandlesLeft,timeLabels,tempWolf,allPtID)

%%