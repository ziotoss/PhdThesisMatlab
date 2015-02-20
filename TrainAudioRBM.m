clear all;close all;

winSize = 0.1;
overlap = 0.05;
nfft = 1024;
nbands = 128;
sampleSize = 200000;

addpath('rbm');
addpath('audio_processing');
path = 'D:\Data\CAL500\CAL500_32kps\';
option_file;
non_existing_idx = [157, 246, 363];
% if ~exist(scratch, 'dir')
%     mkdir(scratch);
% end

if ~exist('scratch\msd_dataset.mat', 'file')
    D = dir(path);
    D = D(3:end);
    dataset = struct;

    for i = 1:length(D)
        [signal, fs] = audioread([path D(i).name]);
        signal = mean(signal, 2);
        f2m = fft2melmx(nfft, fs, nbands);
        f2m = f2m(:, 1:nfft / 2 + 1);

        [spec, fi, ti] = spectrogram(signal, floor(fs * winSize), floor(fs * overlap), nfft, fs);
        dataset(i).spec = f2m * abs(spec);
        dataset(i).fi = fi;
        dataset(i).ti = ti;
    end
else
    disp('LOADING DATASET');
    load('scratch\msd_dataset.mat');
end
    
fid = fopen('D:\Data\CAL500\hardAnnotations.txt');
C = textscan(fid, '%d', 'delimiter', ',');
fclose(fid);
tmp = C{1};
tmp = reshape(tmp, 174, 502);
tmp(:, non_existing_idx) = [];
genre = tmp(150:165, :);

% add preprocessing step if necessary
samplePerSong = ceil(sampleSize / length(dataset));
data = [];
genrePerFrame = [];
samplesIdx = 0;

for i = 1 : length(dataset)
    numSamples = min(samplePerSong, size(dataset(i).spec, 2));
    samplesIdx = [samplesIdx, samplesIdx(i) + numSamples];
    randIdx = randperm(size(dataset(i).spec, 2), numSamples);
    data = [data, dataset(i).spec(:, randIdx)];
    genreIdx = find(genre(:, i) == 1);
    if isempty(genreIdx)
        genreIdx = 0;
    elseif length(genreIdx) > 1
        genreIdx = genreIdx(1);
    end
    genrePerFrame  = [genrePerFrame, repmat(genreIdx, 1, numSamples)];
end

data_mean = mean(data, 1);
data_std = std(data, 1) + eps;

data = data - repmat(data_mean, size(data, 1), 1);
data = data ./ repmat(data_std, size(data, 1), 1);

fprintf(1, 'Training RBM');
params = init_rbm(size(data, 1), size(data, 2), options);   
data = data(:, 1:(params.numBatch*params.batchSize));
data = reshape(data, params.inputSize, params.batchSize, params.numBatch);
[params, rbmModel, runtimeParams] = runRBM(data, params, 'log.txt');

data = reshape(data, params.inputSize, params.batchSize * params.numBatch);
recon = feedForwardRBM(data, rbmModel);
options.fl.rbm.type = 'binary';
params2 = init_rbm(size(recon, 1), size(recon, 2), options);
recon = reshape(recon, params2.inputSize, params2.batchSize, params2.numBatch);
[params2, rbmModel2, runtimeParams2] = runRBM(recon, params2, 'log2.txt');

recon = reshape(recon, params2.inputSize, params2.batchSize * params2.numBatch);
recon2 = feedForwardRBM(recon, rbmModel2);
options.fl.rbm.hidden_layer = 128;
params3 = init_rbm(size(recon2, 1), size(recon2, 2), options);
recon2 = reshape(recon2, params3.inputSize, params3.batchSize, params3.numBatch);
[params3, rbmModel3, runtimeParams3] = runRBM(recon2, params3, 'log3.txt');