%% 素质三连
clear;
clc;
close all;
global root rx ry rz vx vy vz; % 声明全局变量
%% 利用STK自带的LAMBERT库来实现目标拦截（交会）
% 创建或获取正在运行的STK应用程序实例
uiApplication = actxGetRunningServer('STK11.application');
% 获取IAgStkObjectRoot接口，用于操作STK对象模型的根
root = uiApplication.Personality2;
% 检查当前是否有打开的场景，以决定是否需要卸载或关闭当前场景
checkempty = root.Children.Count;
% 如果存在未卸载的场景，则卸载并关闭当前场景，确保环境清洁以开始新的操作
if checkempty ~= 0
    root.CurrentScenario.Unload;
    root.CloseScenario;
end

%% 根据你的需要设定场景的名称
root.NewScenario('RendezvousOptimal');     % 创建一个名为'RendezvousOptimal'的新场景
StartTime = '26 Jan 2024 04:00:00.000';    % 场景开始时间
StopTime = '10 Feb 2024 04:00:00.000';     % 场景结束时间
root.ExecuteCommand(['SetAnalysisTimePeriod * "',StartTime,'" "',StopTime,'"']);
root.ExecuteCommand(' Animate * Reset');

%% 生成蓝方星和拦截红方星的初始轨道数据
% 创建蓝方星，类型为eSatellite，名称为'blue'
Sat_name1='blue';     % 定义第一个卫星的名称
satellite1= root.CurrentScenario.Children.New('eSatellite', Sat_name1);
satellite1.SetPropagatorType('ePropagatorAstrogator');  % 设置卫星的轨道传播器类型
satellite1.Propagator;   % 调用卫星的传播器
% 初始化卫星轨道参数
e=0;Sat_TA=0;Sat_LAN=165;
% 设置Astrogator模块的初始状态和传播参数
root.ExecuteCommand('Astrogator */Satellite/blue SetValue MainSequence.SegmentList Initial_State Propagate');   % 从初始状态进行轨道传播。
root.ExecuteCommand('Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.CoordinateType Modified Keplerian'); % 初始状态坐标类型为修正开普勒轨道
root.ExecuteCommand(['Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Epoch ',StartTime,' UTCG']);    % 设置初始历元（Epoch）时间
root.ExecuteCommand('Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.ElementType "Kozai-Izsak Mean"');   % 开普勒轨道要素类型为 Kozai-Izsak 平根数轨道元素
root.ExecuteCommand('Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.Period 86169.6 sec');   % 设置轨道周期为 86169.6 秒
root.ExecuteCommand(['Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.ecc ',num2str(e)]);    % 设置轨道偏心率
root.ExecuteCommand('Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.inc 0 deg');    % 设置轨道倾角
root.ExecuteCommand('Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.w 0 deg');  % 设置近地点幅角
root.ExecuteCommand(['Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.TA ',num2str(Sat_TA),' deg']); % 设置真近点角
root.ExecuteCommand(['Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.LAN ',num2str(Sat_LAN),' deg']);   % 设置升交点赤经
root.ExecuteCommand('Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Propagate.StoppingConditions Epoch');    % 设置传播器的停止条件为指定历元时间
root.ExecuteCommand(['Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Propagate.StoppingConditions.Epoch.TripValue ',StopTime,' UTCG']); % 设置传播结束时间
root.ExecuteCommand('Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Propagate.Propagator Earth_J2'); % 设置传播器模型
root.ExecuteCommand('Astrogator */Satellite/blue RunMCS');
% 创建并配置目标卫星，类型为eSatellite，名称为'target'
Sat_name2='target';
satellite2= root.CurrentScenario.Children.New('eSatellite', Sat_name2);
satellite2.SetPropagatorType('ePropagatorAstrogator'); 
satellite2.Propagator;
% 初始化卫星轨道参数
e=0;Sat_TA=0;Sat_LAN=105;
% 设置Astrogator模块的初始状态和传播参数
root.ExecuteCommand('Astrogator */Satellite/target SetValue MainSequence.SegmentList Initial_State Propagate');
root.ExecuteCommand('Astrogator */Satellite/target SetValue MainSequence.SegmentList.Initial_State.CoordinateType Modified Keplerian');
root.ExecuteCommand(['Astrogator */Satellite/target SetValue MainSequence.SegmentList.Initial_State.InitialState.Epoch ',StartTime,' UTCG']);
root.ExecuteCommand('Astrogator */Satellite/target SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.ElementType "Kozai-Izsak Mean"');
root.ExecuteCommand('Astrogator */Satellite/target SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.Period 86169.6 sec');
root.ExecuteCommand(['Astrogator */Satellite/target SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.ecc ',num2str(e)]);
root.ExecuteCommand('Astrogator */Satellite/target SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.inc 0 deg');
root.ExecuteCommand('Astrogator */Satellite/target SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.w 0 deg');
root.ExecuteCommand(['Astrogator */Satellite/target SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.TA ',num2str(Sat_TA),' deg']);
root.ExecuteCommand(['Astrogator */Satellite/target SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.LAN ',num2str(Sat_LAN),' deg']);
root.ExecuteCommand('Astrogator */Satellite/target SetValue MainSequence.SegmentList.Propagate.StoppingConditions Epoch');
root.ExecuteCommand(['Astrogator */Satellite/target SetValue MainSequence.SegmentList.Propagate.StoppingConditions.Epoch.TripValue ',StopTime,' UTCG']);
root.ExecuteCommand('Astrogator */Satellite/target SetValue MainSequence.SegmentList.Propagate.Propagator Earth_J2');
root.ExecuteCommand('Astrogator */Satellite/target RunMCS');

%% 根据蓝方的初始状态得到设置的轨道机动的起点
% 通过执行命令获取蓝方卫星在惯性坐标系中的位置和速度信息
data_blue=root.ExecuteCommand(['Report_RM */Satellite/blue Style "Inertial Position Velocity" TimePeriod "',StartTime,'" "',StopTime,'" TimeStep 3600']);
% 对获取的数据进行处理，提取位置和速度信息
struct=regexp(data_blue.Item(1),',','split');
rx=str2double(cell2mat(struct(2)));
ry=str2double(cell2mat(struct(3)));
rz=str2double(cell2mat(struct(4)));
vx=str2double(cell2mat(struct(5)));
vy=str2double(cell2mat(struct(6)));
vz=str2double(cell2mat(struct(7)));
root.ExecuteCommand('ComponentBrowser */ Duplicate "Design Tools" "Lambert Solver" myLambert');

%% 遗传算法计算最优机动时刻
% 输入参考范围：lb=24*60;ub=15*24*60;
x0 = 9000; % 初始猜测值
options = optimset('Display','iter','MaxIter',200,'PlotFcns',@optimplotfval);
% Todo: 运行优化，parfeval
[x,fval] = fminsearch(@lambert,x0,options);
% 输出最优解和目标函数值
fprintf('最优机动时间为：%d 分钟\n', x);
fprintf('最小脉冲值为：%.4f\n', fval);