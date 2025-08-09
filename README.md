# STK 卫星意图识别项目

本项目基于STK (Satellite Tool Kit) 的卫星轨道仿真数据，实现对卫星行为意图的识别与分类。通过生成不同类型的卫星轨道数据，使用机器学习方法对卫星的行为进行分类识别。

## 项目概述

该项目旨在通过分析卫星轨道数据来识别卫星的行为意图，包括：
1. 轨道保持行为 (GEO Station Keeping)
2. 绕飞行为 (Fly Around)
3. 普通轨道传播行为 (Propagator)


## 核心功能模块

### 1. 数据生成模块

- [main_GEOStationKeeping.m](file://e:\matlab\STK\意图识别\main_GEOStationKeeping.m) - 生成地球同步轨道卫星保持行为数据
- [main_FlyAround.m](file://e:\matlab\STK\意图识别\main_FlyAround.m) - 生成绕飞行为数据
- [main_Propagator.m](file://e:\matlab\STK\意图识别\main_Propagator.m) - 生成普通轨道传播行为数据
- [main_Observation.m](file://e:\matlab\STK\意图识别\main_Observation.m) - 生成观测行为数据
- [main_segments.mlx](file://e:\matlab\STK\意图识别\main_segments.mlx) - 生成观测行为数据

### 2. 轨道保持模块

- [StationKeepingEW.m](file://e:\matlab\STK\意图识别\func\StationKeepingEW.m) - 东西向轨道保持
- [StationKeepingWE.m](file://e:\matlab\STK\意图识别\func\StationKeepingWE.m) - 西向东轨道保持
- [StationKeepingNS.m](file://e:\matlab\STK\意图识别\func\StationKeepingNS.m) - 南北向轨道保持
- [StoppingConditions.m](file://e:\matlab\STK\意图识别\func\StoppingConditions.m) - 停止条件设置

### 3. 轨迹关联

- [track_association_all.m](file://e:\matlab\STK\意图识别\track_association_all.m) - 使用LSTM进行轨迹关联，使用周期内完整数据
- [track_association_vae.m](file://e:\matlab\STK\意图识别\track_association_vae.m) - 基于变分自编码器(VAE)的轨迹关联，使用周期内完整数据
- [track_association_autoencoder.m](file://e:\matlab\STK\意图识别\track_association_autoencoder.m) - 基于自编码器的轨迹关联，使用周期内完整数据
- [track_association_segjoint.m](file://e:\matlab\STK\意图识别\track_association_segjoint.m) - 基于分段数据的LSTM轨迹关联

### 4. 意图识别

- [ClassifyUsingLSTM_all.m](file://e:\matlab\STK\意图识别\ClassifyUsingLSTM_all.m) - 使用LSTM进行意图分类，使用完整数据
- [ClassifyUsingLSTM_seg.m](file://e:\matlab\STK\意图识别\ClassifyUsingLSTM_seg.m) - 基于分段数据的LSTM意图分类
- [ClassifyUsingLSTM_segjoint.m](file://e:\matlab\STK\意图识别\ClassifyUsingLSTM_segjoint.m) - 基于分段数据的LSTM意图分类，仅使用观测数据

## 使用方法

### 环境要求

- MATLAB R20XX 或更高版本
- STK (Satellite Tool Kit) 11 或更高版本
- Deep Learning Toolbox (用于神经网络相关功能)

### 运行步骤

1. 确保已安装STK并正确配置MATLAB与STK的连接
2. 将项目代码添加到MATLAB路径中
3. 运行对应的数据生成脚本生成训练数据：
   ```matlab
   % 生成不同类型的行为数据
   main_GEOStationKeeping.m  % 轨道保持数据
   main_FlyAround.m          % 绕飞数据
   main_Propagator.m         % 普通传播数据
   main_Observation.m        % 本星数据
   main_segments.mlx         % 观测弧段
4. 运行意图识别和关机关联算法进行训练和测试

### 参数配置
    项目参数主要在 args.m 文件中配置：
    StartTime - 仿真开始时间
    StopTime - 仿真结束时间
    timeStep - 时间步长(秒)
    data_num - 仿真卫星数量
    
    数据说明
    项目使用的主要数据文件：
    GEO.tle - GEO卫星的两行轨道要素数据


### 算法说明
1. LSTM分类方法
   使用长短期记忆网络(LSTM)对卫星轨道数据进行分类，能够有效识别时间序列数据中的模式。

2. 自编码器方法
   使用自编码器(Autoencoder)对轨道数据进行特征提取和降维，然后使用分类器进行轨迹关联。

3. 变分自编码器(VAE)方法
   使用变分自编码器对轨道数据进行概率性建模，提取更丰富的特征表示用于轨迹关联，仅作为示例，效果很差。

### 注意事项
1. 运行仿真前请确保STK已正确安装并能通过MATLAB调用
2. 仿真时间范围和卫星数量可根据需要在args.m中调整
3. 大量数据处理可能需要较长时间，请耐心等待
4. 不同方法可能需要不同的数据预处理方式

### 扩展应用
该项目框架可以扩展用于识别更多类型的卫星行为，如：
- 轨道机动

- 目标接近

- 编队飞行

- 空间交会


通过训练更多的数据和优化算法，可以提高意图识别的准确性和鲁棒性。
