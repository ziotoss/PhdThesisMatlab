function get_keyword_figures(keyword_ftr_file, top_n)

    load(['scratch' filesep keyword_ftr_file '.mat']);
    song_ftr = ftr_result.features;
    keywords = ftr_result.keywords;
    
    fig_data = struct;
    
    for i = 1:length(song_ftr)
        ftr = song_ftr(i).song_ftr;
        top_n_idx = zeros(1, top_n);
        for j = 1:top_n
            [~, idx] = max(ftr);
            ftr(idx) = 0;
            top_n_idx(j) = idx;
        end
        fig_data(i).title = [song_ftr(i).song_artist ' - ' song_ftr(i).song_title];
        fig_data(i).ftr = song_ftr(i).song_ftr;
        fig_data(i).top_n_keywords = keywords(top_n_idx);
    end

    save(['scratch' filesep 'keyword_figure.mat'], 'fig_data');
end