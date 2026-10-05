function [ manipulated_channel , confidence ] = detect_tampering (R,G, B)

    %Histogram analysis:
    % Shape Test:
    % Compares the shape of the histograms by normalizing them and then
    % finding their difference.
    
    % Gets normalized histogram of all channels (sum of histogram = 1)
    hR = imhist(R)/ numel(R);
    hG = imhist(G)/ numel(G);
    hB = imhist(B)/ numel(B);

    % Sums the difference in histograms and normalizes it 
    dRG = sum(abs(hR - hG)) /2;
    dRB = sum(abs(hR - hB)) /2;
    dGB = sum(abs(hG - hB)) /2;
    % Calculates the average difference per channel
    R_hist_analysis_diff = (dRG + dRB) / 2;
    G_hist_analysis_diff = (dRG + dGB) / 2;
    B_hist_analysis_diff = (dRB + dGB) / 2;
    % Takes those differences and puts them into a ratio. The total of all
    %ratio channels equals 1.
    hist_analysis_total = R_hist_analysis_diff + G_hist_analysis_diff + B_hist_analysis_diff;
    R_n_hist_analysis_diff = R_hist_analysis_diff / hist_analysis_total;
    G_n_hist_analysis_diff = G_hist_analysis_diff / hist_analysis_total;
    B_n_hist_analysis_diff = B_hist_analysis_diff / hist_analysis_total;
    
    % Spike test: 
    % Takes the Mode of the histogram and compares it with the
    %top 20 pixel values in a channel. Since Manipulated channels tend to
    %have higher spikes it works well as a variable to find edited channels 
    
    % Saves all of the histogram values for each channel and the bins the belong to in the
    %histogram.
    [countsR, binsR] = imhist(R);
    [countsG, binsG] = imhist(G);
    [countsB, binsB] = imhist(B);

    % Saves the max 20  of each channel and their index in separate values
    [maxCountR, bin_indexR] = maxk(countsR,20);
    [maxCountG, bin_indexG] = maxk(countsG,20);
    [maxCountB, bin_indexB] = maxk(countsB,20);
    
    % Gets the ratio of the number of pixels in the highest value in the
    %histogram and the other top 20 values averaged for each channel.
    R_spike = maxCountR(1) / mean(maxCountR(2:20));
    G_spike = maxCountG(1) / mean(maxCountG(2:20));
    B_spike = maxCountB(1) / mean(maxCountB(2:20));

    % Normalizes the score so the score of each channel sums to 1.
    total_spike_score = R_spike + G_spike + B_spike;
    R_spike_score = R_spike / total_spike_score;
    G_spike_score = G_spike / total_spike_score;
    B_spike_score = B_spike / total_spike_score;

    % Arbitrary weights added to hist analysis score
    R_hist_analysis_score = R_n_hist_analysis_diff*.5 + R_spike_score*.5;
    G_hist_analysis_score = G_n_hist_analysis_diff*.5 + G_spike_score*.5;
    B_hist_analysis_score = B_n_hist_analysis_diff*.5 + B_spike_score*.5;

    % Noise Test: 
    % Applies gaussian filter to each channel
    gaussian_kernel = fspecial('gaussian', [7 7],1.5);
    R_denoise = imfilter(R,gaussian_kernel,"replicate");
    G_denoise = imfilter(G,gaussian_kernel,"replicate");
    B_denoise = imfilter(B,gaussian_kernel,"replicate");
    

    % Calculates noise score by finding the average distance between filtered
    %channel and the original channel
    R_noise_score = std2(R - R_denoise);
    G_noise_score = std2(G - G_denoise);
    B_noise_score = std2(B - B_denoise);
    
    % Normalize noise score 
    total_noise_score = R_noise_score + G_noise_score + B_noise_score;
    R_n_noise_score = R_noise_score / total_noise_score;
    G_n_noise_score = G_noise_score / total_noise_score;
    B_n_noise_score = B_noise_score / total_noise_score;
   
    % Each test commits 1/3 to the total confidence score
    R_Confidence = R_hist_analysis_score * (2/3) + R_n_noise_score * (1/3);
    G_Confidence = G_hist_analysis_score * (2/3) + G_n_noise_score * (1/3);
    B_Confidence = B_hist_analysis_score * (2/3) + B_n_noise_score * (1/3);
    
    % Compares Confidence values to determine which channel is most likely
    %to be tampered with and return it with the correct confidence score.
    if(R_Confidence > G_Confidence && R_Confidence > B_Confidence)
       manipulated_channel =  'R';
       confidence = R_Confidence;
    elseif(G_Confidence > R_Confidence && G_Confidence > B_Confidence)
       manipulated_channel =  'G';
       confidence = G_Confidence;
    else
       manipulated_channel =  'B';
       confidence = B_Confidence;
    end
end