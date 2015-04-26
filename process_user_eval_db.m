function processed_result = process_user_eval_db(scratch, fig_flag)

    if ~exist([scratch filesep 'processed_user_eval.mat'], 'file')
        load('data\150420_user_eval_db.mat');
        processed_result = struct;

        for i = 1:10
            processed_result(i).songId = i;
            idx = strcmp(user_eval(:, 2), num2str(i));
            processed_result(i).prior_info = user_eval(idx, 3:4);
            processed_result(i).selected_keywords = user_eval(idx, 5);
            processed_result(i).input_keywords = user_eval(idx, 6:10);
            processed_result(i).user_info = user_eval(idx, 11:12);
        end

        for i = 1:10
            tmp = processed_result(i).selected_keywords;
            keywords = [];
            for j = 1:length(tmp)
                keywords = [keywords tmp{j} ', '];
            end

            tmp = strtrim(strsplit(keywords, ','));
            idx = strcmp(tmp, '');
            tmp(idx) = [];
            keywords = tmp;

            tmp = strrep(keywords, 'word', '');
            keywords_idx = sort(str2double(tmp));

            load('data\user_eval_data.mat');
            keyword_list = user_eval(i).keywords;
            keyword_list = unique(keyword_list);

            keyword_count = zeros(1, length(keyword_list));
            for j = 1:length(keyword_count)
                keyword_count(j) = sum(keywords_idx == j);
            end

            processed_result(i).keyword_list = keyword_list;
            processed_result(i).keyword_count = keyword_count;
            processed_result(i).selected_keywords_count = sum(keyword_count > 0);
            processed_result(i).selected_keywords_avg = sum(keyword_count) / size(processed_result(i).user_info, 1);
        end
        
        test_song_id = [80, 79, 89, 76, 11, 72, 38, 52, 57, 20];
        load('150408_scratch\top_40_tfidf_song_ftr_song.mat');
        for i = 1:length(test_song_id)
            tfidf_keywords = fig_data(test_song_id(i)).top_n_keywords(1:20);
            processed_result(i).title = fig_data(test_song_id(i)).title;
            processed_result(i).tfidf_keywords = tfidf_keywords;
        end

        load('150408_scratch\top_40_shannon_ftr_global.mat');
        for i = 1:length(test_song_id)
            shannon_keywords = fig_data(test_song_id(i)).top_n_keywords(1:20);
            processed_result(i).shannon_keywords = shannon_keywords;
        end

        for i = 1:length(test_song_id)
            over_5_idx = processed_result(i).keyword_count >= 5;
            over_5 = processed_result(i).keyword_list(over_5_idx);
            processed_result(i).over_5 = over_5;

            over_10_idx = processed_result(i).keyword_count >= 10;
            over_10 = processed_result(i).keyword_list(over_10_idx);
            processed_result(i).over_10 = over_10;
            
            over_15_idx = processed_result(i).keyword_count >= 15;
            over_15 = processed_result(i).keyword_list(over_15_idx);
            processed_result(i).over_15 = over_15;
            
            over_20_idx = processed_result(i).keyword_count >= 20;
            over_20 = processed_result(i).keyword_list(over_20_idx);
            processed_result(i).over_20 = over_20;
            
            over_25_idx = processed_result(i).keyword_count >= 25;
            over_25 = processed_result(i).keyword_list(over_25_idx);
            processed_result(i).over_25 = over_25;
            
            over_30_idx = processed_result(i).keyword_count >= 30;
            over_30 = processed_result(i).keyword_list(over_30_idx);
            processed_result(i).over_30 = over_30;
            
            over_35_idx = processed_result(i).keyword_count >= 35;
            over_35 = processed_result(i).keyword_list(over_35_idx);
            processed_result(i).over_35 = over_35;
            
            over_40_idx = processed_result(i).keyword_count >= 40;
            over_40 = processed_result(i).keyword_list(over_40_idx);
            processed_result(i).over_40 = over_40;
            
            over_45_idx = processed_result(i).keyword_count >= 45;
            over_45 = processed_result(i).keyword_list(over_45_idx);
            processed_result(i).over_45 = over_45;
            
            over_50_idx = processed_result(i).keyword_count >= 50;
            over_50 = processed_result(i).keyword_list(over_50_idx);
            processed_result(i).over_50 = over_50;
            
            over_55_idx = processed_result(i).keyword_count >= 55;
            over_55 = processed_result(i).keyword_list(over_55_idx);
            processed_result(i).over_55 = over_55;
            
            over_60_idx = processed_result(i).keyword_count >= 60;
            over_60 = processed_result(i).keyword_list(over_60_idx);
            processed_result(i).over_60 = over_60;
        end
        save([scratch filesep 'processed_user_eval.mat']);
    else
        load([scratch filesep 'processed_user_eval.mat']);
    end
    
    if fig_flag
        f1 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
        for i = 1:10
            subplot(3, 4, i);bar(processed_result(i).keyword_count);title(['S_{' num2str(i) '}']);xlabel('Word Index');ylabel('Count');
        end
        %set(gca, 'FontSize', 20, 'FontName', 'Times New Roman');
        set(findall(gcf, 'type', 'text'), 'FontSize', 18, 'FontName', 'Times New Roman');
        f1 = tightfig(f1);
        saveas(f1, 'figures\user_eval_65_participants.png');
        
        keywords_selection_plot = zeros(length(processed_result), 12);
        for i = 1:length(processed_result)
            keywords_selection_plot(i, 1) = length(processed_result(i).over_5);
            keywords_selection_plot(i, 2) = length(processed_result(i).over_10);
            keywords_selection_plot(i, 3) = length(processed_result(i).over_15);
            keywords_selection_plot(i, 4) = length(processed_result(i).over_20);
            keywords_selection_plot(i, 5) = length(processed_result(i).over_25);
            keywords_selection_plot(i, 6) = length(processed_result(i).over_30);
            keywords_selection_plot(i, 7) = length(processed_result(i).over_35);
            keywords_selection_plot(i, 8) = length(processed_result(i).over_40);
            keywords_selection_plot(i, 9) = length(processed_result(i).over_45);
            keywords_selection_plot(i, 10) = length(processed_result(i).over_50);
            keywords_selection_plot(i, 11) = length(processed_result(i).over_55);
            keywords_selection_plot(i, 12) = length(processed_result(i).over_60);
        end
            
        f2 = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
        plot(keywords_selection_plot(1,:), ':x');hold on;
        plot(keywords_selection_plot(2,:), ':o');
        plot(keywords_selection_plot(3,:), ':+');
        plot(keywords_selection_plot(4,:), ':^');
        plot(keywords_selection_plot(5,:), ':>');
        plot(keywords_selection_plot(6,:), ':<');
        plot(keywords_selection_plot(7,:), ':*');
        plot(keywords_selection_plot(8,:), ':d');
        plot(keywords_selection_plot(9,:), ':s');
        plot(keywords_selection_plot(10,:), ':v');
        set(gca, 'XTickLabel', [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60], 'XTick', 1:12);xlim([1, 12]);xlabel('Number of Participants');ylabel('Number of Keywords');legend('S_1', 'S_2', 'S_3', 'S_4', 'S_5', 'S_6', 'S_7', 'S_8', 'S_9', 'S_{10}');
        f2 = tightfig(f2);
        saveas(f2, 'figures\user_eval_65_participants_keyword_decay.png');
    end
end
