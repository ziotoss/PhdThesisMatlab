function ftr_result = extract_keyword_feature(scratch, processed_songs, results, options)

    [sorted_e_w, sorted_idx] = sort(results.E_w, 'descend');
    keywords = processed_songs.dictionary(sorted_idx);
    keywords = keywords(1:options.keyword.num_keywords);
    test_songs = processed_songs.test_songs;
    
    start_time = tic;
    fprintf(1, 'Accumulating keyword occurrence for each song.');
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
    
    time_elapsed = toc(start_time);
    if strcmp(options.keyword.method, 'tfidf')
        save([scratch filesep 'test_songs_' options.keyword.method '_' options.keyword.tfidf.method '_ftr.mat'], 'ftr_result');
    else
        save([scratch filesep 'test_songs_' options.keyword.method '_ftr.mat'], 'ftr_result');
    end
    fprintf(1, ' Done. Time elapsed is %.2f seconds.\n', time_elapsed);
end