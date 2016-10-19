clear all
close all

%this method uses Bayesian inference to infer ion sputtering yield,
%reaction probabilty of neutrals and ion stimulated desorption (all
%hard to measure constants in the surface kinetics model for etching). 

%declare global variables
global proposalLB
global proposalUB
global data
global noUnknowns
global priorLB
global priorUB
global expRows
global expColumns
global noExperiments
global proposalMean
global proposalSD
global numberOfIons
global numberOfRadicals
global expConditions
global y
global noTrainingData
global noTestData
global noExperimentalMetrics
%global algernonEtchRatesWithNoise
global levelSetUnknowns

noExperimentalMetrics = 2;
numberOfIons = 2;
numberOfRadicals = 1;
levelSetUnknowns = 2;
noUnknowns = numberOfIons*2+numberOfRadicals*2+levelSetUnknowns+1;
proposalLB = [0 0 0 0 0 0 .0 0 01]
proposalUB = [1 1 1 1 1 1 1 2 1];
proposalMean = [5 5 5 5 5 5 7.5];
proposalSD =  ones(noUnknowns,1)*0.5;
priorLB = [0 0 0 0 0 0 .1 .1 .01]
priorUB = [10 10 10 10 10 10 5 1 15];


%Bayesian model method
load allSynExpConditions
load algernonEtchRates

%Make set of training/test data %no added noise
noTrainingData = 3;
noTestData = 10;
k = noTrainingData + noTestData;
y = randsample(length(algernonEtchRatesWithNoise),k);
%data = algernonEtchRatesWithNoise(y(1:noTrainingData));
expConditions = allSynExpConditions(y(1:noTrainingData),:);
data = algernonEtchRatesWithNoise(y(1:noTrainingData),:);
%realParameters = [.05 .05 .05 .05 0.25]
%Make initial guess for unknown parameters
current = ones(noUnknowns,1);
Likelihood(current)
%Peform MH iterations

N = 2;
theta = zeros(N*noUnknowns,noUnknowns);
acc = zeros(1,noUnknowns);
PosteriorCurrent = Posterior(current,1);
% for i = 1:burnin    % First make the burn-in stage
%     for j=1:noUnknowns
%       [alpha,t, a,prob, PosteriorCatch] = MetropolisHastings(theta,current,PosteriorCurrent,j);
%     end
% end
for cycle = 1:N  % Cycle to the number of samples
    ind = 1;
     for m=1:noUnknowns % Cycle to make the thinning
            [alpha,t, a,prob, PosteriorCatch] = MetropolisHastings(theta,current,PosteriorCurrent,m);
            theta((cycle-1)*noUnknowns+m,:) = t;        % Samples accepted
            AlphaSet(cycle,m) = alpha;
            current = t;
            PosteriorCurrent = PosteriorCatch;
            acc(m) = acc(m) + a;  % Accepted ?
     end
end
 

accrate = acc/N;     % Acceptance rate,. 

%calculate final etch rate from Bayes using mean values
for i =1:noUnknowns
    inferred(i) = mean(theta(:,i));
end
for k=1:length(data)
        inferredEtchRate(k) = plasma(inferred,k);
end

%Compare real versus prediction
exp = linspace(1,length(data),length(data));
scatter(exp,inferredEtchRate)
hold on
scatter(exp,data(:,1),'r');
title('Real versus predicted (based on mean parameter values');
xlabel('Exp No');
ylabel('Etch Rate (nm/min)');
figure;
    for i =1:noUnknowns
        subplot(3,3,i);
        outputTitle = sprintf('Unknown %d',i);
        hist(theta(:,i)); 
 %       f.Normalization = 'probability';
        %counts = f.Values;
%         hold on
%         line([real(i) real(i)],[0 max(counts)], 'Color', 'r')
%         hold on
%         xmin = min(theta(:,i));
%         xmax = max(theta(:,i));
%         x = xmin:1:xmax;
%         hold on
%         line([priorLB(i) priorLB(i)],[0 max(counts)], 'Color', 'g')
%         hold on
%         line([priorUB(i) priorUB(i)],[0 max(counts)], 'Color', 'g')
        title(outputTitle);
        xlabel('Value');
        ylabel('Frequency');
    end



figure; 
for k =1:noUnknowns
    outputTitle = sprintf('Unknown %d',k);
    subplot(3,3,k);
    plot(theta(:,k));
    hold on
    line([0 N],[real(k) real(k)], 'Color', 'r')
    hold on
    line([0 N],[proposalLB(i) proposalLB(i)], 'Color', 'g')
    line([0 N],[proposalUB(i) proposalUB(i)], 'Color', 'g')
    title(outputTitle);
    xlabel('Cycle #');
    ylabel('Value');
end

%genPlots(theta)
