function evaluation_songs = get_evaluation_data(scratch);
    
    load([scratch filesep 'top_20_hybrid_song_ftr_global.mat']);
    hybrid_global = fig_data;
    load([scratch filesep 'top_20_hybrid_song_ftr_song.mat']);
    hybrid_song = fig_data;
    load([scratch filesep 'top_20_shannon_ftr_global.mat']);
    shannon_global = fig_data;
    load([scratch filesep 'top_20_shannon_ftr_song.mat']);
    shannon_song = fig_data;
    load([scratch filesep 'top_20_tfidf_song_ftr_global.mat']);
    tfidf_global = fig_data;
    load([scratch filesep 'top_20_tfidf_song_ftr_song.mat']);
    tfidf_song = fig_data;
    
    load([scratch filesep 'test_songs_wlimit_20_elimit_20.mat']);
    
    epi_size = zeros(1, length(processed_songs.test_songs));
    for i = 1:length(processed_songs.test_songs)
        epi_size(i) = length(processed_songs.test_songs(i).episodes);
    end
    
    [sorted_size, sorted_idx] = sort(epi_size, 'descend');
    
    evaluation_songs = struct;
    for i = 1:length(processed_songs.test_songs)
        evaluation_songs(i).norm_epi_size = sorted_size(i);
        evaluation_songs(i).song_info = [processed_songs.test_songs(sorted_idx(i)).song_artist ' - ' processed_songs.test_songs(sorted_idx(i)).song_title];
        evaluation_songs(i).tfidf_song = tfidf_song(sorted_idx(i)).top_n_keywords;
        evaluation_songs(i).tfidf_global = tfidf_global(sorted_idx(i)).top_n_keywords;
        evaluation_songs(i).shannon_song = shannon_song(sorted_idx(i)).top_n_keywords;
        evaluation_songs(i).shannon_global = shannon_global(sorted_idx(i)).top_n_keywords;
        evaluation_songs(i).hybrid_song = hybrid_song(sorted_idx(i)).top_n_keywords;
        evaluation_songs(i).hybrid_global = hybrid_global(sorted_idx(i)).top_n_keywords;
    end
    
    save([scratch filesep 'evaluation_song_data.mat'], 'evaluation_songs');
end