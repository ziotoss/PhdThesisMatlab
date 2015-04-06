function results = extract_keyword_overall(scratch, processed_songs, options)
% function extract_keyword_per_song
%
%   Input:
%       scratch - scratch folder path
%       partition_nums - number of partitions (i.e. P value of Shannon's Entropy)
%                        Takes single value or multiple values in a vector form.
%       mean_divider - variable to divide minimum word limit.
%                      (Default value is 1)

    test_songs = processed_songs.test_songs;
    partition_num = processed_songs.partition_num;
    occ_mat = processed_songs.occ_mat;
    dictionary = processed_songs.dictionary;
    episode_count = processed_songs.episode_count;
    
    clear start_time time_elapsed;
    start_time = tic;
    if strcmp(options.keyword.method, 'tfidf')
        fprintf(1, ['Estimating keyword using ' options.keyword.method '(' options.keyword.tfidf.method ') method.\n']);
    else
        fprintf(1, ['Estimating keyword using ' options.keyword.method ' method.\n']);
    end
        
    % Methods to normalize E_norm(w). (tfidf, original, etc);
    if strcmp(options.keyword.method, 'tfidf')
        
        if strcmp(options.keyword.tfidf.method, 'document')
            tf = zeros(episode_count, length(dictionary));
            idf = zeros(1, length(dictionary));
            episodes = [];
            for i = 1:length(test_songs)
                episodes = [episodes, test_songs(i).episodes];
            end
             
            for i = 1:length(episodes)
                for j = 1:length(dictionary)
                    if ~isempty(find(strcmp(episodes(i).content_hts, dictionary{j}) == 1, 1))
                        tf(i, j) = tf(i, j) + length(find(strcmp(episodes(i).content_hts, dictionary{j}) == 1));
                        idf(j) = idf(j) + 1;
                    end
                end
            end

            doc_count = idf;
            idf = log(episode_count ./ idf);
            tf_norm = tf ./ repmat(sum(tf, 2), 1, size(tf, 2));
            tfidf = tf_norm .* repmat(idf, size(tf_norm, 1), 1);
            results.doc_count = doc_count;
            results.tf = tf;
            results.tf_norm = tf_norm;
            results.idf = idf;
            results.tfidf = tfidf;
            results.E_w = mean(tfidf);
            
        elseif strcmp(options.keyword.tfidf.method, 'song')
            tf = occ_mat;
            tf_norm = tf ./ repmat(sum(tf, 2), 1, size(tf, 2));
            doc_count = sum(occ_mat ~= 0, 1);
            idf = log(episode_count ./ doc_count);
            tfidf = tf_norm .* repmat(idf, size(tf_norm, 1), 1);
            results.doc_count = doc_count;
            results.tf = tf;
            results.tf_norm = tf_norm;
            results.idf = idf;
            results.tfidf = tfidf;
            results.E_w = mean(tfidf);
        
        elseif strcmp(options.keyword.tfidf.method, 'full') % Need validation of this approach
            tf = sum(occ_mat, 1);
            idf = zeros(1, length(dictionary));
            for i = 1:length(dictionary)
                count = 0;
                for j = 1:length(test_songs)
                    for k = 1:length(test_songs(j).episodes)
                        if ~isempty(find(strcmp(test_songs(j).episodes(k).content_hts, dictionary(i)) == 1, 1))
                            count = count + 1;
                        end
                    end
                end
                idf(i) = count;
            end
            idf = log(episode_count ./ idf);
            tf_norm = tf ./ repmat(sum(tf, 2), 1, size(tf, 2));
            E_w = tf_norm .* idf;
            results.tf = tf;
            results.tf_norm = tf_norm;
            results.idf = idf;
            results.E_w = E_w;

        else
            fprintf(1, 'Invalid tf-idf method. Check options.keyword.tfidf.method.\n');
            return;
        end

    elseif strcmp(options.keyword.method, 'shannon')
        n_w = sum(occ_mat, 1);
        Ni = sum(occ_mat, 2);
        fi_w = occ_mat ./ repmat(Ni, 1, size(occ_mat, 2));
        fi_w_sum = sum(fi_w, 1);
        p_w = fi_w ./ repmat(fi_w_sum, size(occ_mat, 1), 1);
        S_w_tmp = sum(p_w .* log2(p_w + eps), 1);
        S_w = (-1 / log2(partition_num)) * S_w_tmp;
        S_ran = 1 - ((partition_num - 1) ./ (2 * n_w * log2(partition_num)));
        E_w = (1 - S_w) ./ (1 - S_ran);
        results.p_w = p_w;
        results.S_w = S_w;
        results.E_w = E_w;

    elseif strcmp(options.keyword.method, 'hybrid')
        %n_w = sum(occ_mat, 1);
        Ni = sum(occ_mat, 2);
        fi_w = occ_mat ./ repmat(Ni, 1, size(occ_mat, 2));
        fi_w_sum = sum(fi_w, 1);
        p_w = fi_w ./ repmat(fi_w_sum, size(occ_mat, 1), 1);
        S_w_tmp = sum(p_w .* log2(p_w + eps), 1);
        S_w = (-1 / log2(partition_num)) * S_w_tmp;

        if strcmp(options.keyword.tfidf.method, 'document')
            tf = zeros(episode_count, length(dictionary));
            idf = zeros(1, length(dictionary));
            episodes = [];
            for i = 1:length(test_songs)
                episodes = [episodes, test_songs(i).episodes];
            end

            for i = 1:length(episodes)
                for j = 1:length(dictionary)
                    if ~isempty(find(strcmp(episodes(i).content_hts, dictionary{j}) == 1, 1))
                        tf(i, j) = tf(i, j) + length(find(strcmp(episodes(i).content_hts, dictionary{j}) == 1));
                        idf(j) = idf(j) + 1;
                    end
                end
            end

            idf = log(episode_count ./ idf);
            tf_norm = tf ./ repmat(sum(tf, 2), 1, size(tf, 2));
            tfidf = tf_norm .* repmat(idf, size(tf_norm, 1), 1);
        
        elseif strcmp(options.keyword.tfidf.method, 'song')
            tf = occ_mat;
            tf_norm = tf ./ repmat(sum(tf, 2), 1, size(tf, 2));
            doc_count = sum(occ_mat ~= 0, 1);
            idf = log(episode_count ./ doc_count);
            tfidf = tf_norm .* repmat(idf, size(tf_norm, 1), 1);
        
        elseif strcmp(options.keyword.tfidf.method, 'full')
            
        else
            fprintf(1, 'Invalid tf-idf method. Should be document, song, or full.\n');
            return;
        end
        E_w = (1 - S_w) .* mean(tfidf);
        results.tf = tf;
        results.tf_norm = tf_norm;
        results.idf = idf;
        results.tfidf = tfidf;
        results.p_w = p_w;
        results.S_w = S_w;
        results.E_w = E_w;
    else
        fprintf(1, 'Irregular detection method. Check options.keyword.method.\n');
        return;
    end
    
    results.dictionary = dictionary;
    results.occ_mat = occ_mat;
    results.method = options.keyword.method;
    if strcmp(results.method, 'tfidf')
        results.tfidf_method = options.keyword.tfidf.method;
    end
    
    if strcmp(results.method, 'tfidf') || strcmp(results.method, 'hybrid')
        save([scratch filesep 'keyword_' options.keyword.method '_' options.keyword.tfidf.method '_result.mat'], 'results');
    else
        save([scratch filesep 'keyword_' options.keyword.method '_result.mat'], 'results');
    end
    time_elapsed = toc(start_time);
    fprintf(1, ' Done. Time elapsed is %.2f seconds.\n', time_elapsed);
end