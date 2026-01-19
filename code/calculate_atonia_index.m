function AI = calculate_atonia_index(n_MiniEpochs,Fs,toConsider,averageEMGMiniEpochs_corrected)
%CALCULATE_ATONIA_INDEX: This function is a help function to calculate the
%atonia index, according to the original paper
%https://pubmed.ncbi.nlm.nih.gov/20817596/.
% INPUT: n_MiniEpochs: the number of mini-epochs included in an EMG signal;
% Fs: the sampling frequency of the EMF signal; toConsider: a vecotr of 0s
% and 1s of sampling frequency Fs, where 1s indicate that the sample should
% be considered for the calculation of the atonia index;
% averageEMGMiniEpochs_corrected: the noise-corrected values of EMG
% amplitude in 1s-mini-epochs;
% OUTPUT: AI: the atonia index

% Create a vector with the miniEpochs to consider
include_miniEpochs = zeros(n_MiniEpochs,1);
for i = 1:n_MiniEpochs
    theseSamples = (i-1)*Fs+1:i*Fs;
    if sum(toConsider(theseSamples))==length(theseSamples) % Only if it is all included
        include_miniEpochs(i) = 1;
    end
end

%EMG values of the miniepochs to consider
averageEMGMiniEpochs_toConsider = averageEMGMiniEpochs_corrected(include_miniEpochs==1);

%Calculate the percentages 
percLess1micro = length(find(averageEMGMiniEpochs_toConsider<=1))/length(averageEMGMiniEpochs_toConsider);
perc1to2micro = length(find(averageEMGMiniEpochs_toConsider>1 & averageEMGMiniEpochs_toConsider<=2))/length(averageEMGMiniEpochs_toConsider);

%Calculate AI according to the definition
AI = percLess1micro/(1-perc1to2micro);
end

