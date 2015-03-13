options.keyword.doc_length_limit = 20;
options.keyword.word_count_limit = 20;
options.keyword.num_keywords = 300;
options.keyword.top_n = 20;
options.keyword.method = 'tfidf'; % 'tfidf', 'shannon', 'hybrid'
options.keyword.tfidf.method = 'document'; % 'full', 'cluster', 'document'