%% 素质三连
clear;
clc;
close all;
rng('default')
addpath(genpath('./func'))
addpath(genpath('./data'))
args;

%% 数据加载
% 传播数据
cycle_len = 24*60*60/timeStep;
cycle_num = 30;
data_propagator_temp = load("Propagator.mat");
data_propagator = {data_propagator_temp.tleStruct.PositionVelocity}';      % 提取位置信息
data_propagator = data_propagator(1:data_num);                             % 获取前100各卫星数据（取决于生成多少）
data_propagator = cellfun(@(x) table2array(x(1:cycle_len*cycle_num,1:6)), data_propagator, 'UniformOutput', false);    % 提取卫星信息，去除时间信息
clear data_propagator_temp;

%% 数据组织
labels = repelem((1:data_num)',cycle_num);
split_data_propagator = cellfun(@(x) mat2cell(x, repmat(cycle_len,cycle_num,1), 6), data_propagator, 'UniformOutput', false);
datas = vertcat(split_data_propagator{:});

%% 数据处理
labels = categorical(labels);
% TODO:对比不同归一化方法
datas = cellfun(@(x) (x - min(x)) ./ (max(x) - min(x)), datas, 'UniformOutput', false);
Ind = splitlabels(labels,[0.8,0.1],"randomized");
XTrain = datas(Ind{1},:);YTrain = labels(Ind{1},:);
XValid = datas(Ind{2},:);YValid = labels(Ind{2},:);
XTest = datas(Ind{3},:);YTest = labels(Ind{3},:);

%% 格式转换
N = numel(XTrain);  % XTrain 中的元素个数
XTrain_reshaped = zeros(480, 6, 1, N);
for i = 1:N
    XTrain_reshaped(:, :, 1, i) = single(XTrain{i});  % 将每个 cell 的元素放入四维矩阵的第 i 个位置
end
XTrain = XTrain_reshaped;
N = numel(XTest);  % XTest 中的元素个数
XTest_reshaped = zeros(480, 6, 1, N);
for i = 1:N
    XTest_reshaped(:, :, 1, i) = single(XTest{i});  % 将每个 cell 的元素放入四维矩阵的第 i 个位置
end
XTest = XTest_reshaped;

%% 构建变分自编码器
% 参数设置
numEpochs = 30;     % 训练轮次
learnRate = 0.001;   % 学习率
imageSize = [480 6 1];  % 输入尺寸为480x6的矩阵
numLatentChannels = 100;  % 潜在空间的维度
projectionSize = [30 6 2];  % 根据输入数据的形状调整重构大小
numOutputs = 1;
miniBatchSize = 128;
numInputChannels = imageSize(3);

% 数据处理
dsTrain = arrayDatastore(XTrain,IterationDimension=4);
mbq = minibatchqueue(dsTrain,numOutputs, ...
    MiniBatchSize = miniBatchSize, ...
    MiniBatchFcn=@preprocessMiniBatch, ...
    MiniBatchFormat="SSCB", ...
    PartialMiniBatch="discard");

% 网络结构
layersE = [
    imageInputLayer(imageSize,Normalization="none")
    convolution2dLayer([32,6],32,Padding="same",Stride=[16,1])
    reluLayer
    fullyConnectedLayer(2*numLatentChannels)
    samplingLayer];

layersD = [
    featureInputLayer(numLatentChannels)
    projectAndReshapeLayer(projectionSize)
    transposedConv2dLayer([32,6],32,Cropping="same",Stride=[16,1])
    reluLayer
    transposedConv2dLayer(3,numInputChannels,Cropping="same")
    sigmoidLayer];

% 创建网络对象
netE = dlnetwork(layersE);  % 编码器
netD = dlnetwork(layersD);  % 解码器

% 初始化Adam优化器
trailingAvgE = [];
trailingAvgSqE = [];
trailingAvgD = [];
trailingAvgSqD = [];

% 计算总训练次数
numObservationsTrain = size(XTrain,4);
numIterationsPerEpoch = ceil(numObservationsTrain / miniBatchSize);
numIterations = numEpochs * numIterationsPerEpoch;

% 训练进度监视器
monitor = trainingProgressMonitor( ...
    Metrics="Loss", ...
    Info="Epoch", ...
    XLabel="Iteration");

% 自定义训练循环
epoch = 0;
iteration = 0;
while epoch < numEpochs && ~monitor.Stop
    epoch = epoch + 1;
    shuffle(mbq);  % 数据随机打乱

    while hasdata(mbq) && ~monitor.Stop
        iteration = iteration + 1;
        X = next(mbq);  % 获取mini-batch数据
        [loss, gradientsE, gradientsD] = dlfeval(@modelLoss, netE, netD, X);

        % 更新网络参数
        [netE, trailingAvgE, trailingAvgSqE] = adamupdate(netE, gradientsE, trailingAvgE, trailingAvgSqE, iteration, learnRate);
        [netD, trailingAvgD, trailingAvgSqD] = adamupdate(netD, gradientsD, trailingAvgD, trailingAvgSqD, iteration, learnRate);

        % 更新进度监视器
        recordMetrics(monitor, iteration, Loss=loss);
        updateInfo(monitor, Epoch=epoch + " of " + numEpochs);
        monitor.Progress = 100 * iteration / numIterations;
    end
end

%% 从自编码器获取编码后的特征
featuresTrain = gather(predict(netE,XTrain));
featuresTest = gather(predict(netE,XTest));

% 分类器训练
options=statset(UseParallel=true);
Mdl = TreeBagger(5, featuresTrain, YTrain, 'OOBPrediction', 'on', 'options', options);
TestPred = predict(Mdl, featuresTest);
TrainPred = predict(Mdl, featuresTrain);
TestPred = str2double(TestPred);
TrainPred = str2double(TrainPred);
if iscategorical(YTrain)
    YTrain = double(YTrain);
    YTest = double(YTest);
end
% 计算准确率
train_accuracy = sum(TrainPred == YTrain) / length(YTrain);
test_accuracy = sum(TestPred == YTest) / length(YTest);
fprintf('Train Accuracy: %.2f%%\n', train_accuracy * 100);
fprintf('Test Accuracy: %.2f%%\n', test_accuracy * 100);


%%  函数定义
function [loss, gradientsE, gradientsD] = modelLoss(netE, netD, X)
    % 编码器前向传播
    [Z, mu, logSigmaSq] = forward(netE, X);
    
    % 解码器前向传播
    Y = forward(netD, Z);
    
    % 计算损失和梯度
    loss = elboLoss(Y, X, mu, logSigmaSq);
    [gradientsE, gradientsD] = dlgradient(loss, netE.Learnables, netD.Learnables);
end

function loss = elboLoss(Y,T,mu,logSigmaSq)
    % 计算重构损失
    reconstructionLoss = mse(Y,T);
    % 计算KL散度
    KL = -0.5 * sum(1 + logSigmaSq - mu.^2 - exp(logSigmaSq),1);
    KL = mean(KL);
    % 综合损失
    loss = reconstructionLoss + KL;
end

function X = preprocessMiniBatch(dataX)
    % 将不同的样本合并为一个mini-batch
    X = cat(4, dataX{:});
end

function Y = modelPredictions(netE,netD,mbq)
Y = [];
while hasdata(mbq)
    X = next(mbq);
    Z = predict(netE,X);
    XGenerated = predict(netD,Z);
    Y = cat(4,Y,extractdata(XGenerated));
end
end

function Y = encode(netE,mbq)
Y = [];
while hasdata(mbq)
    X = next(mbq);
    Z = predict(netE,X);
    Y = cat(2,Y,extractdata(Z));
end
end