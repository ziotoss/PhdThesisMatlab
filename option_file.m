%%%%% DATA RELATED OPTIONS %%%%%
options.data.type = 'test';
options.data.normalize = 0;
options.data.preprocess.on = 0;
options.data.preprocess.type = 'tf-idf';

%%%%% FEATURE LEARNING OPTIONS %%%%%
options.fl.rbm.type = 'poisson'; % binary, gaussian, poisson
if strcmp(options.fl.rbm.type, 'binary')
    options.fl.rbm.epsilon = 0.1;
elseif strcmp(options.fl.rbm.type, 'poisson')
    options.fl.rbm.epsilon = 0.0001;
end
options.fl.rbm.weight_cost = 0.002;
options.fl.rbm.maxEpoch = 1000;
options.fl.rbm.hidden_layer = 50;
options.fl.rbm.batch_size = 90;