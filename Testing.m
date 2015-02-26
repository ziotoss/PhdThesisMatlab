fid = fopen('D:\Data\CAL500\songNames.txt');
C = textscan(fid, '%s');
fclose(fid);
songTitles = C{1};

list = dir('D:\Data\CAL500\CAL500_32kps\');
list = list(3:end);
list_titles = cell(length(list), 1);

for i = 1:length(list)
    list_titles{i} = list(i).name(1:end - 4);
end

exists = zeros(1, length(songTitles));
for i = 1:length(songTitles)
    for j = 1:length(list_titles)
        if strcmp(songTitles{i}, list_titles{j})
            exists(i) = 1;
            break;
        end
    end
end