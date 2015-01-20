classdef ReLURBMParameters < handle
    %RBMPARAMETERS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

        type
        
        initvisbiases
        inithidbiases
        initMult
        
        epsilon     = 0.003;   % Learning rate 
        weightcost  = 0.002;

        initialmomentum  = 0.5;
        finalmomentum    = 0.9;
        
        maxEpoch = 100;
        epochfinalmomentum = 5;

        batchSize
        inputSize
        numBatch
        hiddenLayerSize
        
        activationAveragingConstant = 0.01;

    end
    
    methods
    end
    
end
