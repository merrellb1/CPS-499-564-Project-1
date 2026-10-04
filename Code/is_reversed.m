function result = is_reversed(manipulated,ref1,ref2)
    % mean and standard dev of good channels and bad one
    m = mean(ref1(:))/2 + mean(ref2(:))/2;
    s = std(ref1(:))/2 + std(ref2(:))/2;
    m_bad = mean(manipulated(:));
    s_bad = std(manipulated(:));


    % creating masks for highlights and shadows of good channels
    % using thresholds dependent on mean and std
    low = m-s*1;
    high = m+s*1;
    low_bad = m_bad-s_bad*1;
    high_bad = m_bad+s_bad*1;

    shadows = ref1<low & ref2<low;
    highlights = ref1>high & ref2>high;
    shadows_bad = manipulated<low_bad;
    highlights_bad = manipulated>high_bad;
    
    % see how much the shadows and highlights match between good and bad
    % channels, compare to inverse
    good_points = sum(sum(shadows & shadows_bad)) + sum(sum(highlights & highlights_bad));
    inverted_points = sum(sum(shadows & highlights_bad)) + sum(sum(highlights & shadows_bad));
    

    % temp
    %figure,imshow(shadows);
    %figure,imshow(highlights);
    

    result = good_points<inverted_points;
end