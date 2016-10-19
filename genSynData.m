clear all
global expConditions
%global data
global noUnknowns
global numberOfIons
global numberOfRadicals
global noExperimentalMetrics
global levelSetUnknowns

noExperimentalMetrics = 2;
numberOfIons = 2;
numberOfRadicals = 2;
levelSetUnknowns = 2;
noUnknowns = numberOfIons*2+numberOfRadicals*2+levelSetUnknowns+1;

load allSynExpConditions

expConditions = allSynExpConditions;

%make fake real parameters for novel resist material "Algernon"
A = [.1 .2];
B = [3.1 6.2];
lambda1 = 1;
lambda2 = .6;
rxnProb = 0.7;
SCl = [.4 .7];
noise = 2;
epsS = 50;
epsD = 8;
algernonUnknowns = [A B rxnProb SCl lambda1 lambda2 epsS epsD noise];

%data = allSynData(y(1:noTrainingData));
for i = 39:length(expConditions)
 [data, g, data0, algernonTrenchDim(i,1), algernonTrenchDim(i,2)] = etchingWithMask_new('high', 'contour', 'varyAlpha',algernonUnknowns,i);
end

