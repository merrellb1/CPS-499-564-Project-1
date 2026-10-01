function restored_channel = restore_channel(manipulated, ref1, ref2)
    manipulated = double(manipulated);
    ref1 = double(ref1);
    ref2 = double(ref2);
    
    % Differences between bad channel and good channels
    dif1 = manipulated-ref1; % manipulated = dif1 + ref1
    dif2 = manipulated-ref2; 
    
    
    % try gaussian filter to smooth out differences
    sigma = 5;
    dif1_smooth = imgaussfilt(dif1,sigma);
    dif2_smooth = imgaussfilt(dif2,sigma);
    
    % solutions
    sol1 = dif1_smooth + ref1;
    sol2 = dif2_smooth + ref2;
    sol = sol1/2 + sol2/2;

    %restored_channel = uint8(sol);
    restored_channel = sol/3 + ref1/3 + ref2/3;

end