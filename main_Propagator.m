%% 素质三连
clear;
clc;
close all;
rng('default')
addpath(genpath('./func'))
addpath(genpath('./data'))

args    % 参数加载
%% 卫星TLE数据加载、格式转换
data_path = 'GEO.tle';
tleStruct = readtle(data_path);
ArgumentOfPeriapsis = [tleStruct.ArgumentOfPeriapsis]';    % 近地点幅角
Eccentricity = [tleStruct.Eccentricity]';  % 偏心率
Inclination = [tleStruct.Inclination]';    % 轨道倾角
RightAscensionOfAscendingNode = [tleStruct.RightAscensionOfAscendingNode]';    % 升交点赤经
Period = [tleStruct.Period]';  % 轨道周期
TrueAnomaly = [tleStruct.TrueAnomaly]'; % 真近点角

%% STK场景建立
% engine = actxserver('STKX11.application');
% root = actxserver('AgStkObjects11.AgStkObjectRoot');
% checkempty = root.Children.Count;
% % 如果存在未卸载的场景，则卸载并关闭当前场景，确保环境清洁以开始新的操作
% if checkempty ~= 0
%     root.CurrentScenario.Unload;
%     root.CloseScenario;
% end

%% 本文实现卫星传播
% 创建或获取正在运行的STK应用程序实例
uiApplication = actxserver('STK11.application');
uiApplication.Visible = true;
% 获取IAgStkObjectRoot接口，用于操作STK对象模型的根
root = uiApplication.Personality2;
% 检查当前是否有打开的场景，以决定是否需要卸载或关闭当前场景
checkempty = root.Children.Count;
% 如果存在未卸载的场景，则卸载并关闭当前场景，确保环境清洁以开始新的操作
if checkempty ~= 0
    root.CurrentScenario.Unload;
    root.CloseScenario;
end

%% 场景时间设定
root.NewScenario('Propagator');
root.ExecuteCommand(['SetAnalysisTimePeriod * "',StartTime,'" "',StopTime,'"']);
time_min = datetime(StartTime, 'InputFormat', 'dd MMM yyyy HH:mm:ss.SSS', 'Locale', 'en_US');  % 显式指定时间格式

%% 卫星生成
Sat_name='Sat';         % 定义卫星的名称
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

results = cell(data_num, 1);
for i = 1:data_num
    % 卫星轨道参数
    eccentricity = Eccentricity(i);       % 偏心率
    trueanomaly = TrueAnomaly(i);         % 真近点角
    inclination = Inclination(i);         % 轨道倾角
    argumentOfPeriapsis = ArgumentOfPeriapsis(i);     %近地点幅角
    raan = RightAscensionOfAscendingNode(i);          %升交点赤经
    period = Period(i);                   % 轨道周期
    % 设置Astrogator模块的初始状态和传播参数
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.Period ',num2str(period),' sec']);   % 设置轨道周期为 86169.6 秒
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.ecc ',num2str(eccentricity)]);    % 设置轨道偏心率
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.inc ',num2str(inclination),' deg']);    % 设置轨道倾角
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.w ',num2str(argumentOfPeriapsis),' deg']);  % 设置近地点幅角
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.TA ',num2str(trueanomaly),' deg']); % 设置真近点角
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.RAAN ',num2str(raan),' deg']);   % 设置升交点赤经
    root.ExecuteCommand('Astrogator */Satellite/Sat RunMCS');

    %% 导出卫星轨道数据
    data = root.ExecuteCommand(['Report_RM */Satellite/', Sat_name,' Style "J2000 Position Velocity" TimeStep ' num2str(timeStep)]);
    result = data.Range(1,data.Count);
    T = convertReport(result,true);
    tleStruct(i).PositionVelocity = T(:,2:7);

    %% 进度展示，每完成1个卫星输出一次
    disp(['已完成 ' num2str(i) ' / ' num2str(data_num) ' 个']);
end
%% 保存数据
save('./data/Propagator.mat', 'tleStruct');







