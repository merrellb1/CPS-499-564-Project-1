function [ manipulated_channel , confidence ] = detect_tampering (R,G, B)
    %Mean test:
    %Find mean pixel value of each channel
    % R_mean = mean2(R);
    % G_mean= mean2(G);
    % B_mean = mean2(B);
    % %Compare Averages to see which channels are close to each other
    % dRG = abs(R_mean-G_mean);
    % dRB = abs(R_mean-B_mean);
    % dGB = abs(G_mean-B_mean);
    % %Get the ratio between the average difference in means and the difference
    % %of the other 2 channels
    % R_mean_score = abs(((dRG + dRB)/2) / dGB)
    % G_mean_score = abs(((dRG + dGB)/2) / dRB)
    % B_mean_score = abs(((dRB + dGB)/2) / dRG)
    % 
    % %Need to normalize score to a percentage (needs fine tuning from 0 to 1,
    % %this gives score from 0.33 to about 1)
    % mean_total = R_mean_score + G_mean_score + B_mean_score;
    % R_n_mean_score = R_mean_score /mean_total
    % G_n_mean_score = G_mean_score /mean_total
    % B_n_mean_score = B_mean_score /mean_total

    % %Median test:
    % R_med = median(R(:));
    % G_med = median(G(:));
    % B_med = median(B(:));
    % 
    % dRG = abs(R_med - G_med);
    % dRB = abs(R_med - B_med);
    % dGB = abs(G_med - B_med);
    % 
    % R_med_score = abs(((dRG + dRB)/2) - dGB)
    % G_med_score = abs(((dRG + dGB)/2) - dRB)
    % B_med_score = abs(((dRB + dGB)/2) - dRG)
    % 
    %Standard deviation test: 
    % R_std = std2(R);  G_std = std2(G);  B_std = std2(B);
    % 
    % sRG = abs(R_std - G_std);
    % sRB = abs(R_std - B_std);
    % sGB = abs(G_std - B_std);
    % 
    % R_std_score = abs(((sRG + sRB)/2) - sGB)
    % G_std_score = abs(((sRG + sGB)/2) - sRB)
    % B_std_score = abs(((sRB + sGB)/2) - sRG)
    % 
    % total = R_std_score + G_std_score + B_std_score;
    % R_n_std_score = R_std_score * 2
    % G_n_std_score = G_std_score * 2
    % B_n_std_score = B_std_score * 2

    % R_hist_analysis_score = .4*R_n_std_score+.6*R_n_mean_score
    % G_hist_analysis_score = .4*G_n_std_score+.6*G_n_mean_score
    % B_hist_analysis_score = .4*B_n_std_score+.6*B_n_mean_score
    %Histogram anaylsis:

    hR = imhist(R)/ numel(R);
    hG = imhist(G)/ numel(G);
    hB = imhist(B)/ numel(B);
    disp(hR)
    dRG = sum(abs(hR - hG)) /2;
    dRB = sum(abs(hR - hB)) /2;
    dGB = sum(abs(hG - hB)) /2;

    R_hist_analysis_diff = (dRG + dRB) / 2;
    G_hist_analysis_diff = (dRG + dGB) / 2;
    B_hist_analysis_diff = (dRB + dGB) / 2;
    hist_analysis_total = R_hist_analysis_diff + G_hist_analysis_diff + B_hist_analysis_diff
    R_n_hist_analysis_diff = R_hist_analysis_diff / hist_analysis_total
    G_n_hist_analysis_diff = G_hist_analysis_diff / hist_analysis_total
    B_n_hist_analysis_diff = B_hist_analysis_diff / hist_analysis_total
   
    % R_hist_analysis_score = .75*R_hist_analysis_diff_score+.25*R_n_mean_score
    % G_hist_analysis_score = .75*G_hist_analysis_diff_score+.25*G_n_mean_score
    % B_hist_analysis_score = .75*B_hist_analysis_diff_score+.25*B_n_mean_score
    [countsR, binsR] = imhist(R);
    [maxCountR, bin_indexR] = maxk(countsR,20);
    R_spike = maxCountR(1) / mean(maxCountR(2:20))

    [countsG, binsG] = imhist(G);
    [maxCountG, bin_indexG] = maxk(countsG,20);
    G_spike = maxCountG(1) / mean(maxCountG(2:20))

    [countsB, binsB] = imhist(B);
    [maxCountB, bin_indexB] = maxk(countsB,20);
    B_spike = maxCountB(1) / mean(maxCountB(2:20));
    total_spike_score = R_spike + G_spike + B_spike;

    R_spike_score = R_spike / total_spike_score
    G_spike_score = G_spike / total_spike_score
    B_spike_score = B_spike / total_spike_score 


    R_hist_analysis_score = R_n_hist_analysis_diff*.4 + R_spike_score*.6
    G_hist_analysis_score = G_n_hist_analysis_diff*.4 + G_spike_score*.6
    B_hist_analysis_score = B_n_hist_analysis_diff*.4 + B_spike_score*.6
    %Noise Test: (seems useless in these test cases)
    
    gaussian_kernel = fspecial('gaussian', [3 3],1);
    R_denoise = imfilter(R,gaussian_kernel,"replicate");
    G_denoise = imfilter(G,gaussian_kernel,"replicate");
    B_denoise = imfilter(B,gaussian_kernel,"replicate");
    

    %Calculates noise score by finding the average distance between filtered
    %channel and the original channel
    R_noise_score = mean2(abs(R - R_denoise));
    G_noise_score = mean2(abs(G - G_denoise));
    B_noise_score = mean2(abs(B - B_denoise));
    %Normalize noise score (need to find a way to standardize noise score)
    R_n_noise_score = R_noise_score;
    G_n_noise_score = G_noise_score;
    B_n_noise_score = B_noise_score;
    
    

    
    %Get max normalized score for each channel for all tests and return it as
    %a confidence score if it is the highest percentage of all channels
    R_Confidence = max(R_n_noise_score,R_hist_analysis_score);
    G_Confidence = max(G_n_noise_score,G_hist_analysis_score);
    B_Confidence = max(B_n_noise_score,B_hist_analysis_score);
    
    
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