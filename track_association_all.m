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
% datas = cellfun(@(x) (x - mean(x,1)) ./ std(x,0,1), datas, 'UniformOutput', false);
Ind = splitlabels(labels,[0.8,0.1],"randomized");
XTrain = datas(Ind{1},:);YTrain = labels(Ind{1},:);
XValid = datas(Ind{2},:);YValid = labels(Ind{2},:);
XTest = datas(Ind{3},:);YTest = labels(Ind{3},:);

%% 网络定义
num_channel = size(datas{1,1},2);
hidden_dim = 100;
num_clssify = data_num;
layers = [ ...
    sequenceInputLayer(num_channel) ...   % 输入层：用于接收序列输入，输入维度为6
    bilstmLayer(hidden_dim,'OutputMode','last') ...    % 双向 LSTM 层：包含100个隐藏单元，输出最后一个时间步的结果
    dropoutLayer(0.2) ...       % Dropout层：防止过拟合
    fullyConnectedLayer(num_clssify,'WeightL2Factor', 0.01) ...  % % 全连接层：将输入映射到2维输出（对应分类数量）
    softmaxLayer ...            % Softmax 层：将输出转换为概率分布
    ];

net = dlnetwork(layers);

%% 训练参数
MaxEpochs = 100;
MiniBatchSize = 300;
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
    'LearnRateDropPeriod', 5, ...      % 每5个epoch降低学习率
    'Metrics', "accuracy" ...
);          

%% 网络训练
[net,info] = trainnet(XTrain,YTrain,net,"crossentropy",options);