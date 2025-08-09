%% 素质三连
clc;
clear;
close all;
rng(42);
addpath(genpath('./data'));
addpath(genpath('./func'));

%% 数据加载
disp('数据量较大，预计耗时2分钟')
load("segments.mat");

%% 以观测段作为输入进行分类
datas = {segment.position}';      % 提取观测段位置信息
labels = [segment.label]';        % 提取label信息
index = {segment.time}';

%% 数据处理
segmentlength = median(cellfun(@(x) size(x,1) ,datas));
disp(['数据长度中位数为：' num2str(segmentlength)]);
[datas,labels] = segmentDatas(datas,labels,segmentlength);
labels = categorical(labels);
datas = cellfun(@(x) (x - mean(x,1)) ./ std(x,0,1), datas, 'UniformOutput', false);
Ind = splitlabels(labels,[0.8,0.1],"randomized");
XTrain = datas(Ind{1},:);YTrain = labels(Ind{1},:);
XValid = datas(Ind{2},:);YValid = labels(Ind{2},:);
XTest = datas(Ind{3},:);YTest = labels(Ind{3},:);

%% 网络定义
num_channel = size(datas{1,1},1);
hidden_dim = 100;
num_clssify = 3;
layers = [ ...
    sequenceInputLayer(num_channel) ...   % 输入层：用于接收序列输入，输入维度为6
    bilstmLayer(hidden_dim,'OutputMode','last') ...    % 双向 LSTM 层：包含100个隐藏单元，输出最后一个时间步的结果
    dropoutLayer(0.2) ...       % Dropout层：防止过拟合
    fullyConnectedLayer(num_clssify,'WeightL2Factor', 0.01) ...  % % 全连接层：将输入映射到2维输出（对应分类数量）
    softmaxLayer ...            % Softmax 层：将输出转换为概率分布
    ];

%% 训练参数
MaxEpochs = 10;
MiniBatchSize = 1000;
InitialLearnRate = 0.01;
options = trainingOptions('adam', ...
    'MaxEpochs', MaxEpochs, ...     % 设置最大训练轮数为10
    'Shuffle','every-epoch', ...    % 每轮训练打乱数据
    'MiniBatchSize', MiniBatchSize, ... % 设置每次训练的小批量数据大小为10  
    'InitialLearnRate', InitialLearnRate, ...  % 设置初始学习率为0.01
    'GradientThreshold', 1, ...     % 设置梯度阈值为1，防止梯度爆炸
    'ExecutionEnvironment', "gpu", ...  % 指定使用GPU进行训练以加速计算
    'plots', 'training-progress', ...   % 显示训练进度图，便于实时监控训练过程
    'Verbose', false, ...           % 关闭详细输出，减少控制台信息干扰
    'ValidationData',{XValid,YValid},...    % 使用验证集验证 
    'LearnRateSchedule','piecewise', ...    % 使用逐步降低学习率
    'LearnRateDropFactor', 0.5, ...   % 每隔一定周期减半
    'LearnRateDropPeriod', 5 ...      % 每5个epoch降低学习率
);          


%% 网络训练
[net,info] = trainnet(XTrain,YTrain,net,"crossentropy",options);

%% 训练效果
% 训练集
trainPred = classify(net,XTrain,'SequenceLength',SequenceLength);
LSTMTrainAccuracy = sum(trainPred == YTrain)/numel(YTrain);
disp(['训练集正确率：' num2str(LSTMTrainAccuracy)]);
figure
myplot
classLabels = {'绕飞', '保持', '传播'};
figure(1)
YTrainstringLabels = arrayfun(@(x) classLabels{x}, double(YTrain), 'UniformOutput', false);
trainPredstringLabels = arrayfun(@(x) classLabels{x}, double(trainPred), 'UniformOutput', false);
confusionchart(YTrainstringLabels,trainPredstringLabels,'Title','训练集');
% 验证集
validPred = classify(net,XValid,'SequenceLength',SequenceLength);
LSTMValidAccuracy = sum(validPred == YValid)/numel(YValid);
disp(['验证集正确率：' num2str(LSTMValidAccuracy)]);
figure(2)
YValidstringLabels = arrayfun(@(x) classLabels{x}, double(YValid), 'UniformOutput', false);
validPredstringLabels = arrayfun(@(x) classLabels{x}, double(validPred), 'UniformOutput', false);
confusionchart(YValidstringLabels,validPredstringLabels,'Title','验证集');
% 测试集
testPred = classify(net,XTest,'SequenceLength',SequenceLength);
LSTMTestAccuracy = sum(testPred == YTest)/numel(YTest);
disp(['测试集正确率：' num2str(LSTMTestAccuracy)]);
figure(3)
YTeststringLabels = arrayfun(@(x) classLabels{x}, double(YTest), 'UniformOutput', false);
testPredstringLabels = arrayfun(@(x) classLabels{x}, double(testPred), 'UniformOutput', false);
confusionchart(YTeststringLabels,testPredstringLabels,'Title','测试集');

