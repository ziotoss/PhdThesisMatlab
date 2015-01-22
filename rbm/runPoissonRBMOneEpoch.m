function [errsum, reconerr, timeTaken] = runPoissonRBMOneEpoch(data, params, rbmModel, runtimeParams)
    errsum = 0;
    reconerr = 0;
    delta = params.epsilon / params.batchSize;
    
    start = toc;
    for batch = 1:size(data,3)

        hidbiasesrep = repmat(rbmModel.hidbiases,1, size(data,2));
        visbiasesrep = repmat(rbmModel.visbiases,1, size(data,2));

        X = data(:, :, batch);

        %%%%% START POSITIVE PHASE p(h=1 | v) %%%%%
        D = sum(X, 1);
        pnetinput = rbmModel.vishid*X + hidbiasesrep .* repmat(D, size(hidbiasesrep, 1), 1);
        possigmoid   = 1./(1 + exp( - pnetinput)  );

        poshidstates = possigmoid > rand(size(possigmoid));
        posnetinputre = possigmoid;

        posprods     = posnetinputre * X';
        poshidact    = sum(posnetinputre, 2);
        posvisact    = sum(X, 2);

        %%%%% START NEGATIVE PHASE p(v=1 | h) %%%%%
        negdata  = (rbmModel.vishid'*poshidstates) + visbiasesrep;
        tmp = exp(negdata);
        sumtmp = sum(tmp, 1);
        v2_pdf = tmp ./ repmat(sumtmp, size(tmp , 1), 1);
        negdata = mnrnd(D', v2_pdf');
        negdata = negdata';

        nnetinput = rbmModel.vishid*negdata + hidbiasesrep .* repmat(D, size(hidbiasesrep, 1), 1);
        negnetinputre= 1./(1 + exp( - nnetinput)  );

        negprods    = negnetinputre * negdata';
        neghidact   = sum(negnetinputre, 2);
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
        
        runtimeParams.vishidinc = runtimeParams.momentum*runtimeParams.vishidinc + posprods - negprods;
        runtimeParams.visbiasinc = runtimeParams.momentum*runtimeParams.visbiasinc + posvisact - negvisact;
        runtimeParams.hidbiasinc = runtimeParams.momentum*runtimeParams.hidbiasinc + poshidact - neghidact; % + sparsityinc 

        rbmModel.vishid = rbmModel.vishid + delta * runtimeParams.vishidinc;
        rbmModel.visbiases = rbmModel.visbiases + delta * runtimeParams.visbiasinc;
        rbmModel.hidbiases = rbmModel.hidbiases + delta * runtimeParams.hidbiasinc;
        rbmModel.batchposhidprob(:, :, batch) = possigmoid;
    end

    timeTaken = toc - start;
end
