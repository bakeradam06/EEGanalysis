function [cmcBetaPreNegTwoToZero, cmcBetaPreZeroToTwo, ...
          cmcBetaPostNegTwoToZero, cmcBetaPostZeroToTwo, ...
          cmcBetaFUNegTwoToZero, cmcBetaFUZeroToTwo, ...
          lastRowNV] = ...
    sub_getCMC_FDI_Beta(dataCMCBetaNV_FDI, ...
                            preTrialsAvailableNV, postTrialsAvailableNV, fuTrialsAvailableNV, ...
                            postIdxNV, pairsCmcChar, y)

    %% Pre
    cmcBetaPreNegTwoToZero = dataCMCBetaNV_FDI{y}(4:3+preTrialsAvailableNV, 57:64);
    cmcBetaPreNegTwoToZero.Properties.VariableNames = pairsCmcChar;

    cmcBetaPreZeroToTwo = dataCMCBetaNV_FDI{y}(4:3+preTrialsAvailableNV, 89:96);
    cmcBetaPreZeroToTwo.Properties.VariableNames = pairsCmcChar;

    %% Post
    cmcBetaPostNegTwoToZero = dataCMCBetaNV_FDI{y}(postIdxNV:postIdxNV+postTrialsAvailableNV-1, 57:64);
    cmcBetaPostNegTwoToZero.Properties.VariableNames = pairsCmcChar;

    cmcBetaPostZeroToTwo = dataCMCBetaNV_FDI{y}(postIdxNV:postIdxNV+postTrialsAvailableNV-1, 89:96);
    cmcBetaPostZeroToTwo.Properties.VariableNames = pairsCmcChar;

    %% FU
    lastRowNV = size(dataCMCBetaNV_FDI{y}, 1);

    cmcBetaFUNegTwoToZero = dataCMCBetaNV_FDI{y}(lastRowNV-fuTrialsAvailableNV+1:lastRowNV, 57:64);
    cmcBetaFUNegTwoToZero.Properties.VariableNames = pairsCmcChar;

    cmcBetaFUZeroToTwo = dataCMCBetaNV_FDI{y}(lastRowNV-fuTrialsAvailableNV+1:lastRowNV, 89:96);
    cmcBetaFUZeroToTwo.Properties.VariableNames = pairsCmcChar;
end