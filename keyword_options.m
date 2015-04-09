options.keyword.doc_length_limit = 20;
options.keyword.word_count_limit = 20;
options.keyword.num_keywords = 300;
options.keyword.top_n = 40;
options.keyword.method = 'tfidf'; % 'tfidf', 'shannon', 'hybrid'
options.keyword.tfidf.method = 'document'; % 'full', 'song', 'document'
options.keyword.ftr.method = 'song'; % song, global