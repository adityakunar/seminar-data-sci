clear
clc
%read in the data in matlab and segment out the data from the labels.
X = readtable('BC.csv');
T = X(:, 3:end);
labels = X(:,2);
labels =table2array(labels);
Data = table2array(T);
Centered_Data = ((Data - mean(Data))./std(Data)); %center the matrix with respect to mean and standardize.
Gram = Centered_Data * Centered_Data';
m = size(Data,1);
[eigvec, eigval] =eig(((Gram)./m),'matrix'); % compute the eigen vectors and eigen values of the covariance matrix.
[d,ind] = sort(diag(eigval),'descend'); % compute the indices of the eigen values in descending order based on diagonal elements of the eigen value matrix.
eigvalsorted = eigval(ind,ind); % sort the eigenvalue matrix using the indices.
eigvecsorted = eigvec(:,ind);  % sort the eigvectors matrix using the indices. This will give us the principle components or modes 
                               %  in descending order of the amount of variance in that particular direction indicated by the modes.

eigvalD = diag(eigvalsorted) 

d = 2; %dimension we need to reduce to. 

basisvecs = zeros(size(Data,2),d); % initialise empty matrix to store basis vectors of affine spaces in the dimension of the full feature space.

% Extending the eigen vectors calculated from the gram matrix to the full
% feature space dimensionality. 
for i = 1:d
    basis = (sqrt(eigvalD(i))^-1).*(Centered_Data' * eigvecsorted(:,i));
    basisvecs(:,i)=(basis)/norm(basis);
end

% Orthogonal basis vectors as the dot product is very close to zero.
dot(basisvecs(:,1),basisvecs(:,2))

% Computing the data in the new reduced coordinate system based on principle modes.
Reduced_data =-(Centered_Data *(basisvecs));


% The variance as explained by the first 2 PCA modes. We also see that the
% variance captured is very close to 1 meaning the first 2 modes capture
% most of the variance in the data. 
var(Reduced_data)/sum(var(Reduced_data))

% Visualising the data in the reduced space.

% Showing that the new data has mutually uncorrelated columns.
corrcoef(Reduced_data)

plot_2d_scatter(Reduced_data, labels, "Snapshot of WBCD");

function plot_2d_scatter(x, labels, t)
    classes = unique(labels);
    num_classes = size(classes, 1);
    
    colmap = ["g", "r", "b", "y", "m"];
    
    figure();
    for i = 1:num_classes
        indexes = find(strcmp(labels, classes(i)));
        scatter(x(indexes,1), x(indexes,2),colmap(i));
        hold on
        c = mean(x(indexes,:));
        text(c(1), c(2), classes(i))
        hold on
    
    end
    title(t);
end