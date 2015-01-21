function [dictionary, data] = load_dataset(path, options)

    if ~isempty(strfind(path, 'Naver'))
        D = dir([path filesep 'word_freq']);

        fid = fopen([path filesep 'word_freq' filesep D(3).name]);
        C = textscan(fid, '%s%d', 'delimiter', '\t');
        wordSize = length(C{1});
        fclose(fid);

        bowMatrix = zeros(wordSize, length(D) - 2);

        for i = 3:length(D)
            fid = fopen([path filesep 'word_freq' filesep D(i).name]);
            C = textscan(fid, '%s%d', 'delimiter', '\t');
            dictionary = C{1};
            fclose(fid);

            tmp = C{2};
            if options.data.normalize
                bowMatrix(:, i - 2) = tmp / sum(tmp);
            else
                bowMatrix(:, i - 2) = tmp;
            end
        end

        data = bowMatrix;
    elseif ~isempty(strfind(path, '20NewsGroups'))
        if strcmp(options.data.type, 'train')
            fileName = [path filesep 'matlab' filesep 'train.data'];
        elseif strcmp(options.data.type, 'test')
            fileName = [path filesep 'matlab' filesep 'test.data'];
        else
            disp('Invalid data type. Aborting program');
            return;
        end
        fid = fopen(fileName);
        C = textscan(fid, '%d%d%d', 'delimiter', ' ');
        fclose(fid);
        
        textIdx = C{1};
        wordIdx = C{2};
        occ = C{3};
        
        fileName = [path filesep 'matlab' filesep 'vocabulary.txt'];
        fid = fopen(fileName);
        C = textscan(fid, '%s');
        fclose(fid);
        
        dictionary = C{1};
        
        data = zeros(length(dictionary), max(textIdx));
        for i = 1:length(textIdx)
            data(wordIdx(i), textIdx(i)) = occ(i);
        end
        
        if options.data.normalize
            for i = 1:size(data, 2)
                data(:, i) = data(:, i) / sum(data(:, i));
            end
        end
    end
end