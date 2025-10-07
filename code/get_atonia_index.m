function [out_atonia_index,toConsider_REM,toConsider_N1,...
    toConsider_N2,toConsider_N3,toConsider_NREM,toConsider_W]= get_atonia_index(EMG,Fs,lights,artifacts,hypnogram,window_analysis)

%GET_ATONIA_INDEX This function calculates the atonia index for all sleep
%stages in the analysis window, within lights off and excluding the
%artifacts selected by the user
% INPUT: EMG, the EMG signal; Fs: the sampling frequency of the EMG signal;
% lights: a vector of 0s and 1s of the same size of the EMG signal, with 1s
% indicating lights off time; artifacts: a vector of 0s and 1s of the same
% size of the EMG signal, with 1s indicating artifacts; hypnogram: a vector
% containing the hypnogram of the same size of the EMG signal, with 2 =
% unscored, 1 = W, 0 = REM, -1 = N1, -2 = N2, -3 = N3; window_analysis: a
% vector of 0s and 1s of the same size of the EMG signal, with 1s indicating 
% the window where the analysis should be done.
% OUTPUT: out_atonia_index: a vector of size (1,12) containing the
% following values: the atonia index in REM, in N1 sleep, in N2 sleep, in
% N3 sleep, in NREM sleep and in W, the minutes of REM, N1 sleep, N2 sleep,
% N3 sleep, NREM sleep and W considered for the calculation (this
% information can be useful for the user to undestand how many artifact
% where present); toConsider_REM: a vector od 0s and 1s of the same size of
% EMG, where 1s indicate the REM sleep used for computation of the atonia
% index; toConsider_N1 a vector od 0s and 1s of the same size of
% EMG, where 1s indicate the N1 sleep used for computation of the atonia
% index; toConsider_N2: a vector od 0s and 1s of the same size of
% EMG, where 1s indicate the N2 sleep used for computation of the atonia
% index; toConsider_N3: a vector od 0s and 1s of the same size of
% EMG, where 1s indicate the N3 sleep used for computation of the atonia
% index; toConsider_NREM: a vector od 0s and 1s of the same size of
% EMG, where 1s indicate the NREM sleep used for computation of the atonia
% index; toConsider_W: a vector od 0s and 1s of the same size of
% EMG, where 1s indicate the W used for computation of the atonia
% index; 

%Initialization for the reuslts
out_atonia_index = nan(1,6);

%1. Consider the signal only in light off, within the analysis, and exclude artifacts
EMG(artifacts==1) = NaN;
EMG(lights==0) = NaN;
EMG(window_analysis==0) = NaN;

%2. Rectify the signal
EMG_rect = 2*abs(EMG);

%3. Now divide the whole signals into 1s mini-epochs
n_MiniEpochs = floor(length(EMG_rect)/Fs);

%4. Calculate the average in each mini-epoch
averageEMGMiniEpochs = nan(n_MiniEpochs,1);
for j = 1:n_MiniEpochs
    theseSamples = (j-1)*Fs+1:j*Fs;
    this_EMG = EMG_rect(theseSamples);
    averageEMGMiniEpochs(j) = nanmean(this_EMG);
end

%5. Make the noise correction
averageEMGMiniEpochs_corrected = nan(n_MiniEpochs,1);
%Noise correction for the first 30 miniEpochs
for j = 1:30
    thisWindow = 1:j+30;
    minimumThisWindow = nanmin(averageEMGMiniEpochs(thisWindow));
    averageEMGMiniEpochs_corrected(j) = averageEMGMiniEpochs(j)-minimumThisWindow;
end
%Noise correction fot the middle miniEpochs
for j = 31:length(averageEMGMiniEpochs_corrected)-30
    thisWindow = j-30:j+30;
    minimumThisWindow = nanmin(averageEMGMiniEpochs(thisWindow));
    averageEMGMiniEpochs_corrected(j) = averageEMGMiniEpochs(j)-minimumThisWindow;
end
%Noise correction for the last 30 miniEpochs
for j = length(averageEMGMiniEpochs_corrected)-29:length(averageEMGMiniEpochs_corrected)
    thisWindow = j-30:length(averageEMGMiniEpochs_corrected);
    minimumThisWindow = nanmin(averageEMGMiniEpochs(thisWindow));
    averageEMGMiniEpochs_corrected(j) = averageEMGMiniEpochs(j)-minimumThisWindow;
end

%6.Calculate the indices in the different stages
%REM sleep
disp('Calculating in REM sleep')
REM_sleep = hypnogram==0;
toConsider_REM = double(REM_sleep & ~artifacts & lights & window_analysis);
out_atonia_index(1) = calculate_atonia_index(n_MiniEpochs,Fs,toConsider_REM,averageEMGMiniEpochs_corrected);
out_atonia_index(7) = round((sum(toConsider_REM)/Fs)/60,2);
%N1 sleep
disp('Calculating in N1 sleep')
N1_sleep = hypnogram==-1;
toConsider_N1 = double(N1_sleep & ~artifacts & lights & window_analysis);
out_atonia_index(2) = calculate_atonia_index(n_MiniEpochs,Fs,toConsider_N1,averageEMGMiniEpochs_corrected);
out_atonia_index(8) = round((sum(toConsider_N1)/Fs)/60,2);
%N2 sleep
disp('Calculating in N2 sleep')
N2_sleep = hypnogram==-2;
toConsider_N2 = double(N2_sleep & ~artifacts & lights & window_analysis);
out_atonia_index(3) = calculate_atonia_index(n_MiniEpochs,Fs,toConsider_N2,averageEMGMiniEpochs_corrected);
out_atonia_index(9) = round((sum(toConsider_N2)/Fs)/60,2);
%N3 sleep
disp('Calculating in N3 sleep')
N3_sleep = hypnogram==-3;
toConsider_N3 = double(N3_sleep & ~artifacts & lights & window_analysis);
out_atonia_index(4) = calculate_atonia_index(n_MiniEpochs,Fs,toConsider_N3,averageEMGMiniEpochs_corrected);
out_atonia_index(10) = round((sum(toConsider_N3)/Fs)/60,2);
%NREM sleep
disp('Calculating in NREM sleep')
NREM_sleep = hypnogram<0;
toConsider_NREM = double(NREM_sleep & ~artifacts & lights & window_analysis);
out_atonia_index(5) = calculate_atonia_index(n_MiniEpochs,Fs,toConsider_NREM,averageEMGMiniEpochs_corrected);
out_atonia_index(11) = round((sum(toConsider_NREM)/Fs)/60,2);
%W
disp('Calculating in W')
W = hypnogram==1;
toConsider_W = double(W & ~artifacts & lights & window_analysis);
out_atonia_index(6) = calculate_atonia_index(n_MiniEpochs,Fs,toConsider_W,averageEMGMiniEpochs_corrected);
out_atonia_index(12) = round((sum(toConsider_W)/Fs)/60,2);


end

