function restored_channel = restore_channel(manipulated, ref1, ref2)
    manipulated = double(manipulated);
    ref1 = double(ref1);
    ref2 = double(ref2);
    
    if is_reversed(manipulated,ref1,ref2)
        restored_channel = 1-manipulated;
    else
        % Differences between bad channel and good channels
        dif1 = manipulated-ref1; % manipulated = dif1 + ref1
        dif2 = manipulated-ref2; 
        
        % try gaussian filter to smooth out differences
        sigma = 5;
        k = 2*ceil(3*sigma)+1;
        gaussian_kernel = fspecial('gaussian', [k k], sigma);
        dif1_smooth = imfilter(dif1,gaussian_kernel,'replicate');
        dif2_smooth = imfilter(dif2,gaussian_kernel,'replicate');
        
        % solutions
        sol1 = dif1_smooth + ref1;
        sol2 = dif2_smooth + ref2;
        sol = sol1/2 + sol2/2;
    
        % average this solution with the two good channels
        % to produce a distribution closer to those channels
        restored_channel = sol/3 + ref1/3 + ref2/3;
    end        
end