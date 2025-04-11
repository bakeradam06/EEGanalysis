
% Created by AB - 2024-10-17
% Last modified - 2025-04-11
    % summary of changes: modified the tiledlayout to adapt to # of
    % participants being analyzed, so it's not hardcoded anymore.
    % evident by the line, for example ron = tiledlayout(numRows, numCols);



% make fig for 2024 MUSC SRD
% pulling alphaPrepNV data from currently processed pt EEG data and
% plotting in a tiledlayout. 

% same with the others (alpha exe, beta prep/exe)

function sub_SRDfiguresInterSubject(allAlphaPrepNV,allAlphaExeNV,allBetaPrepNV, ...
    allBetaExeNV,timePoints,plotHandlesLeft,timeLabels,tempWolf,allPtID,excelFileNames)

figure
numFiles = length(excelFileNames);
numCols = 5; 
numRows = ceil(numFiles / numCols);
neville = tiledlayout(numRows,numCols);

set(gcf,'Position', [23,137,1747,757]);

nSubjects = height(allAlphaPrepNV) / 3;
if ~isequal(nSubjects,height(allPtID))
    disp("ERROR: inconsistent # of patients between nSubjects & # allPtID values");
    return
else
end

%% start big plotting loop, plotting conditions (e.g., alpha prep) across subjects
%for i = 1:length(allPtID) % for all patients...
    %% alpha prep
    for i = 1:height(allAlphaPrepNV) % for all values alpha prep list...
        if i > length(allPtID)
            disp('done plotting');
            break
        end
        currentPt = [allPtID{i}];

        tableIdx = strcmp([allAlphaPrepNV.subjectID],(allPtID(i)));
        tempTable = double(allAlphaPrepNV{tableIdx,2:end});

        % note: chatGPT helped a little with this next part
        % slice data (pre/post/fu is every 3 rows)
        startRow = (i - 1) * 3 + 1;
        endRow = startRow + 2; % pre/post/fu. Three from startRow.
        disp(['currently plotting alphaPrep of ' allPtID{i}]);
        % subjDataTemp = allAlphaPrepNV{startRow:endRow,2:end}; % get data for all cols of these three rows
        nexttile(neville);
        hold on
        % note to self:
        % make this a function when you got more time
        for gustav = 2:(width(tempTable))
            if tempTable(2,gustav) < tempTable(1,gustav)
                mars = plot(timePoints, tempTable(:,gustav),'--o');
            else
                mars = plot(timePoints, tempTable(:,gustav),'-x');
            end
            plotHandlesLeft = [plotHandlesLeft,mars];
        end
        % left y axis
        ylabel('LaggedCoh');
        % x axis details
        xticks(timePoints);
        xticklabels(timeLabels);

        yyaxis right
        % note to self:
        % make this a function when you got more time
        for albus=1:height(tempWolf)
            if  tempWolf.subjID{albus} == currentPt
                dataIdx = strcmp(tempWolf.subjID,currentPt);
                subjSpecWolf = double(tempWolf{dataIdx,3});
                plot(timePoints,subjSpecWolf,'-s','LineWidth',2,'Color',[0 0 0.75]); % plot the time points, make thicker black line.
            end
        end
        ylabel('WMFT (s)');
        ylim([0 120]);
        ax = gca;
        ax.YColor = [0 0 0.75];
        title([ allPtID(i) ' Alpha Prep & WMFT']);

    savefig(gcf,'Alpha Prep & WMFT');
    saveas(gcf,strcat('Alpha Prep & WMFT','.png'));
    end
    allAxes = findall(gcf,"Type","axes"); % find all axes from subplots
    for dobbie = 1:length(allAxes) % go trhough all axes from above
        ax = allAxes(dobbie); % make var for all axes as loop goes
        xLimits = xlim(ax); % denote lim of current axis
        % make var of pad amt by adding 10% extra white space to the difference between xLim2 and xLim1
        padding = 0.025* (xLimits(2) - xLimits(1));
        % set new axes based on aboline
        xlim(ax, [xLimits(1) - padding, xLimits(2) + padding]);
    end

    %% alpha Exe
    figure
    ron = tiledlayout(numRows, numCols);
    set(gcf,'Position', [23,137,1747,757]);

    for i = 1:height(allAlphaExeNV) % for all values alpha prep list...
        if i > length(allPtID)
            disp('done plotting');
            break
        end
        currentPt = [allPtID{i}];

        tableIdx = strcmp([allAlphaExeNV.subjectID],(allPtID(i)));
        tempTable = double(allAlphaExeNV{tableIdx,2:end});

        % note: chatGPT helped a little with this next part
        % slice data (pre/post/fu is every 3 rows)
        startRow = (i - 1) * 3 + 1;
        endRow = startRow + 2; % pre/post/fu. Three from startRow.
        disp(['currently plotting alphaExe of ' allPtID{i}]);
        % subjDataTemp = allAlphaPrepNV{startRow:endRow,2:end}; % get data for all cols of these three rows
        nexttile(ron);
        hold on
        % note to self:
        % make this a function when you got more time
        for gustav = 2:(width(tempTable))
            if tempTable(2,gustav) < tempTable(1,gustav)
                mars = plot(timePoints, tempTable(:,gustav),'--o');
            else
                mars = plot(timePoints, tempTable(:,gustav),'-x');
            end
            plotHandlesLeft = [plotHandlesLeft,mars];
        end
        % left y axis
        ylabel('LaggedCoh');
        % x axis details
        xticks(timePoints);
        xticklabels(timeLabels);

        yyaxis right
        % note to self:
        % make this a function when you got more time
        for albus=1:height(tempWolf)
            if  tempWolf.subjID{albus} == currentPt
                dataIdx = strcmp(tempWolf.subjID,currentPt);
                subjSpecWolf = double(tempWolf{dataIdx,3});
                plot(timePoints,subjSpecWolf,'-s','LineWidth',2,'Color',[0 0 0.75]); % plot the time points, make thicker black line.
            end
        end
        ylabel('WMFT (s)');
        ylim([0 120]);
        ax = gca;
        ax.YColor = [0 0 0.75];
        title([ allPtID(i) ' Alpha Exe & WMFT']);

    savefig(gcf,'Alpha Exe & WMFT');
    saveas(gcf,strcat('Alpha Exe & WMFT','.png'));
    end
    allAxes = findall(gcf,"Type","axes"); % find all axes from subplots
    for dobbie = 1:length(allAxes) % go trhough all axes from above
        ax = allAxes(dobbie); % make var for all axes as loop goes
        xLimits = xlim(ax); % denote lim of current axis
        % make var of pad amt by adding 10% extra white space to the difference between xLim2 and xLim1
        padding = 0.025* (xLimits(2) - xLimits(1));
        % set new axes based on aboline
        xlim(ax, [xLimits(1) - padding, xLimits(2) + padding]);
    end

    %% beta prep
    figure
    james = tiledlayout(numRows, numCols);
    set(gcf,'Position', [23,137,1747,757]);

    for i = 1:height(allBetaPrepNV) % for all values alpha prep list...
        if i > length(allPtID)
            disp('done plotting');
            break
        end
        currentPt = [allPtID{i}];

        tableIdx = strcmp([allBetaPrepNV.subjectID],(allPtID(i)));
        tempTable = double(allBetaPrepNV{tableIdx,2:end});

        % note: chatGPT helped a little with this next part
        % slice data (pre/post/fu is every 3 rows)
        startRow = (i - 1) * 3 + 1;
        endRow = startRow + 2; % pre/post/fu. Three from startRow.
        disp(['currently plotting betaPrep of ' allPtID{i}]);
        % subjDataTemp = allAlphaPrepNV{startRow:endRow,2:end}; % get data for all cols of these three rows
        nexttile(james);
        hold on
        % note to self:
        % make this a function when you got more time
        for gustav = 2:(width(tempTable))
            if tempTable(2,gustav) < tempTable(1,gustav)
                mars = plot(timePoints, tempTable(:,gustav),'--o');
            else
                mars = plot(timePoints, tempTable(:,gustav),'-x');
            end
            plotHandlesLeft = [plotHandlesLeft,mars];
        end
        % left y axis
        ylabel('LaggedCoh');
        % x axis details
        xticks(timePoints);
        xticklabels(timeLabels);

        yyaxis right
        % note to self:
        % make this a function when you got more time
        for albus=1:height(tempWolf)
            if  tempWolf.subjID{albus} == currentPt
                dataIdx = strcmp(tempWolf.subjID,currentPt);
                subjSpecWolf = double(tempWolf{dataIdx,3});
                plot(timePoints,subjSpecWolf,'-s','LineWidth',2,'Color',[0 0 0.75]); % plot the time points, make thicker black line.
            end
        end
        ylabel('WMFT (s)');
        ylim([0 120]);
        ax = gca;
        ax.YColor = [0 0 0.75];
        title([ allPtID(i) ' Beta Prep & WMFT']);

    savefig(gcf,'Beta Prep & WFMT');
    saveas(gcf,strcat('Beta Prep & WMFT','.png'));
    end
    allAxes = findall(gcf,"Type","axes"); % find all axes from subplots
    for dobbie = 1:length(allAxes) % go trhough all axes from above
        ax = allAxes(dobbie); % make var for all axes as loop goes
        xLimits = xlim(ax); % denote lim of current axis
        % make var of pad amt by adding 10% extra white space to the difference between xLim2 and xLim1
        padding = 0.025* (xLimits(2) - xLimits(1));
        % set new axes based on aboline
        xlim(ax, [xLimits(1) - padding, xLimits(2) + padding]);
    end
