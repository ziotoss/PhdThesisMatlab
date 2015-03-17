load(['scratch' filesep 'test_songs_tfidf_document_result.mat']);
load(['scratch' filesep 'test_songs_tfidf_document_ftr.mat']);

tf = results.tf;
dictionary = results.dictionary;
keywords = ftr_result.keywords;

tf_examine = zeros(size(tf, 1), 300);

for i = 1:length(keywords)
    idx = find(strcmp(dictionary, keywords{i}));
    tf_examine(:, i) = tf(:, idx);
end

for i = 1:12
    figure;
    for j = 1:5
        for k = 1:5
            subplot(5, 5, 5 * (j - 1) + k);bar(tf_examine(:, 25 * (i - 1) + 5 * (j - 1) + k));title(keywords{25 * (i - 1) + 5 * (j - 1) + k});
        end
    end
end
    