function TrainRBM(scratch, path)

    addpath('rbm');
    option_file;
    if ~exist(scratch, 'dir')
        mkdir(scratch);
    end
    
    if ~isempty(strfind(path, 'Naver'))
        fileName = ['naver_dataset_' options.data.type '.mat'];
    elseif ~isempty(strfind(path, '20NewsGroups'))
        fileName = ['20newsgroups_dataset_' options.data.type '.mat'];
    end
    
    fprintf(1, 'Loading dataset');
    if ~exist([scratch filesep fileName], 'file')
        [dictionary, data] = load_dataset(path, options);
        save([scratch filesep fileName], 'dictionary', 'data');
    else
        load([scratch filesep fileName]);
    end
    
    if options.data.preprocess.on
        fprintf(1, ['Preprocessing data using ' options.data.preprocess.type]);
        data = run_preprocessing(data, options);
    end
    
    fprintf(1, 'Training RBM');
    params = init_rbm(size(data, 1), size(data, 2), options);   
    data = data(:, 1:(params.numBatch*params.batchSize));
    data = reshape(data, params.inputSize, params.batchSize, params.numBatch);
    [params, rbmModel, runtimeParams] = runRBM(data, params, 'log.txt');
    
    save([scratch filesep 'learned_params.mat'], 'params', 'rbmModel', 'runtimeParams');
    
end