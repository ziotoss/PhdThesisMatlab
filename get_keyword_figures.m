function get_keyword_figures(scratch, ftr_result, options)

    song_ftr = ftr_result.features;
    keywords = ftr_result.keywords;
    
    fig_data = struct;
    
    for i = 1:length(song_ftr)
        ftr = song_ftr(i).song_ftr;
        top_n_idx = zeros(1, options.keyword.top_n);
        for j = 1:options.keyword.top_n
            [~, idx] = max(ftr);
            ftr(idx) = 0;
            top_n_idx(j) = idx;
        end
        fig_data(i).title = [song_ftr(i).song_artist ' - ' song_ftr(i).song_title];
        fig_data(i).ftr = song_ftr(i).song_ftr;
        fig_data(i).top_n_keywords = keywords(top_n_idx);
    end

    if strcmp(options.keyword.method, 'tfidf')
        save([scratch filesep 'top_' num2str(options.keyword.top_n) '_keywords_' options.keyword.method '_' options.keyword.tfidf.method '.mat'], 'fig_data');
    else
        save([scratch filesep 'top_' num2str(options.keyword.top_n) '_keywords_' options.keyword.method '.mat'], 'fig_data');
    end
end