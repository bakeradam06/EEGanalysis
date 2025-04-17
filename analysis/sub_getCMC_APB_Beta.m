function [cmcBetaPreNegFiveToNegThree_NV, cmcBetaPreNegFourToNegTwo_NV, cmcBetaPreNegThreeToNegOne_NV, ...
    cmcBetaPreNegTwoToZero_NV, cmcBetaPreZeroToTwo_NV, ...
    cmcBetaPostNegFiveToNegThree_NV, cmcBetaPostNegFourToNegTwo_NV, cmcBetaPostNegThreeToNegOne_NV, ...
    cmcBetaPostNegTwoToZero_NV, cmcBetaPostZeroToTwo_NV, ...
    cmcBetaFUNegFiveToNegThree_NV, cmcBetaFUNegFourToNegTwo_NV, cmcBetaFUNegThreeToNegOne_NV, ...
    cmcBetaFUNegTwoToZero_NV, cmcBetaFUZeroToTwo_NV, ...
    cmcBetaPreNegFiveToNegThree_V, cmcBetaPreNegFourToNegTwo_V, cmcBetaPreNegThreeToNegOne_V, ...
    cmcBetaPreNegTwoToZero_V, cmcBetaPreZeroToTwo_V, ...
    cmcBetaPostNegFiveToNegThree_V, cmcBetaPostNegFourToNegTwo_V, cmcBetaPostNegThreeToNegOne_V, ...
    cmcBetaPostNegTwoToZero_V, cmcBetaPostZeroToTwo_V, ...
    cmcBetaFUNegFiveToNegThree_V, cmcBetaFUNegFourToNegTwo_V, cmcBetaFUNegThreeToNegOne_V, ...
    cmcBetaFUNegTwoToZero_V, cmcBetaFUZeroToTwo_V, ...
    lastRowNV, lastRowV] = ...
    sub_getCMC_APB_Beta(dataCMCBetaNV_APB, dataCMCBetaV_APB, ...
    preTrialsAvailableNV, postTrialsAvailableNV, fuTrialsAvailableNV, ...
    preTrialsAvailableV, postTrialsAvailableV, fuTrialsAvailableV, ...
    postIdxNV, postIdxV, pairsCccChar, y)

%% Pre NoVib
cmcBetaPreNegFiveToNegThree_NV = dataCMCBetaNV_APB{y}(4:3+preTrialsAvailableNV, 9:36);
cmcBetaPreNegFiveToNegThree_NV.Properties.VariableNames = pairsCccChar;

cmcBetaPreNegFourToNegTwo_NV = dataCMCBetaNV_APB{y}(4:3+preTrialsAvailableNV, 38:65);
cmcBetaPreNegFourToNegTwo_NV.Properties.VariableNames = pairsCccChar;

cmcBetaPreNegThreeToNegOne_NV = dataCMCBetaNV_APB{y}(4:3+preTrialsAvailableNV, 67:94);
cmcBetaPreNegThreeToNegOne_NV.Properties.VariableNames = pairsCccChar;

cmcBetaPreNegTwoToZero_NV = dataCMCBetaNV_APB{y}(4:3+preTrialsAvailableNV, 96:123);
cmcBetaPreNegTwoToZero_NV.Properties.VariableNames = pairsCccChar;

cmcBetaPreZeroToTwo_NV = dataCMCBetaNV_APB{y}(4:3+preTrialsAvailableNV, 154:181);
cmcBetaPreZeroToTwo_NV.Properties.VariableNames = pairsCccChar;

%% Pre Vib
cmcBetaPreNegFiveToNegThree_V = dataCMCBetaV_APB{y}(4:3+preTrialsAvailableV, 9:36);
cmcBetaPreNegFiveToNegThree_V.Properties.VariableNames = pairsCccChar;

cmcBetaPreNegFourToNegTwo_V = dataCMCBetaV_APB{y}(4:3+preTrialsAvailableV, 38:65);
cmcBetaPreNegFourToNegTwo_V.Properties.VariableNames = pairsCccChar;

cmcBetaPreNegThreeToNegOne_V = dataCMCBetaV_APB{y}(4:3+preTrialsAvailableV, 67:94);
cmcBetaPreNegThreeToNegOne_V.Properties.VariableNames = pairsCccChar;

cmcBetaPreNegTwoToZero_V = dataCMCBetaV_APB{y}(4:3+preTrialsAvailableV, 96:123);
cmcBetaPreNegTwoToZero_V.Properties.VariableNames = pairsCccChar;

cmcBetaPreZeroToTwo_V = dataCMCBetaV_APB{y}(4:3+preTrialsAvailableV, 154:181);
cmcBetaPreZeroToTwo_V.Properties.VariableNames = pairsCccChar;

%% Post NoVib
cmcBetaPostNegFiveToNegThree_NV = dataCMCBetaNV_APB{y}(postIdxNV:postIdxNV+postTrialsAvailableNV-1, 9:36);
cmcBetaPostNegFiveToNegThree_NV.Properties.VariableNames = pairsCccChar;

cmcBetaPostNegFourToNegTwo_NV = dataCMCBetaNV_APB{y}(postIdxNV:postIdxNV+postTrialsAvailableNV-1, 38:65);
cmcBetaPostNegFourToNegTwo_NV.Properties.VariableNames = pairsCccChar;

