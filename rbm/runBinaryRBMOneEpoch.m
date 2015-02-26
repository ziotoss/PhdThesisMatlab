function [errsum, reconerr, timeTaken] = runBinaryRBMOneEpoch(data, params, rbmModel, runtimeParams)
    errsum = 0;
    reconerr = 0;
    
    start = toc;
    for batch = 1:size(data,3)

        hidbiasesrep = repmat(rbmModel.hidbiases,1, size(data,2));
        visbiasesrep = repmat(rbmModel.visbiases,1, size(data,2));

        X = data(:, :, batch);
        numcases = size(data, 2);

        %%%%% START POSITIVE PHASE p(h=1 | v) %%%%%
        pnetinput = rbmModel.vishid*X + hidbiasesrep;
        
        if strcmp(params.hidtype, 'linear')
            possigmoid = pnetinput;
        else
            possigmoid   = 1./(1 + exp( - pnetinput)  );
        end

        poshidstates = possigmoid > rand(size(possigmoid));

        posprods     = possigmoid * X';
        poshidact    = sum(possigmoid, 2);
        posvisact    = sum(X, 2);

        %%%%% START NEGATIVE PHASE p(v=1 | h) %%%%%
        negdata  = (rbmModel.vishid'*poshidstates) + visbiasesrep;
        negdata = 1./(1 + exp( - negdata)  );

        nnetinput = rbmModel.vishid*negdata + hidbiasesrep;
        
        if strcmp(params.hidtype, 'linear')
            negsigmoid = nnetinput;
        else
            negsigmoid= 1./(1 + exp( - nnetinput)  );
        end

        negprods    = negsigmoid * negdata';
        neghidact   = sum(negsigmoid, 2);
        negvisact   = sum(negdata, 2);

        %%%%% ERROR CALCULATION %%%%%
        err = mean(sum( (X-negdata).^2 ));
        errsum = err + errsum;
        
        recon = (rbmModel.vishid'*possigmoid) + visbiasesrep;
        rerr = mean(sum( (X-recon).^2 )); 
        reconerr = rerr + reconerr;

        %%%%% UPDATE WEIGHTS AND BIASES %%%%%
        runtimeParams.averageActivations = (1 - params.activationAveragingConstant) * runtimeParams.averageActivations + ...
                                            params.activationAveragingConstant * ...
                                            mean(possigmoid, 2);
        
        runtimeParams.vishidinc = runtimeParams.momentum*runtimeParams.vishidinc + ...
                    params.epsilon*( (posprods-negprods)/numcases - params.weightcost*rbmModel.vishid);
        runtimeParams.visbiasinc = runtimeParams.momentum*runtimeParams.visbiasinc + (params.epsilon/numcases)*(posvisact-negvisact);
        runtimeParams.hidbiasinc = runtimeParams.momentum*runtimeParams.hidbiasinc + (params.epsilon/numcases)*(poshidact-neghidact); % + sparsityinc 

        rbmModel.vishid = rbmModel.vishid + runtimeParams.vishidinc;
        rbmModel.visbiases = rbmModel.visbiases + runtimeParams.visbiasinc;
        rbmModel.hidbiases = rbmModel.hidbiases + runtimeParams.hidbiasinc;
        rbmModel.batchposhidprob(:, :, batch) = possigmoid;
    end

    timeTaken = toc - start;
end
