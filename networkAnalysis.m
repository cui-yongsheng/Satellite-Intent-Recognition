%% 分析网络参数大小
%% 网络分析
num_channel = 6;
hidden_dim = 50;
num_clssify = 3;

%% "bilstm"
bilstm = [ ...
    sequenceInputLayer(num_channel) ...   % 输入层：用于接收序列输入，输入维度为6
    bilstmLayer(hidden_dim,'OutputMode','last') ...    % 双向 LSTM 层：包含10个隐藏单元，输出最后一个时间步的结果
    dropoutLayer(0.2) ...       % Dropout层：防止过拟合
    fullyConnectedLayer(num_clssify,'WeightL2Factor', 0.01) ...  % % 全连接层：将输入映射到2维输出（对应分类数量）
    softmaxLayer ...            % Softmax 层：将输出转换为概率分布
    ];
analyzeNetwork(bilstm)

%% "CNN_BiLSTM"
CNN_BiLSTM = [ ...
    sequenceInputLayer(num_channel)
    convolution1dLayer(50, 32, 'Padding', 'same', 'Stride', 25)
    batchNormalizationLayer
    reluLayer
    bilstmLayer(30, 'OutputMode', 'last')
    dropoutLayer(0.2)
    fullyConnectedLayer(num_clssify, 'WeightL2Factor', 0.01)
    softmaxLayer
    ];
analyzeNetwork(CNN_BiLSTM)

%% "CNN"
CNN = [ ...
    sequenceInputLayer(num_channel)
    convolution1dLayer(50, 16, 'Padding', 'same', 'Stride', 25)
    reluLayer
    convolution1dLayer(50, 24, 'Padding', 'same', 'Stride', 25)
    reluLayer
    globalAveragePooling1dLayer
    dropoutLayer(0.2)
    fullyConnectedLayer(num_clssify, 'WeightL2Factor', 0.01)
    softmaxLayer
    ];
analyzeNetwork(CNN)
