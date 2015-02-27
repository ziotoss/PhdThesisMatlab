function result = get_keyword_result(test_song_file_name, top_n)

    load(['scratch' filesep test_song_file_name '.mat']);
    result = struct;
    for i = 1:length(test_songs);
        dic = test_songs(i).dictionary;
        e_w = test_songs(i).E_w;
        
        [sorted_e_w, sorted_idx] = sort(e_w, 'descend');

        result(i).song_artist = test_song(i).song_artist;
        result(i).song_title = test_song(i).song_title;
        result(i).top_n = top_n;
        result(i).sorted_dic = dic(sorted_idx(1:top_n));
        result(i).sorted_e_w = sorted_e_w(1:top_n);
    end
end