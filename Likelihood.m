function [F] = Likelihood(current)
global data;
global likelihoodRecord
global etchRecord
global noExpMetrics
likeData = 0;
noise = current(end); %change this back to unknown noise parameter eventually
trenchDim = zeros(noExpMetrics,1);
for i=1:length(data)
  [a, g, data0,trenchDim(1), trenchDim(2)] = etchingWithMask_new('low', 'contour', 'varyAlpha',current,i)
   for j = 1:length(noExpMetrics)
            Like = normpdf(data(i,j),trenchDim(j),noise) + 10e-20; %change back to look at both horizontal and vertical etch rates according to data function
            likeData = log(Like) + likeData;
    end
end
likelihoodRecord = [likelihoodRecord likeData];
F = likeData;
