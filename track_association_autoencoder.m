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
data_propagator = data_propagator(1:data_num);                                  % 获取前100各卫星数据（取决于生成多少）
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

%% 构建自编码器
% 设置自编码器架构
hiddenSize = 100; % 隐藏层大小
autoenc = trainAutoencoder(XTrain, hiddenSize, ...
    'MaxEpochs', 100, ...
    'L2WeightRegularization', 0.001, ...
    'SparsityRegularization', 4, ...
    'SparsityProportion', 0.05, ...
    'DecoderTransferFunction', 'purelin', ...
    'ScaleData', true,...
    'UseGPU', true...
    );

% 从自编码器获取编码后的特征
featuresTrain = encode(autoenc, XTrain);
featuresTest = encode(autoenc, XTest);

%% 分类器训练
options=statset(UseParallel=true);
Mdl = TreeBagger(10, featuresTrain', YTrain, 'OOBPrediction', 'on', 'options', options);

%%
YPred = predict(Mdl, featuresTest');
YPred = str2double(YPred);
if iscategorical(YTest)
    YTest = double(YTest);
end
% 计算准确率
accuracy = sum(YPred == YTest) / length(YTest);
fprintf('Classification Accuracy: %.2f%%\n', accuracy * 100);