%% beta exe
    figure
    sirius = tiledlayout(numRows, numCols);
    set(gcf,'Position', [23,137,1747,757]);

    for i = 1:height(allBetaExeNV) % for all values alpha prep list...
        if i > length(allPtID)
            disp('done plotting');
            break
        end
        currentPt = [allPtID{i}];

        tableIdx = strcmp([allBetaExeNV.subjectID],(allPtID(i)));
        tempTable = double(allBetaExeNV{tableIdx,2:end});

        % note: chatGPT helped a little with this next part
        % slice data (pre/post/fu is every 3 rows)
        startRow = (i - 1) * 3 + 1;
        endRow = startRow + 2; % pre/post/fu. Three from startRow.
        disp(['currently plotting betaExe of ' allPtID{i}]);
        % subjDataTemp = allAlphaPrepNV{startRow:endRow,2:end}; % get data for all cols of these three rows
        nexttile(sirius);
        hold on
        % note to self:
        % make this a function when you got more time
        for gustav = 2:(width(tempTable))
            if tempTable(2,gustav) < tempTable(1,gustav)
                mars = plot(timePoints, tempTable(:,gustav),'--o');
            else
                mars = plot(timePoints, tempTable(:,gustav),'-x');
            end
            plotHandlesLeft = [plotHandlesLeft,mars];
        end
        % left y axis
        ylabel('LaggedCoh');
        % x axis details
        xticks(timePoints);
        xticklabels(timeLabels);

        yyaxis right
        % note to self:
        % make this a function when you got more time
        for albus=1:height(tempWolf)
            if  tempWolf.subjID{albus} == currentPt
                dataIdx = strcmp(tempWolf.subjID,currentPt);
                subjSpecWolf = double(tempWolf{dataIdx,3});
                plot(timePoints,subjSpecWolf,'-s','LineWidth',2,'Color',[0 0 0.75]); % plot the time points, make thicker black line.
            end
        end
        ylabel('WMFT (s)');
        ylim([0 120]);
        ax = gca;
        ax.YColor = [0 0 0.75];
        title([ allPtID(i) ' Beta Exe & WMFT']);

    savefig(gcf,'Beta Exe & WFMT');
    saveas(gcf,strcat('Beta Exe & WMFT','.png'));
    end
    allAxes = findall(gcf,"Type","axes"); % find all axes from subplots
    for dobbie = 1:length(allAxes) % go trhough all axes from above
        ax = allAxes(dobbie); % make var for all axes as loop goes
        xLimits = xlim(ax); % denote lim of current axis
        % make var of pad amt by adding 10% extra white space to the difference between xLim2 and xLim1
        padding = 0.025* (xLimits(2) - xLimits(1));
        % set new axes based on aboline
        xlim(ax, [xLimits(1) - padding, xLimits(2) + padding]);
    end



end