cmcBetaPostNegThreeToNegOne_NV = dataCMCBetaNV_APB{y}(postIdxNV:postIdxNV+postTrialsAvailableNV-1, 67:94);
cmcBetaPostNegThreeToNegOne_NV.Properties.VariableNames = pairsCccChar;

cmcBetaPostNegTwoToZero_NV = dataCMCBetaNV_APB{y}(postIdxNV:postIdxNV+postTrialsAvailableNV-1, 96:123);
cmcBetaPostNegTwoToZero_NV.Properties.VariableNames = pairsCccChar;

cmcBetaPostZeroToTwo_NV = dataCMCBetaNV_APB{y}(postIdxNV:postIdxNV+postTrialsAvailableNV-1, 154:181);
cmcBetaPostZeroToTwo_NV.Properties.VariableNames = pairsCccChar;

%% Post Vib
cmcBetaPostNegFiveToNegThree_V = dataCMCBetaV_APB{y}(postIdxV:postIdxV+postTrialsAvailableV-1, 9:36);
cmcBetaPostNegFiveToNegThree_V.Properties.VariableNames = pairsCccChar;

cmcBetaPostNegFourToNegTwo_V = dataCMCBetaV_APB{y}(postIdxV:postIdxV+postTrialsAvailableV-1, 38:65);
cmcBetaPostNegFourToNegTwo_V.Properties.VariableNames = pairsCccChar;

cmcBetaPostNegThreeToNegOne_V = dataCMCBetaV_APB{y}(postIdxV:postIdxV+postTrialsAvailableV-1, 67:94);
cmcBetaPostNegThreeToNegOne_V.Properties.VariableNames = pairsCccChar;

cmcBetaPostNegTwoToZero_V = dataCMCBetaV_APB{y}(postIdxV:postIdxV+postTrialsAvailableV-1, 96:123);
cmcBetaPostNegTwoToZero_V.Properties.VariableNames = pairsCccChar;

cmcBetaPostZeroToTwo_V = dataCMCBetaV_APB{y}(postIdxV:postIdxV+postTrialsAvailableV-1, 154:181);
cmcBetaPostZeroToTwo_V.Properties.VariableNames = pairsCccChar;

%% FU
lastRowNV = size(dataCMCBetaNV_APB{y}, 1);
lastRowV = size(dataCMCBetaV_APB{y}, 1);

cmcBetaFUNegFiveToNegThree_NV = dataCMCBetaNV_APB{y}(lastRowNV-fuTrialsAvailableNV+1:lastRowNV, 9:36);
cmcBetaFUNegFiveToNegThree_NV.Properties.VariableNames = pairsCccChar;

cmcBetaFUNegFourToNegTwo_NV = dataCMCBetaNV_APB{y}(lastRowNV-fuTrialsAvailableNV+1:lastRowNV, 38:65);
cmcBetaFUNegFourToNegTwo_NV.Properties.VariableNames = pairsCccChar;

cmcBetaFUNegThreeToNegOne_NV = dataCMCBetaNV_APB{y}(lastRowNV-fuTrialsAvailableNV+1:lastRowNV, 67:94);
cmcBetaFUNegThreeToNegOne_NV.Properties.VariableNames = pairsCccChar;

cmcBetaFUNegTwoToZero_NV = dataCMCBetaNV_APB{y}(lastRowNV-fuTrialsAvailableNV+1:lastRowNV, 96:123);
cmcBetaFUNegTwoToZero_NV.Properties.VariableNames = pairsCccChar;

cmcBetaFUZeroToTwo_NV = dataCMCBetaNV_APB{y}(lastRowNV-fuTrialsAvailableNV+1:lastRowNV, 154:181);
cmcBetaFUZeroToTwo_NV.Properties.VariableNames = pairsCccChar;

cmcBetaFUNegFiveToNegThree_V = dataCMCBetaV_APB{y}(lastRowV-fuTrialsAvailableV+1:lastRowV, 9:36);
cmcBetaFUNegFiveToNegThree_V.Properties.VariableNames = pairsCccChar;

cmcBetaFUNegFourToNegTwo_V = dataCMCBetaV_APB{y}(lastRowV-fuTrialsAvailableV+1:lastRowV, 38:65);
cmcBetaFUNegFourToNegTwo_V.Properties.VariableNames = pairsCccChar;

cmcBetaFUNegThreeToNegOne_V = dataCMCBetaV_APB{y}(lastRowV-fuTrialsAvailableV+1:lastRowV, 67:94);
cmcBetaFUNegThreeToNegOne_V.Properties.VariableNames = pairsCccChar;

cmcBetaFUNegTwoToZero_V = dataCMCBetaV_APB{y}(lastRowV-fuTrialsAvailableV+1:lastRowV, 96:123);
cmcBetaFUNegTwoToZero_V.Properties.VariableNames = pairsCccChar;

cmcBetaFUZeroToTwo_V = dataCMCBetaV_APB{y}(lastRowV-fuTrialsAvailableV+1:lastRowV, 154:181);
cmcBetaFUZeroToTwo_V.Properties.VariableNames = pairsCccChar;
end