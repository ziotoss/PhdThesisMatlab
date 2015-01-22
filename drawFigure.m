function drawFigure(data, path, rbmModel)

    addpath('rbm');

    reduced = feedForwardRBM(data, rbmModel);
    plot_result = compute_mapping(reduced', 'PCA', 2);
    
    fid = fopen([path filesep 'matlab' filesep 'test.label']);
    C = textscan(fid, '%d');
    fclose(fid);
    label = C{1};
    
    uniqueLabel = unique(label);
    colors = [0 0 0;
              0 0 0.5;
              0 0 1;
              0 0.5 0;
              0 0.5 0.5;
              0 0.5 1;
              0 1 0;
              0 1 0.5;
              0 1 1;
              0.5 0 0;
              0.5 0 0.5;
              0.5 0 1;
              0.5 0.5 0;
              0.5 0.5 0.5;
              0.5 0.5 1;
              0.5 1 0;
              0.5 1 0.5;
              0.5 1 1;
              1 0 0;
              1 1 1;
              ];

    fig_color = zeros(length(label), 3);
    
    for i = 1:length(uniqueLabel)
        startIdx = find(label == uniqueLabel(i), 1, 'first');
        endIdx = find(label == uniqueLabel(i), 1, 'last');
        fig_color(startIdx:endIdx, :) = repmat(colors(i, :), endIdx - startIdx + 1, 1);
    end
    
    figure;scatter(plot_result(:, 1), plot_result(:, 2), [], fig_color);
end