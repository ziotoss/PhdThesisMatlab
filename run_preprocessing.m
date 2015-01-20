function preprocessed_data = run_preprocessing(data, options)

    if strcmp(options.data.preprocess.type, 'tf-idf')
        preprocessed_data = preprocessing_tfidf(data);
    end

end