tmwaveform = csvread('OriginalSignal.csv');
tmwaveform2 = normalization(tmwaveform);

% distancePolar = abs(tmwaveform2(1:end-1)-tmwaveform2(2:end));
% histogram(distancePolar,100)
startB = 5;
maxB = 256;
errormaxB = 8;
error = zeros(1,maxB)+500;
avglen = zeros(1,maxB);
signalSize = zeros(1,maxB);
bitsMatrix = zeros(1,maxB);
exponent = zeros(1,maxB);
maxBBits = ceil(log2(maxB));
huffman = false;
trueValue = 10;


for i=startB:maxB
    [error(i),avglen(i),signalSize(i)] = HuffmanDynamicSplit(tmwaveform,i,trueValue,false,huffman);
    bitsMatrix(i) = i;
end

intervalBits = 0:maxBBits;
for i=1:maxBBits
    logicalmatrix = (bitsMatrix > 2^intervalBits(i) & bitsMatrix <= 2^intervalBits(i+1));
    exponent = exponent + logicalmatrix .* 2^intervalBits(i+1);
end

dictUsage = bitsMatrix ./ exponent .*100;
wastedBits = exponent - bitsMatrix;

figure
plot(error)
title('EVM vs num. min. intervals')
xlabel('Intervals')
ylabel('EVM (%)')

if(huffman)
    figure
    plot(avglen)
    title('Average length vs num. min. intervals')
    xlabel('Intervals')
    ylabel('bits')

    figure
    plot(signalSize)
    title('Signal size vs num. min. intervals')
    xlabel('Intervals')
    ylabel('size(bits)')
end

minBits = min(bitsMatrix(error <= errormaxB));
[row,column] = find(bitsMatrix == minBits & error <= errormaxB);
[eee,aaa,sss] = HuffmanSplit(tmwaveform,minBits,true,true);
bestConf = {'Error','Num. Bits','Num Values','Wasted Values','DictUsage','Avg. len','Size Signal';...
    eee,log2(exponent(row,column)),bitsMatrix(row,column),...
    wastedBits(row,column),dictUsage(row,column),aaa,sss};