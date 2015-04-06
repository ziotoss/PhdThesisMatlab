% load(['scratch' filesep 'test_songs_wlimit_20_elimit_20.mat']);
dic = processed_songs.dictionary;
occ_mat = processed_songs.occ_mat;
songs = processed_songs.test_songs;

words = {'우울', '우울하다', '우울함', '행복', '행복하다', '행복함', '이별', '결혼', '신나다', '생일', '크리스마스'};

for i = 1:length(words)
    song_artist = cell(1, 5);
    song_title = cell(1, 5);
    idx = find(strcmp(dic, words(i)));
    occ_tmp = occ_mat(:, idx);
    occ_tmp = occ_tmp / sum(occ_tmp);
    max_idx = zeros(1, 5);
    
    for j = 1:length(song_artist)
        [~, max_idx(j)] = max(occ_tmp);
        song_artist(j) = {songs(max_idx(j)).song_artist};
        song_title(j) = {songs(max_idx(j)).song_title};
        occ_tmp(max_idx(j)) = 0;
    end

    x_label = cell(1, 5);
    for j = 1:length(song_artist)
        str = [song_artist{j} '-' song_title{j}];
        x_label(j) = {str};
    end

    [x_tick, sort_idx] = sort(max_idx);
    x_str = x_label(sort_idx);
    
    figure;stem(occ_mat(:,idx) / sum(occ_mat(:,idx)));title(words{i});set(gca, 'XTick', x_tick, 'XTickLabel', x_str, 'FontSize', 10);
    xticklabel_rotate([], 90, []);
end