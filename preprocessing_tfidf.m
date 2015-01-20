function tfidf = preprocessing_tfidf(data)

    tfidf = zeros(size(data, 1), size(data, 2));

    for i = 1:size(data, 1)
        idf = log((length(D) - 2) / (sum(data(i, :) ~= 0)));
        tfidf(i, :) = data(i, :) * idf;
    end

end