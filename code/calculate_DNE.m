function out = ...
    calculate_DNE(num_MiniEpochs,FS,toCons,averageEMGMiniEpochs_normal)
%CALCULATE_DNE: This function is a help function to calculate the
%DNE, according to the original paper
%https://pubmed.ncbi.nlm.nih.gov/28329117/.

% INPUT: num_MiniEpochs: the number of mini-epochs included in an EMG signal;
% FS: the sampling frequency of the EMF signal; toCons: a vector of 0s
% and 1s of sampling frequency Fs, where 1s indicate that the sample should
% be considered for the calculation of the atonia index;
% averageEMGMiniEpochs_normal: the normalized values of EMG
% amplitude in 0.5s-mini-epochs;
% OUTPUT: out: a vector with the 9 values of percentiles (1st, 3rd, 5th,
% 25th, 50th, 75th, 95th, 97th and 99th)

% Create a vector with the miniEpochs to consider
include_miniEpochs = zeros(num_MiniEpochs,1);
for i = 1:num_MiniEpochs
    theseSamples = (i-1)*0.5*FS+1:i*0.5*FS;
    if sum(toCons(theseSamples))==length(theseSamples)
        include_miniEpochs(i) = 1;
    end
end

%EMG values of the miniepochs to consider
averageEMGMiniEpochs_toConsider = averageEMGMiniEpochs_normal(include_miniEpochs==1);

%Calculate the values
perc1 = prctile(averageEMGMiniEpochs_toConsider,1);
perc3 = prctile(averageEMGMiniEpochs_toConsider,3);
perc5 = prctile(averageEMGMiniEpochs_toConsider,5);
perc25 = prctile(averageEMGMiniEpochs_toConsider,25);
perc50 = prctile(averageEMGMiniEpochs_toConsider,50);
perc75 = prctile(averageEMGMiniEpochs_toConsider,75);
perc95 = prctile(averageEMGMiniEpochs_toConsider,95);
perc97 = prctile(averageEMGMiniEpochs_toConsider,97);
perc99 = prctile(averageEMGMiniEpochs_toConsider,99);

%Output
out = [perc1,perc3,perc5,perc25,perc50,perc75,perc95,perc97,perc99];

end
