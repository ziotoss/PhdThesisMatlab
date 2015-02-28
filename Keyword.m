clear all;close all;clc;

hts_folder = '_hts';
file_path = 'D:\Data\Keyword\TestSongs';

D = dir(file_path);
D(1:2) = [];
test_songs = struct;

start_time = tic;
fprintf(1, 'Gathering song information.');
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
time_elapsed = toc(start_time);
fprintf(1, ' Done. Time elapsed is %.2f seconds.\n', time_elapsed);

% Create an occurrence matrix for each test song
clear start_time time_elapsed;
start_time = tic;
partition_nums = [3 5 10 25 50 100];
mean_divider = 2;
fprintf(1, 'Creating the occurrence matrix using the unique dictionary.');
for partition_num = partition_nums
    for i = 1:length(test_songs)
        episodes_per_partition = floor(length(test_songs(i).episodes) / partition_num);
        test_songs(i).occ_mat = zeros(partition_num, length(test_songs(i).dictionary));
        rand_idx = randperm(length(test_songs(i).episodes));
        for j = 1:partition_num %length(test_songs(i).episodes)
            partition_rand_idx = rand_idx((j - 1) * episodes_per_partition + 1:j * episodes_per_partition);
            for k = partition_rand_idx
                words = test_songs(i).episodes(k).content_hts;
                for m = 1:length(words)
                    idx = find(cellfun(@(x) ~isempty(x), strfind(test_songs(i).dictionary, words{m})) == 1);
                    test_songs(i).occ_mat(j, idx) = test_songs(i).occ_mat(j, idx) + 1;
                end
            end
        end

        % Remove words that occur less than average per word occurrence.
        average_word_occ = floor(sum(test_songs(i).occ_mat, 1) / size(test_songs(i).occ_mat, 2));
        average_word_occ = floor(average_word_occ / mean_divider);
        remove_idx = sum(test_songs(i).occ_mat, 1) <= average_word_occ;
        test_songs(i).dictionary(remove_idx) = [];
        test_songs(i).occ_mat(:, remove_idx) = [];

        % Calculate Shannon's entropy
        occ_mat_sum = sum(test_songs(i).occ_mat, 1);
        p_w = test_songs(i).occ_mat ./ repmat(occ_mat_sum, size(test_songs(i).occ_mat, 1), 1);
        S_w_tmp = sum(p_w .* log2(p_w + eps), 1);
        S_w = (-1 / log2(partition_num)) * S_w_tmp;
        S_ran = 1 - ((partition_num - 1) ./ (2 * occ_mat_sum * log2(partition_num)));
        test_songs(i).E_w = (1 - S_w) ./ (1 - S_ran);
    end
    save(['scratch\test_songs_partition_' num2str(partition_num) '.mat'], 'test_songs');
end
time_elapsed = toc(start_time);
fprintf(1, ' Done. Time elapsed is %.2f seconds.\n', time_elapsed);