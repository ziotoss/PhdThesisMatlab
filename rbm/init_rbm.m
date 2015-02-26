function rbm_params = init_rbm(input_size, num_input, options, hidden_layer_size)

    % RBM parameters
    rbm_params = ReLURBMParameters;

    rbm_params.vistype = options.fl.rbm.vistype;
    rbm_params.hidtype = options.fl.rbm.hidtype;
    
    rbm_params.initvisbiases = 0.001;
    rbm_params.inithidbiases = 0.001;
    rbm_params.initMult = 0.001;
    
    if strcmp(options.fl.rbm.vistype, 'binary')
        rbm_params.epsilon = 0.1;    
        rbm_params.weightcost = 0.002;
    elseif strcmp(options.fl.rbm.vistype, 'poisson')
        rbm_params.epsilon = 0.0001;
        rbm_params.weightcost = 0.0002;
    end

    rbm_params.maxEpoch  = options.fl.rbm.maxEpoch;
    rbm_params.epochfinalmomentum = rbm_params.maxEpoch/5;
    
    rbm_params.batchSize = options.fl.rbm.batch_size;
    rbm_params.inputSize = input_size;
    rbm_params.numBatch = floor(num_input / rbm_params.batchSize);
    rbm_params.hiddenLayerSize = hidden_layer_size;
    
    rbm_params.activationAveragingConstant = 0.01;
end