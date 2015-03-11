function run_keyword_extraction(scratch)

    methods = {'tfidf', 'shannon', 'hybrid'};
    tfidf_methods = {'full', 'document'};
    
    for i = 1:length(methods)
        if strcmp(methods{i}, 'tfidf')
            for j = 1:length(tfidf_methods)
                keyword_options;
                options.keyword.method = methods{i};
                options.keyword.tfidf.method = tfidf_methods{j};
                processed_songs = get_test_songs(scratch, options);
                results = extract_keyword_overall(scratch, processed_songs, options);
                ftr_result = extract_keyword_feature(scratch, processed_songs, results, options);
                get_keyword_figures(scratch, ftr_result, options);
            end
        else
            keyword_options;
            options.keyword.method = methods{i};
            processed_songs = get_test_songs(scratch, options);
            results = extract_keyword_overall(scratch, processed_songs, options);
            ftr_result = extract_keyword_feature(scratch, processed_songs, results, options);
            get_keyword_figures(scratch, ftr_result, options);
        end
    end
    
end