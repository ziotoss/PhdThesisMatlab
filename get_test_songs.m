function processed_songs = get_test_songs(scratch, options)

    if ~exist([scratch filesep 'test_songs_wlimit_' num2str(options.keyword.word_count_limit) ...
                                         '_elimit_' num2str(options.keyword.doc_length_limit) '.mat'], 'file');
        hts_folder = '_hts_preprocessed';
        file_path = 'D:\Data\Keyword\TestSongs';

        D = dir(file_path);
        D(1:2) = [];
        processed_songs = struct;
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
                if fid ~= -1
                    C = textscan(fid, '%s%s%s', 'delimiter', ':');
                    fclose(fid);

                    hts_types = C{2};
                    hts_words = C{3};

                    neglect_idx = [];
                    neglect_idx = [neglect_idx; find(strcmp(hts_types, '%') == 1)];
                    neglect_idx = [neglect_idx; find(strcmp(hts_types, '*') == 1)];
                    neglect_idx = [neglect_idx; find(strcmp(hts_types, '1') == 1)];
                    neglect_idx = [neglect_idx; find(strcmp(hts_types, '@') == 1)];
                    neglect_idx = [neglect_idx; find(strcmp(hts_types, 'A') == 1)];

                    hts_types(neglect_idx) = [];
                    hts_words(neglect_idx) = [];
                    if length(hts_words) >= options.keyword.doc_length_limit
                        test_songs(i).episodes(j).hts_file = hts_file;
                        test_songs(i).episodes(j).content_hts = hts_words;
                        test_songs(i).episodes(j).content_hts_type = hts_types;
                        vocabs = [vocabs; hts_words];
                    end
                end
            end
            test_songs(i).dictionary = unique(vocabs);
        end

        % Remove empty episodes
        for i = 1 : length(test_songs)
            removeIdx = zeros(1, length(test_songs(i).episodes));
            for j = 1 : length(test_songs(i).episodes)
                if isempty(test_songs(i).episodes(j).hts_file)
                    removeIdx(j) = 1;
                end
            end
            test_songs(i).episodes(boolean(removeIdx)) = [];

        end
        time_elapsed = toc(start_time);
        fprintf(1, ' Done. Time elapsed is %.2f seconds.\n', time_elapsed);
                
        partition_num = length(test_songs);
        % Create an overall dictionary
        clear start_time time_elapsed;
        start_time = tic;
        fprintf(1, 'Creating an overall unique dictionary.');
        dictionary = [];
        episode_count = 0;
        for i = 1:partition_num
            dictionary = [dictionary;test_songs(i).dictionary];
            episode_count = episode_count + length(test_songs(i).episodes);
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
        remove_idx = sum(occ_mat, 1) <= options.keyword.word_count_limit;
        dictionary(remove_idx) = [];
        occ_mat(:, remove_idx) = [];
        
        empty_idx = find(strcmp(dictionary, ''));
        dictionary(empty_idx) = [];
        occ_mat(:,empty_idx) = [];
        
        processed_songs.test_songs = test_songs;
        processed_songs.occ_mat = occ_mat;
        processed_songs.dictionary = dictionary;
        processed_songs.partition_num = partition_num;
        processed_songs.episode_count = episode_count;
        time_elapsed = toc(start_time);
        save([scratch filesep 'test_songs_wlimit_' num2str(options.keyword.word_count_limit) ...
                                        '_elimit_' num2str(options.keyword.doc_length_limit) '.mat'], 'processed_songs');
        fprintf(1, ' Done. Time elapsed is %.2f seconds.\n', time_elapsed);
    else
        start_time = tic;
        fprintf(1, 'Loading test_songs file.\n');
        load([scratch filesep 'test_songs_wlimit_' num2str(options.keyword.word_count_limit) ...
                                        '_elimit_' num2str(options.keyword.doc_length_limit) '.mat']);
        time_elapsed = toc(start_time);
        fprintf(1, ' Done. Time elapsed is %.2f seconds.\n', time_elapsed);
    end

end