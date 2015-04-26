clear all;close all;clc;

load('150420_scratch\processed_user_eval.mat');
result = struct;

for songs = 1:length(processed_result)
    tfidf = processed_result(songs).tfidf_keywords;
    shannon = processed_result(songs).shannon_keywords;

    keyword_count = processed_result(songs).keyword_count;
    keyword_list = processed_result(songs).keyword_list;

    [sorted_count, idx] = sort(keyword_count, 'descend');
    over_5 = sorted_count >= 5;
    idx = idx(over_5);

    sorted_keywords = keyword_list(idx);

    tfidf_precision = zeros(1, length(tfidf));
    tfidf_recall = zeros(1, length(tfidf));
    shannon_precision = zeros(1, length(shannon));
    shannon_recall = zeros(1, length(shannon));

    exist_idx = [];
    for i = 1:length(sorted_keywords)
        exist_idx = [exist_idx, find(strcmp(tfidf, sorted_keywords{i}))];
    end

    tfidf_location = zeros(1, length(tfidf));
    tfidf_location(exist_idx) = 1;

    for i = 1:length(tfidf_precision)
        tfidf_precision(i) = sum(tfidf_location(1:i)) / i;
        tfidf_recall(i) = sum(tfidf_location(1:i)) / length(sorted_keywords);
    end

    exist_idx = [];
    for i = 1:length(sorted_keywords)
        exist_idx = [exist_idx, find(strcmp(shannon, sorted_keywords{i}))];
    end

    shannon_location = zeros(1, length(shannon));
    shannon_location(exist_idx) = 1;

    for i = 1:length(shannon_precision)
        shannon_precision(i) = sum(shannon_location(1:i)) / i;
        shannon_recall(i) = sum(shannon_location(1:i)) / length(sorted_keywords);
    end
    result(songs).tfidf_p = tfidf_precision;
    result(songs).tfidf_r = tfidf_recall;
    result(songs).shannon_p = shannon_precision;
    result(songs).shannon_r = shannon_recall;
end

f = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
for i = 1:length(result)
    subplot(5,2,i);
    plot(result(i).tfidf_r, result(i).tfidf_p, 'o-');hold on;plot(result(i).shannon_r, result(i).shannon_p, 'r-*');
    ylim([0 1.1]);title(['S_{' num2str(i) '}']);xlabel('recall');ylabel('precision');
    if i == 1
        legend('tf-idf', 'shannon');
    end
end
set(findall(gcf, 'type', 'text'), 'FontSize', 18, 'FontName', 'Times New Roman');
f = tightfig(f);
saveas(f, 'figures\user_eval_prec_rec.png');

tfidf_p_avg = zeros(length(result), 20);
tfidf_r_avg = zeros(length(result), 20);
shannon_p_avg = zeros(length(result), 20);
shannon_r_avg = zeros(length(result), 20);

for i = 1:length(result)
    tfidf_p_avg(i,:) = result(i).tfidf_p;
    tfidf_r_avg(i,:) = result(i).tfidf_r;
    shannon_p_avg(i,:) = result(i).shannon_p;
    shannon_r_avg(i,:) = result(i).shannon_r;
end

tfidf_p_avg = mean(tfidf_p_avg, 1);
tfidf_r_avg = mean(tfidf_r_avg, 1);
shannon_p_avg = mean(shannon_p_avg, 1);
shannon_r_avg = mean(shannon_r_avg, 1);

figure;plot(tfidf_r_avg, tfidf_p_avg, 'o-');hold on;plot(shannon_r_avg, shannon_p_avg, 'r-*');