function [betaPrePinchNegTwoToZeroNV, betaPrePinchZeroToTwoNV, ...
          betaPrePinchNegTwoToZeroV, betaPrePinchZeroToTwoV, ...
          betaPostPinchNegTwoToZeroNV, betaPostPinchZeroToTwoNV, ...
          betaPostPinchNegTwoToZeroV, betaPostPinchZeroToTwoV, ...
          betaFUPinchNegTwoToZeroNV, betaFUPinchZeroToTwoNV, ...
          betaFUPinchNegTwoToZeroV, betaFUPinchZeroToTwoV] = ...
    sub_getBetaCCC(dataCCCBetaNV, dataCCCBetaV, ...
                   preTrialsAvailableNV, postTrialsAvailableNV, fuTrialsAvailableNV, ...
                   preTrialsAvailableV, postTrialsAvailableV, fuTrialsAvailableV, ...
                   postIdxNV, postIdxV, lastRowNV, lastRowV, pairsCccChar, y)
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