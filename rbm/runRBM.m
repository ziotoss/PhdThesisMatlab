function [params, rbmModel, runtimeParams] = runRBM(data, params, logfile)
    tic;

    applog(logfile, ':: Running RBM Training');
    applog(logfile, ['-- Max Epoch ' num2str(params.maxEpoch)]);
    applog(logfile, ['-- Weight Cost ' num2str(params.weightcost)]);
    applog(logfile, ['-- Hidden Layer Size ' num2str(params.hiddenLayerSize)]);

    % Setup AutoEncoder
    [rbmModel, runtimeParams] = setupReLURBM(params);

    % Run for a few Epochs
    for epoch = 1:params.maxEpoch,

        if epoch > params.epochfinalmomentum,
            runtimeParams.momentum = params.finalmomentum;
        end
        
        if strcmp(params.vistype, 'binary')
            [errsum, reconerr, timeTaken] = runBinaryRBMOneEpoch(data, params, rbmModel, runtimeParams);
        elseif strcmp(params.vistype, 'poisson')
            [errsum, reconerr, timeTaken] = runPoissonRBMOneEpoch(data, params, rbmModel, runtimeParams);
        elseif strcmp(params.type, 'gaussian')
            [errsum, reconerr, timeTaken] = runGaussianRBMOneEpoch(data, params, rbmModel, runtimeParams);
        end

        % params.epsilon = max(params.minepsilon, params.epsilon * params.annealepsilon); 

        % Log String
        logString = sprintf('-- Epoch %4i serror %f rerror %f meanact %f wnorm %f timeElapsed %f', epoch, errsum / size(data,3), ...
                            reconerr / size(data,3), mean(runtimeParams.averageActivations),...
                            sum(sqrt(sum(rbmModel.vishid.*rbmModel.vishid,2))), ...
                            timeTaken);

        applog(logfile, logString);
    end
end