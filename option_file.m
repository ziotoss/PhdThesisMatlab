%%%%% DATA RELATED OPTIONS %%%%%
options.data.type = 'test';
options.data.normalize = 0;
options.data.preprocess.on = 0;
options.data.preprocess.type = 'tf-idf';

options.preproc.pca.dim = 64;
options.preproc.pca.eps = 0.01;
options.preproc.pca.retained = 0.9;

%%%%% FEATURE LEARNING OPTIONS %%%%%
options.fl.rbm.vistype = 'gaussian'; % binary, gaussian, poisson
if strcmp(options.fl.rbm.vistype, 'binary')
    options.fl.rbm.epsilon = 0.01;
elseif strcmp(options.fl.rbm.vistype, 'poisson')
    options.fl.rbm.epsilon = 0.0001;
elseif strcmp(options.fl.rbm.vistype, 'gaussian')
    options.fl.rbm.epsilon = 0.001;
end

if strcmp(options.fl.rbm.vistype, 'gaussian')
    options.fl.rbm.weight_cost = 0.001;
else
    options.fl.rbm.weight_cost = 0.002;
end
options.fl.rbm.maxEpoch = 300;
options.fl.rbm.hidden_layer = 256;
options.fl.rbm.batch_size = 100;