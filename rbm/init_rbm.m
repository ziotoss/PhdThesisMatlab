function rbm_params = init_rbm(input_size, num_input, options)

    % RBM parameters
    rbm_params = ReLURBMParameters;

    rbm_params.type = options.fl.rbm.type;
    
    rbm_params.initvisbiases = 0.001;
    rbm_params.inithidbiases = 0.001;
    rbm_params.initMult = 0.001;
    
    rbm_params.epsilon = options.fl.rbm.epsilon;
    rbm_params.weightcost = options.fl.rbm.weight_cost;

    rbm_params.maxEpoch  = options.fl.rbm.maxEpoch;
    rbm_params.epochfinalmomentum = rbm_params.maxEpoch/5;
    
    rbm_params.batchSize = options.fl.rbm.batch_size;
    rbm_params.inputSize = input_size;
    rbm_params.numBatch = floor(num_input / rbm_params.batchSize);
    rbm_params.hiddenLayerSize = options.fl.rbm.hidden_layer;
    
    rbm_params.activationAveragingConstant = 0.01;
end