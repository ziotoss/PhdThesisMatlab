function extract_keyword_overall(scratch, doc_length_limit, mean_divider)
% function extract_keyword_per_song
%
%   Input:
%       scratch - scratch folder path
%       partition_nums - number of partitions (i.e. P value of Shannon's Entropy)
%                        Takes single value or multiple values in a vector form.
%       mean_divider - variable to divide minimum word limit.
%                      (Default value is 1)

    if nargin < 2
        doc_length_limit = 50;
        mean_divider = 2;
    end

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

            fid = fopen(hts_file);
            C = textscan(fid, '%s%s%s', 'delimiter', ':');
            fclose(fid);

            % ToDo: Remove episodes that have less than word_limit words.
            hts_types = C{2};
            hts_words = C{3};
            contentIdx = strcmp(hts_words, 'CONTENT');
            contentIdx = find(contentIdx == 1);
            hts_types = hts_types(contentIdx + 1:end);
            hts_words = hts_words(contentIdx + 1:end);
            neglect_idx = [];
            neglect_idx = [neglect_idx; find(strcmp(hts_types, '%') == 1)];
            neglect_idx = [neglect_idx; find(strcmp(hts_types, '*') == 1)];
            neglect_idx = [neglect_idx; find(strcmp(hts_types, '1') == 1)];
            neglect_idx = [neglect_idx; find(strcmp(hts_types, '@') == 1)];
            neglect_idx = [neglect_idx; find(strcmp(hts_types, 'K') == 1)];

            hts_types(neglect_idx) = [];
            hts_words(neglect_idx) = [];
            if length(hts_words) >= doc_length_limit
                test_songs(i).episodes(j).hts_file = hts_file;
                test_songs(i).episodes(j).content_hts = hts_words;
                test_songs(i).episodes(j).content_hts_type = hts_types;
                vocabs = [vocabs; hts_words];
            end
        end
        test_songs(i).dictionary = unique(vocabs);
    end
    time_elapsed = toc(start_time);
    fprintf(1, ' Done. Time elapsed is %.2f seconds.\n', time_elapsed);

    partition_num = length(test_songs);
    save([scratch filesep 'overall_test_songs_ln_partition_' num2str(partition_num) '.mat'], 'test_songs');

    % Create an overall dictionary
    clear start_time time_elapsed;
    start_time = tic;
    fprintf(1, 'Creating an overall unique dictionary.');
    dictionary = [];
    overall_episodes = 0;
    for i = 1:partition_num
        dictionary = [dictionary;test_songs(i).dictionary];
        overall_episodes = overall_episodes + length(test_songs(i).episodes);
    end
    dictionary = unique(dictionary);
    time_elapsed = toc(start_time);
    fprintf(1, ' Done. Time elapsed is %.2f seconds.\n', time_elapsed);
    
    % Create an overall occurrence matrix
    clear start_time time_elapsed;
    start_time = tic;
    occ_mat = zeros(partition_num, length(dictionary));
    fprintf(1, 'Creating the occurrence matrix using the unique dictionary.');
    for i = 1:partition_num
        for j = 1:length(test_songs(i).episodes)
            words = test_songs(i).episodes(j).content_hts;
            for k = 1:length(words)
                idx = find(strcmp(dictionary, words{k}) == 1);
                occ_mat(i, idx) = occ_mat(i, idx) + 1;
            end
        end
    end

    % Remove words that occur less than average per word occurrence.
    total_words = sum(sum(occ_mat));
    average_word_occ = floor(total_words / overall_episodes);
    average_word_occ = floor(average_word_occ / mean_divider);
    remove_idx = sum(occ_mat, 1) <= average_word_occ;
    dictionary(remove_idx) = [];
    occ_mat(:, remove_idx) = [];
    time_elapsed = toc(start_time);
    fprintf(1, ' Done. Time elapsed is %.2f seconds.\n', time_elapsed);
    
    % Calculate Shannon's entropy
    clear start_time time_elapsed;
    start_time = tic;
    fprintf(1, 'Calculating Shannons Entropy.');
    n_w = sum(occ_mat, 1);
    Ni = sum(occ_mat, 2);
    fi_w = occ_mat ./ repmat(Ni, 1, size(occ_mat, 2));
    fi_w_sum = sum(fi_w, 1);
    p_w = fi_w ./ repmat(fi_w_sum, size(occ_mat, 1), 1);
    S_w_tmp = sum(p_w .* log2(p_w + eps), 1);
    S_w = (-1 / log2(partition_num)) * S_w_tmp;
    S_ran = 1 - ((partition_num - 1) ./ (2 * n_w * log2(partition_num)));
    E_w = (1 - S_w) ./ (1 - S_ran);
    
    results.dictionary = dictionary;
    results.occ_mat = occ_mat;
    results.E_w = E_w;
    save([scratch filesep 'overall_test_songs_ln_result.mat'], 'results');
    time_elapsed = toc(start_time);
    fprintf(1, ' Done. Time elapsed is %.2f seconds.\n', time_elapsed);
end
    
    
    
    