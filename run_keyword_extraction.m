function run_keyword_extraction(scratch)

    methods = {'tfidf', 'shannon', 'hybrid'};
    tfidf_methods = {'document', 'song'};
    ftr_methods = {'song', 'global'};
    
    if ~exist(scratch, 'dir')
        mkdir(scratch)
    end

    keyword_options;
    processed_songs = get_test_songs(scratch, options);
    
    for i = 1:length(methods)
        if strcmp(methods{i}, 'tfidf') || strcmp(methods{i}, 'hybrid')
            for j = 1:length(tfidf_methods)
                for k = 1:length(ftr_methods)
                    keyword_options;
                    options.keyword.method = methods{i};
                    options.keyword.tfidf.method = tfidf_methods{j};
                    options.keyword.ftr.method = ftr_methods{k};
                    results = extract_keyword_overall(scratch, processed_songs, options);
                    ftr_result = extract_keyword_feature(scratch, processed_songs, results, options);
                    get_keyword_figures(scratch, ftr_result, options);
                end
            end
        else
            for j = 1:length(ftr_methods)
                keyword_options;
                options.keyword.method = methods{i};
                options.keyword.ftr.method = ftr_methods{j};
                results = extract_keyword_overall(scratch, processed_songs, options);
                ftr_result = extract_keyword_feature(scratch, processed_songs, results, options);
                get_keyword_figures(scratch, ftr_result, options);
            end
        end
    end
    
end