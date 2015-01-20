clear all; close all; clc;

path = 'D:\Data\NewsData\word_freq\';
D = dir(path);

fid = fopen([path D(3).name]);
C = textscan(fid, '%s\t%s');
wordSize = length(C{1});
fclose(fid);

bowMatrix = zeros(wordSize, length(D) - 2);

for i = 3:length(D)
    fid = fopen([path D(i).name]);
    C = textscan(fid, '%s\t%s');
    dictionary = C{1};
    fclose(fid);
    
    tmp = str2double(C{2});
    bowMatrix(:, i - 2) = tmp / sum(tmp);
end

tfIdf = zeros(size(bowMatrix, 1), size(bowMatrix, 2));

for i = 1:size(bowMatrix, 1)
    idf = log((length(D) - 2) / (sum(bowMatrix(i, :) ~= 0)));
    tfIdf(i, :) = bowMatrix(i, :) * idf;
end