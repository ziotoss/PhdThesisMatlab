function [rbmModel, runtimeParams] = setupReLURBM(params)

    runtimeParams = RuntimeParameters;
    rbmModel = ReLURBMModel;

    hiddenSize = params.hiddenLayerSize;

    rbmModel.vishid     = params.initMult*randn(hiddenSize, params.inputSize);
    rbmModel.hidbiases  = params.inithidbiases*randn(hiddenSize, 1);
    rbmModel.visbiases  = params.initvisbiases*randn(params.inputSize, 1);
    rbmModel.batchposhidprob = zeros(hiddenSize, params.batchSize, params.numBatch);

    % Setup Initial Parameters
    runtimeParams.averageActivations = zeros(hiddenSize, 1);
    runtimeParams.momentum = params.initialmomentum;

    % Temporary Storage
    runtimeParams.vishidinc  = zeros(hiddenSize, params.inputSize);
    runtimeParams.hidbiasinc = zeros(hiddenSize,1);
    runtimeParams.visbiasinc = zeros(params.inputSize,1);

end