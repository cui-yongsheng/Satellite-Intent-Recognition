%% 素质三连
clear;
clc;
close all;
rng('default')
addpath(genpath('./func'))
addpath(genpath('./data'))

args    % 参数加载
%% 卫星TLE数据加载、格式转换
data_path = './data/GEO.tle';
tleStruct = readtle(data_path);
ArgumentOfPeriapsis = [tleStruct.ArgumentOfPeriapsis]';    % 近地点幅角
Eccentricity = [tleStruct.Eccentricity]';  % 偏心率
Inclination = [tleStruct.Inclination]';    % 轨道倾角
RightAscensionOfAscendingNode = [tleStruct.RightAscensionOfAscendingNode]';    % 升交点赤经
TrueAnomaly = [tleStruct.TrueAnomaly]';    % 真近点角

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

%% 仿真模拟
delta = 0.2;    % 轨道保持边界
results = cell(data_num, 1);
for i = 1:data_num
    %% 卫星轨道参数
    eccentricity = Eccentricity(i);       % 偏心率
    trueanomaly = TrueAnomaly(i);         % 真近点角
    inclination = Inclination(i);         % 轨道倾角
    argumentOfPeriapsis = ArgumentOfPeriapsis(i);     %近地点幅角
    raan = RightAscensionOfAscendingNode(i);          %升交点赤经
    sma = 42166.3;                                    % 应该处于的轨道高度

    %% 对选择部分GEO卫星进行处理
    if inclination>0.1
        disp([num2str(i) '轨道倾角大']);
        disp(['已跳过 ' num2str(i) ' / ' num2str(data_num) ' 个']);
        continue
    elseif eccentricity>6e-4
        disp([num2str(i) '轨道偏心率大']);
        disp(['已跳过 ' num2str(i) ' / ' num2str(data_num) ' 个']);
        continue
    else
        inclination = 0;         % 小于该范围轨道倾角默认应该处于0
    end 

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
  
    % 设置Astrogator模块的初始状态和传播参数
    root.ExecuteCommand(['Astrogator */Satellite/',Sat_name,' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.sma ',num2str(sma),' km']);         % 轨道半长轴
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.ecc ',num2str(eccentricity)]);    % 设置轨道偏心率
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.inc ',num2str(inclination),' deg']);    % 设置轨道倾角
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.w ',num2str(argumentOfPeriapsis),' deg']);  % 设置近地点幅角
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.TA ',num2str(trueanomaly),' deg']); % 设置真近点角
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.RAAN ',num2str(raan),' deg']);   % 设置升交点赤经
    root.ExecuteCommand('Astrogator */Satellite/Sat RunMCS');
    data = root.ExecuteCommand(['Report_RM */Satellite/', Sat_name,' Style "LLA Position" TimeStep ' num2str(timeStep*10)]);

    %% 计算近地点经度
    lan = root.ExecuteCommand(['Astrogator_RM */Satellite/', Sat_name, ' GetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.LAN']);
    lan = lan.Range(1,1);
    lan = regexp(lan{1,1}, '-?\d+\.\d+', 'match');
    lan = str2double(lan{1});

    %% 计算参数设置
    root.ExecuteCommand('ComponentBrowser */ Duplicate "Calculation Objects" Inclination "TOD"');
    root.ExecuteCommand('ComponentBrowser */ SetValue "Calculation Objects" "TOD" CoordSystem "CentralBody/Earth TOD"');
    % 判断漂移方向
    result = data.Range(1,data.Count);
    T = convertReport(result,true);
    if T{end,3} < lan-delta
        StationKeepingWE(satellite,lan,delta);
        StationKeepingNS(satellite,inclination);
        StoppingConditions(satellite,lan,-delta,inclination);
    elseif T{end,3} >= lan + delta
        StationKeepingEW(satellite,lan,-delta);
        StationKeepingNS(satellite,inclination);
        StoppingConditions(satellite,lan,delta,inclination);
    else
        disp([num2str(i) '轨道偏移小']);
        disp(['已跳过 ' num2str(i) ' / ' num2str(data_num) ' 个']);
        root.ExecuteCommand(['Unload / */Satellite/', Sat_name]);
        continue
    end

    %% 导出卫星轨道数据
    root.ExecuteCommand(['Astrogator */Satellite/',Sat_name,' RunMCS']);
    data = root.ExecuteCommand(['Report_RM */Satellite/', Sat_name,' Style "J2000 Position Velocity" TimePeriod "',StartTime,'" "',StopTime,'" TimeStep ' num2str(timeStep)]);
    result = data.Range(1,data.Count);
    T = convertReport(result,true);
    tleStruct(i).PositionVelocity = T(:,2:7);

    %% 进度展示，每完成1个卫星输出一次
    disp(['已完成 ' num2str(i) ' / ' num2str(data_num) ' 个']);
    root.ExecuteCommand(['Unload / */Satellite/', Sat_name]);
    
end
%% 保存数据
save('./data/GEOStationKeeping.mat', 'tleStruct');







