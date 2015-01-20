function hidden = feedForwardRBM (data, rbmModel)
    
    hidden = bsxfun(@plus, rbmModel.vishid*data, rbmModel.hidbiases);
    hidden = 1 ./ (1 + exp(-hidden));

end
