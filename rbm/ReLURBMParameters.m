classdef ReLURBMParameters < handle
    %RBMPARAMETERS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties

        vistype
        hidtype
        
        initvisbiases
        inithidbiases
        initMult
        
        epsilon  % Learning rate 
        weightcost

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
