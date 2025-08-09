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

%% 卫星A生成
Sat_name='SatA';         % 定义卫星的名称
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

%% 卫星B生成
Sat_name1='SatB';         % 定义卫星的名称
satellite1= root.CurrentScenario.Children.New('eSatellite', Sat_name1);
satellite1.SetPropagatorType('ePropagatorAstrogator');  % 设置卫星的轨道传播器类型
satellite1.Propagator;   % 调用卫星的传播器
root.ExecuteCommand(['Astrogator */Satellite/', Sat_name1, ' SetValue MainSequence.SegmentList Initial_State Propagate']);   % 从初始状态进行轨道传播。
root.ExecuteCommand(['Astrogator */Satellite/', Sat_name1, ' SetValue MainSequence.SegmentList.Initial_State.CoordinateType Modified Keplerian']); % 初始状态坐标类型为修正开普勒轨道
root.ExecuteCommand(['Astrogator */Satellite/', Sat_name1, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Epoch ',StartTime,' UTCG']);    % 设置初始历元（Epoch）时间
root.ExecuteCommand(['Astrogator */Satellite/', Sat_name1, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.ElementType "Kozai-Izsak Mean"']);   % 开普勒轨道要素类型为 Kozai-Izsak 平根数轨道元素
root.ExecuteCommand(['Astrogator */Satellite/', Sat_name1, ' SetValue MainSequence.SegmentList.Propagate.StoppingConditions Epoch']);    % 设置传播器的停止条件为指定历元时间
root.ExecuteCommand(['Astrogator */Satellite/', Sat_name1, ' SetValue MainSequence.SegmentList.Propagate.StoppingConditions.Epoch.TripValue ',StopTime,' UTCG']); % 设置传播结束时间
root.ExecuteCommand(['Astrogator */Satellite/', Sat_name1, ' SetValue MainSequence.SegmentList.Propagate.Propagator Earth_J2']); % 设置传播器模型

%% 绕飞卫星生成
VMC_SatName='raofei';
satellite2= root.CurrentScenario.Children.New('eSatellite', VMC_SatName);
satellite2.SetPropagatorType('ePropagatorAstrogator'); 
satellite2.Propagator;
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList Initial_State Propagate');
root.ExecuteCommand(['Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.CoordinateSystem "Satellite/',Sat_name1,' VVLH"']);
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.CoordinateType Cartesian');
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Propagate.Propagator Earth_J2');

%% 转移卫星生成
Sat_best='Sat_best';
satellite3= root.CurrentScenario.Children.New('eSatellite', Sat_best);  % 在当前场景中新建卫星
satellite3.SetPropagatorType('ePropagatorAstrogator');  % 设置卫星的轨道传播器类型
satellite3.Propagator;
results = cell(data_num, 1);
for i = 1:data_num
    %% 卫星A轨道参数
    eccentricity = Eccentricity(i);       % 偏心率
    trueanomaly = TrueAnomaly(i);         % 真近点角
    inclination = Inclination(i);         % 轨道倾角
    argumentOfPeriapsis = ArgumentOfPeriapsis(i);     %近地点幅角
    raan = RightAscensionOfAscendingNode(i);          %升交点赤经
    period = Period(i);                   % 轨道周期
    % 设置Astrogator模块的初始状态和传播参数
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.Period ',num2str(period),' sec']);   % 设置轨道周期为 86169.6 秒
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.ecc ',num2str(eccentricity)]);       % 设置轨道偏心率
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.inc ',num2str(inclination),' deg']);        % 设置轨道倾角
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.w ',num2str(argumentOfPeriapsis),' deg']);  % 设置近地点幅角
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.TA ',num2str(trueanomaly),' deg']);  % 设置真近点角
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.RAAN ',num2str(raan),' deg']);       % 设置升交点赤经
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name, ' RunMCS']);

    %% 卫星B轨道参数
    j = randi(data_num);
    while j == i
        j = randi(data_num);
    end
    eccentricity1 = Eccentricity(j);       % 偏心率
    trueanomaly1 = TrueAnomaly(j);         % 真近点角
    period1 = Period(j);                   % 轨道周期
    inclination1 = Inclination(j);         % 轨道倾角
    argumentOfPeriapsis1 = ArgumentOfPeriapsis(j);     % 近地点幅角
    raan1 = RightAscensionOfAscendingNode(j);          % 升交点赤经
    % 设置Astrogator模块的初始状态和传播参数
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name1, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.Period ',num2str(period1),' sec']);   % 设置轨道周期为 86169.6 秒
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name1, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.ecc ',num2str(eccentricity1)]);    % 设置轨道偏心率
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name1, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.inc ',num2str(inclination1),' deg']);    % 设置轨道倾角
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name1, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.w ',num2str(argumentOfPeriapsis1),' deg']);  % 设置近地点幅角
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name1, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.TA ',num2str(trueanomaly1),' deg']); % 设置真近点角
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name1, ' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.LAN ',num2str(raan1),' deg']);   % 设置升交点赤经
    root.ExecuteCommand(['Astrogator */Satellite/', Sat_name1, ' RunMCS']);

    %% 随机生成任务时间（完成轨道转移时刻），基于场景时间范围
    time_min = datetime(StartTime, 'InputFormat', 'dd MMM yyyy HH:mm:ss.SSS', 'Locale', 'en_US');  % 显式指定时间格式
    time_max = datetime(StopTime, 'InputFormat', 'dd MMM yyyy HH:mm:ss.SSS', 'Locale', 'en_US');
    buffer_minutes = 5*24*60; % 缓冲时间为5天
    total_minutes = minutes(time_max - time_min);
    if buffer_minutes >= total_minutes
        error('缓冲时间过长，请调整 buffer_minutes 或增加时间范围。');
    end
    random_minutes = randi([buffer_minutes, total_minutes], 1, 1);
    MissionTime = time_min + minutes(random_minutes);
    MissionTime = datestr(MissionTime, 'dd mmm yyyy HH:MM:SS.FFF');

    %% 利用STK报表的方式生成一个该时刻绕飞的卫星
    omega=2*pi/period1;      % 卫星角速度
    % 随机生成短半轴
    z = randi([5, 15]);     % 绕飞短半轴，范围为5到15
    dx=2*omega*z;           % 计算绕飞椭圆的X轴速度分量(科里奥利力)
    % 利用CW方程选择能绕飞的点, VVLH坐标系
    time=0:timeStep:period1;
    X=[0,0,z,dx,0,0]';      % 初始状态向量，包含位置和速度
    xx=zeros(length(time),6);  % 创建一个6列的矩阵，用于保存结果
    for index = 1:length(time)
        t=(index-1)*timeStep;
        xx(index,:)=CW(X,omega,t);
    end
    root.ExecuteCommand(['Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.InitialState.Epoch ',MissionTime,' UTCG']);
    root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Propagate.StoppingConditions Epoch');
    root.ExecuteCommand(['Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Propagate.StoppingConditions.Epoch.TripValue ',StopTime,' UTCG']);

    %% 利用函数优化的方法找到最优机动时刻以及最优入轨点
    root.ExecuteCommand('ComponentBrowser */ Duplicate "Design Tools" "Lambert Solver" myLambert');
    data=root.ExecuteCommand(['Report_RM */Satellite/',Sat_name ,' Style "Inertial Position Velocity" TimePeriod "',StartTime,'" "',MissionTime,'" TimeStep ',num2str(timeStep)]);
    result = data.Range(1,data.Count);
    data = convertReport(result,true);
    vars.xx = xx;   vars.root = root;  vars.MissionTime = MissionTime; 
    vars.timeStep = timeStep; vars.StopTime = StopTime;
    vars.VMC_SatName = VMC_SatName; vars.data = data(2:end,:);
    x1 = (1+size(data,1)-1)/2;
    x2 = (1+size(xx,1))/2;
    options = optimset('MaxIter',200);
    [x,fval]=fminsearch(@(x)lambertSTK(x,vars),[x1,x2],options);

    %% 通过lambert求解，后续加到卫星轨道转移中
    J=lambertSTK(x,vars);
    root.ExecuteCommand('ComponentBrowser */ SetValue "Design Tools" myLambert SequenceName ones'); % 机动序列命名 ones     
    root.ExecuteCommand('ComponentBrowser */ LambertConstructSequence "Design Tools" myLambert');   % 构造机动序列
    root.ExecuteCommand('ComponentBrowser */ LambertAddToCB "Design Tools" myLambert');             % Add to MCS Segment
    root.ExecuteCommand('ComponentBrowser_RM */ GetValue "Design Tools" myLambert InitEpoch');   % 移除默认任务序列
    root.ExecuteCommand(['Astrogator */Satellite/',Sat_best,' SetValue MainSequence.SegmentList ones Propagate']);   % 添加任务序列 ones
    root.ExecuteCommand(['Astrogator */Satellite/',Sat_best,' SetValue MainSequence.SegmentList.Propagate.StoppingConditions Epoch']);   % 设置两种停止条件
    root.ExecuteCommand(['Astrogator */Satellite/',Sat_best,' SetValue MainSequence.SegmentList.Propagate.StoppingConditions.Epoch.TripValue ',StopTime,' UTCG']);
    root.ExecuteCommand(['Astrogator */Satellite/',Sat_best,' SetValue MainSequence.SegmentList.Propagate.Propagator Earth_J2']);
    root.ExecuteCommand(['Astrogator */Satellite/',Sat_best,' RunMCS']);
   
    %% 导出卫星轨道数据
    t_min=floor(x(1));
    mission_start_time=data{t_min,1};% 找到对应时间对应的报告
    data_satA = root.ExecuteCommand(['Report_RM */Satellite/', Sat_name,' Style "J2000 Position Velocity" TimePeriod "',StartTime,'" "',char(mission_start_time),'" TimeStep ',num2str(timeStep)]);
    result = data_satA.Range(1,data_satA.Count);
    T_satA = convertReport(result,true);
    data_best = root.ExecuteCommand(['Report_RM */Satellite/', Sat_best,' Style "J2000 Position Velocity" TimePeriod "',StartTime,'" "',StopTime,'" TimeStep ' num2str(timeStep)]);
    result = data_best.Range(1,data_best.Count);
    T_best = convertReport(result,true);
    T = vertcat(T_satA(1:end-1,:), T_best);
    tleStruct(i).PositionVelocity = T(:,2:7);
    tleStruct(i).raofei = tleStruct(j).SatelliteName;
    tleStruct(i).mission_start_time = mission_start_time;
    tleStruct(i).mission_stop_time = MissionTime;

    %% 进度展示，每完成1个卫星输出一次
    disp(['已完成 ' num2str(i) ' / ' num2str(data_num) ' 个']);
    clear Start_time xx;
end
%% 保存数据
save('./data/FlyAround.mat', 'tleStruct');





