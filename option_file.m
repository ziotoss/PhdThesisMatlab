%%%%% DATA RELATED OPTIONS %%%%%
options.data.type = 'test';
options.data.normalize = 0;
options.data.preprocess.on = 0;
options.data.preprocess.type = 'tf-idf';

%%%%% FEATURE LEARNING OPTIONS %%%%%
options.fl.rbm.vistype = 'poisson'; % binary, gaussian, poisson
options.fl.rbm.hidtype = 'binary'; % binary, linear
options.fl.rbm.maxEpoch = 300;
options.fl.rbm.hidden_layer = [1000, 500, 150, 125];
options.fl.rbm.batch_size = 100;