function [PrePinchNegTwoToZeroNV, PrePinchZeroToTwoNV, ...
          PrePinchNegTwoToZeroV, PrePinchZeroToTwoV, ...
          PostPinchNegTwoToZeroNV, PostPinchZeroToTwoNV, ...
          PostPinchNegTwoToZeroV, PostPinchZeroToTwoV, ...
          FUPinchNegTwoToZeroNV, FUPinchZeroToTwoNV, ...
          FUPinchNegTwoToZeroV, FUPinchZeroToTwoV, lastRowNV, lastRowV] = ...
    sub_getAlphaCCC(dataCCCAlphaNV, dataCCCAlphaV, ...
                    preTrialsAvailableNV, postTrialsAvailableNV, fuTrialsAvailableNV, ...
                    preTrialsAvailableV, postTrialsAvailableV, fuTrialsAvailableV, ...
                    postIdxNV, postIdxV, pairsCccChar, y)
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