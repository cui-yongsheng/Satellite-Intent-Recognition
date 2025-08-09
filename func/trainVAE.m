function [vae, info] = trainVAE(XTrain, num_channel,encoder, decoder, lossFunction, options)

    inputLayer = sequenceInputLayer(num_channel);
    layers = [
        inputLayer
        encoder
        decoder
    ];
    
    % 创建 VAE 网络
    net = dlnetwork(layers);
    
    % 训练网络
    [vae, info] = trainnet(XTrain, net, lossFunction, options);
end