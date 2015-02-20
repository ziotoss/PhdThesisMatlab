%Jiquan's implementation of PCA Whitening

function [V,Vi,E,D,retained] = pca_whiten(X, num, threshold, addeps)

% do PCA on image patches
%
% INPUT variables:
% X                  matrix with image patches as columns
%
% OUTPUT variables:
% V                  whitening matrix
% Vi                 dewhitening matrix
% E                  principal component transformation (orthogonal)
% D                  variances of the principal components


% shuffle data
X = X(:,randperm(size(X,2)));

% Calculate the eigenvalues and eigenvectors of the new covariance matrix.
covarianceMatrix = X*X'/size(X,2);
[E, D] = eig(covarianceMatrix);

% Sort the eigenvalues  and recompute matrices
[dummy,order] = sort(diag(-D));

prop  = cumsum(dummy)/sum(dummy);

%     if exist('threshold', 'var') && ~isempty(threshold)
% 		maxe  = find(prop>threshold,1);
% 		order = order(1:maxe); % In case some eigen values go to zero
%     elseif exist('num', 'var') && ~isempty(num)
% 		order = order(1:num);
%     end

pca_size = min(find(prop>threshold,1), num);
order = order(1:pca_size);

if ~exist('addeps', 'var') || isempty(addeps)
    addeps = 0;
end


%fprintf('Using %f components at %f \n', length(order), 100*prop(length(order)));

retained = prop(length(order));

E = E(:,order);
d = diag(D);
dsqrt    = real((d+addeps).^(0.5));
Dsqrt    = diag(dsqrt(order));
dsqrtinv = real((d+addeps).^(-0.5));
Dsqrtinv = diag(dsqrtinv(order));
D = diag(d(order));
V  = Dsqrtinv*E';
Vi = E*Dsqrt;

end

