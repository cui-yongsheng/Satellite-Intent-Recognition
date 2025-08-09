%% 素质三连
clear;
clc;
close all;
rng('default')
addpath(genpath('./func'))
addpath(genpath('./data'))

args    % 参数加载
%% STK场景建立
engine = actxserver('STKX11.application');
root = actxserver('AgStkObjects11.AgStkObjectRoot');
checkempty = root.Children.Count;
% 如果存在未卸载的场景，则卸载并关闭当前场景，确保环境清洁以开始新的操作
if checkempty ~= 0
    root.CurrentScenario.Unload;
    root.CloseScenario;
end

%% 场景时间设定
root.NewScenario('GEOStationKeeping');
root.ExecuteCommand(['SetAnalysisTimePeriod * "',StartTime,'" "',StopTime,'"']);
root.ExecuteCommand(' Animate * Reset');

%% 卫星轨道参数
eccentricity = 0;           % 偏心率
trueanomaly = 0;            % 真近点角
inclination = 0;            % 轨道倾角
argumentOfPeriapsis = 0;    % 近地点幅角
raan = 0;                   % 升交点赤经
data_num = 10;min_sma = 10000;max_sma = 40166.3;  % 低于同步卫星轨道2000km
sam_list = linspace(min_sma, max_sma, data_num);    % 应该处于的轨道高度      

%% 卫星生成
Sat_name='SatObservation';         % 定义卫星的名称
satellite= root.CurrentScenario.Children.New('eSatellite', Sat_name);
satellite.SetPropagatorType('ePropagatorAstrogator');  % 设置卫星的轨道传播器类型
satellite.Propagator;   % 调用卫星的传播器
root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList Initial_State Propagate']);   % 从初始状态进行轨道传播。
root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.CoordinateType Modified Keplerian']); % 初始状态坐标类型为修正开普勒轨道
root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Epoch ',StartTime,' UTCG']);    % 设置初始历元（Epoch）时间
root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.ElementType "Kozai-Izsak Mean"']);   % 开普勒轨道要素类型为 Kozai-Izsak 平根数轨道元素
root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Propagate.StoppingConditions Epoch']);    % 设置传播器的停止条件为指定历元时间
root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Propagate.StoppingConditions.Epoch.TripValue ',StopTime,' UTCG']); % 设置传播结束时间
root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Propagate.Propagator Earth_J2']); % 设置传播器模型

%% 遍历不同轨道高度，得到轨迹数据
tleStruct(data_num).PositionVelocity = '';
for i = 1:data_num
    sma = sam_list(i);
    % 设置Astrogator模块的初始状态和传播参数
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name,' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.sma ',num2str(sma),' km']);         % 轨道半长轴
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.ecc ',num2str(eccentricity)]);    % 设置轨道偏心率
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.inc ',num2str(inclination),' deg']);    % 设置轨道倾角
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.w ',num2str(argumentOfPeriapsis),' deg']);  % 设置近地点幅角
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.TA ',num2str(trueanomaly),' deg']); % 设置真近点角
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.RAAN ',num2str(raan),' deg']);   % 设置升交点赤经
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' RunMCS']);
    %% 数据导出
    data = root.ExecuteCommand(['Report_RM */Satellite/', Sat_name,' Style "J2000 Position Velocity" TimeStep ' num2str(timeStep)]);
    result = data.Range(1,data.Count);
    T = convertReport(result,true);
    tleStruct(i).PositionVelocity = T(:,2:7);
    tleStruct(i).SemiMajorAxis = sma;
end
%% 保存数据
save('./data/SatObservation.mat', 'tleStruct');
