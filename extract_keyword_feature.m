function extract_keyword_feature(keyword_reslt_file, keyword_test_songs_file, num_keywords)

    result = load(['scratch' filesep keyword_reslt_file '.mat']);
    songs = load(['scratch' filesep keyword_test_songs_file '.mat']);
    
    [sorted_e_w, sorted_idx] = sort(result.results.E_w, 'descend');
    keywords = result.results.dictionary(sorted_idx);
    keywords = keywords(1:num_keywords);

    start_time = tic;
    fprintf(1, 'Accumulating keyword occurrence for each song.');
    features = struct;
    for i = 1 : length(songs.test_songs)
        episodes = songs.test_songs(i).episodes;
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
        
        features(i).song_artist = songs.test_songs(i).song_artist;
        features(i).song_title = songs.test_songs(i).song_title;
        features(i).song_ftr = feature_vector;
    end
    result.features = features;
    result.sorted_e_w = sorted_e_w;
    result.keywords = keywords;
    
    time_elapsed = toc(start_time);
    save('scratch\overall_test_songs_20_ftr.mat', 'result');
    fprintf(1, ' Done. Time elapsed is %.2f seconds.\n', time_elapsed);
end