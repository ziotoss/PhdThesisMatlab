clear all;close all;clc;

hts_folder = '_hts';
file_path = 'D:\Data\Keyword\TestSongs';

D = dir(file_path);
D(1:2) = [];
test_songs = struct;

for i = 1 : length(D)
    vocabs = [];
    fid = fopen([file_path filesep D(i).name]);
    C = textscan(fid, '%s', 'delimiter', '');
    fclose(fid);

    song_info = strsplit(D(i).name, '_');
    song_artist = song_info{1};
    song_title = song_info{2};
    song_title = song_title(1:end - 4);
    test_songs(i).song_artist = song_artist;
    test_songs(i).song_title = song_title;
    test_songs(i).episodes = struct;

    song_files = C{1};
    for j = 1 : length(song_files)
        tmp = strsplit(song_files{j}, '\\');
        hts_file = [tmp{1} filesep tmp{2} filesep tmp{3} filesep tmp{4} hts_folder filesep tmp{5}];
        test_songs(i).episodes(j).hts_file = hts_file;
        
        fid = fopen(hts_file);
        C = textscan(fid, '%s%s%s', 'delimiter', ':');
        fclose(fid);

        hts_types = C{2};
        hts_words = C{3};
        contentIdx = strfind(hts_words, 'CONTENT');
        contentIdx = find(cellfun(@(x) ~isempty(x), contentIdx) == 1);
        hts_types = hts_types(contentIdx + 1:end);
        hts_words = hts_words(contentIdx + 1:end);
        neglect_idx = [];
        neglect_idx = [neglect_idx; find(cellfun(@(x) ~isempty(x), strfind(hts_types, '%')) == 1)];
        neglect_idx = [neglect_idx; find(cellfun(@(x) ~isempty(x), strfind(hts_types, '*')) == 1)];
        neglect_idx = [neglect_idx; find(cellfun(@(x) ~isempty(x), strfind(hts_types, '1')) == 1)];
        neglect_idx = [neglect_idx; find(cellfun(@(x) ~isempty(x), strfind(hts_types, '@')) == 1)];
        neglect_idx = [neglect_idx; find(cellfun(@(x) ~isempty(x), strfind(hts_types, 'K')) == 1)];
        
        hts_types(neglect_idx) = [];
        hts_words(neglect_idx) = [];
        
        test_songs(i).episodes(j).content_hts = hts_words;
        test_songs(i).episodes(j).content_hts_type = hts_types;
        vocabs = [vocabs; hts_words];
    end
    test_songs(i).dictionary = unique(vocabs);
end

% Create unique dictionary
% dictionary = unique(vocabs);
% occ_mat = zeros(length(test_songs), length(dictionary));

% Create an occurrence matrix for each test song
fprintf(1, 'Creating the occurrence matrix using the unique dictionary.');
partitions = 10;
for i = 1:length(test_songs)
    occ_mat = zeros(length(test_songs(i).episodes), length(test_songs(i).dictionary));
    for j = 1:length(test_songs(i).episodes)
        words = test_songs(i).episodes(j).content_hts;
        for k = 1:length(words)
            idx = find(cellfun(@(x) ~isempty(x), strfind(test_songs(i).dictionary, words{k})) == 1);
            occ_mat(j, idx) = occ_mat(j, idx) + 1;
        end
    end
    
    occ_mat_partition = zeros(partitions, length(test_songs(i).dictionary));
    num_episodes_per_partition = floor(length(test_songs(i).episodes) / partitions);
    for j = 1 : partitions
        start_idx = (j - 1) * num_episodes_per_partition + 1;
        end_idx = j * num_episodes_per_partition;
        occ_tmp = sum(occ_mat(start_idx:end_idx, :));
        occ_mat_partition(j, :) = occ_tmp;
    end
    
    test_songs(i).occ_mat = occ_mat_partition;
    test_songs(i).num_partitions = partitions;
end

%% Calculate Shannon's entropy
fprintf(1, 'Calculating Shannons entropy.\n');
for i = 1 : length(test_songs)
    partition_num = test_songs(i).num_partitions;
    occ_mat = test_songs(i).occ_mat;
    occ_mat_sum = sum(occ_mat, 1);
    p_w = occ_mat ./ repmat(occ_mat_sum, size(occ_mat, 1), 1);
    S_w_tmp = sum(p_w .* log(p_w + eps), 1);
    S_w = (-1 / log(partition_num)) * S_w_tmp;
    S_ran = 1 - ((partition_num - 1) ./ (2 * occ_mat_sum * log(partition_num)));
    E_w = (1 - S_w) ./ (1 - S_ran);
    test_songs(i).entropy = E_w;
end