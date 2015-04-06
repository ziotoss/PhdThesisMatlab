function ftr_result = extract_keyword_feature(scratch, processed_songs, results, options)

    if strcmp(options.keyword.ftr.method, 'individual')
        
    elseif strcmp(options.keyword.ftr.method, 'song')
        word_importance = results.occ_mat .* repmat(results.E_w, size(results.occ_mat, 1), 1);
        test_songs = processed_songs.test_songs;
        
        start_time = tic;
        fprintf(1, 'Extracting keywords from each songs.\n');
        features = struct;
        for i = 1 : length(test_songs)
            [sorted_word, sorted_idx] = sort(word_importance(i, :), 'descend');
            keywords = processed_songs.dictionary(sorted_idx);
            keywords = keywords(1:options.keyword.num_keywords);
            
            features(i).song_artist = test_songs(i).song_artist;
            features(i).song_title = test_songs(i).song_title;
            features(i).feature_vector = sorted_word(1:options.keyword.num_keywords);
            features(i).keywords = keywords;
        end
        ftr_result.features = features;
        ftr_result.word_importance = word_importance;
        
    elseif strcmp(options.keyword.ftr.method, 'global')
        [sorted_e_w, sorted_idx] = sort(results.E_w, 'descend');
        keywords = processed_songs.dictionary(sorted_idx);
        keywords = keywords(1:options.keyword.num_keywords);
        test_songs = processed_songs.test_songs;

        start_time = tic;
        fprintf(1, 'Extracting keywords using global keywords.\n');
        features = struct;
        for i = 1 : length(test_songs)
            episodes = test_songs(i).episodes;
            feature_vector = zeros(1, length(keywords));

            hts = [];
            for j = 1:length(episodes)
                hts = [hts; episodes(j).content_hts];
            end

            for j = 1 : length(hts)
               idx = find(strcmp(keywords, hts(j)));
                if ~isempty(idx)
                    feature_vector(idx) = feature_vector(idx) + 1;
                end
            end

            features(i).song_artist = test_songs(i).song_artist;
            features(i).song_title = test_songs(i).song_title;
            features(i).song_ftr = feature_vector;
        end
        ftr_result.features = features;
        ftr_result.sorted_e_w = sorted_e_w;
        ftr_result.keywords = keywords;
        
    else
        fprintf(1, 'Invalid feature extraction method. Should be either song or global.\n');
        return;
    end
    time_elapsed = toc(start_time);
    if strcmp(options.keyword.method, 'tfidf') || strcmp(options.keyword.method, 'hybrid')
        save([scratch filesep 'keyword_' options.keyword.method '_' options.keyword.tfidf.method '_ftr_' options.keyword.ftr.method '.mat'], 'ftr_result');
    else
        save([scratch filesep 'keyword_' options.keyword.method '_ftr_' options.keyword.ftr.method '.mat'], 'ftr_result');
    end
    fprintf(1, ' Done. Time elapsed is %.2f seconds.\n', time_elapsed);
end