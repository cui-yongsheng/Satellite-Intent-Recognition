function [signalsOut, labelsOut] = segmentDatas(signalsIn,labelsIn,segmentlength)
%SEGMENTSIGNALS makes all signals in the input array segmentlength samples long

% Copyright 2017 The MathWorks, Inc.

targetLength = segmentlength;
signalsOut = cell(length(signalsIn),1);
labelsOut = cell(length(labelsIn),1);

for idx = 1:numel(signalsIn)
    
    x = signalsIn{idx};
    y = labelsIn(idx);
    
    % Compute the number of targetLength-sample chunks in the signal
    numSigs = floor(length(x)/targetLength);
    
    if numSigs == 0
        x = [x; zeros(targetLength - size(x,1),size(x,2))];  %#ok<AGROW> % 填0以补足长度; 
    else
        x = x(1:targetLength,:);
    end
    
    % Vertically concatenate into cell arrays
    signalsOut{idx} = x;
    labelsOut{idx} = y;
end
labelsOut = cell2mat(labelsOut);
end