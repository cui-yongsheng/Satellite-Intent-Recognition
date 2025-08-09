%% 素质三连
clear;
clc;
close all;
global root xx

%% 本文实现兰伯特制导，末位置为对目标绕飞所需要的时间和地点
% 创建或获取正在运行的STK应用程序实例
uiApplication = actxserver('STK11.application');
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
root.NewScenario('FlyAroundOptimal');  % 创建一个新的场景，名称为'FlayAroundOptimal'
StartTime = '26 Jan 2024 04:00:00.000';    % 场景开始时间
StopTime = '10 Feb 2024 04:00:00.000';     % 场景结束时间
time_step = 60;                          % 定义仿真时间间隔为60秒
root.ExecuteCommand(['SetAnalysisTimePeriod * "',StartTime,'" "',StopTime,'"']);

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

%% 给出到达目标星的时间确定绕飞的位置 
Mission_time='5 Feb 2024 04:00:00';     %在给定任务的第十天要求到达该位置

%% 利用STK报表的方式生成一个该时刻绕飞的卫星
VMC_SatName='raofei';
miu=3.986e5;            % 地球引力常数
omega=2*pi/86169.6;     % 卫星角速度，卫星轨道周期86169.6sec
z=10;                   % 绕飞短半轴
dx=2*omega*z;           % 计算绕飞椭圆的X轴速度分量(科里奥利力)

%% 利用CW方程选择能绕飞的点
% https://blog.csdn.net/weixin_57997461/article/details/136787786
t=0:time_step:86169.6;
X=[0,0,z,dx,0,0]';      % 初始状态向量，包含位置和速度
xx=zeros(length(t),6);  % 创建一个6列的矩阵，用于保存结果
for i=1:length(t)
    t=(i-1)*60;
    xx(i,:)=CW(X,omega,t);
end

%% 利用STK报表的方式生成一个该时刻绕飞的卫星
satellite3= root.CurrentScenario.Children.New('eSatellite', VMC_SatName);
satellite3.SetPropagatorType('ePropagatorAstrogator'); 
satellite3.Propagator;
root.ExecuteCommand('ComponentBrowser */ Duplicate "Design Tools" "Lambert Solver" myLambert');

%% 利用函数优化的方法找到最优机动时刻以及最优入轨点，已知初始出发时间为26 Jan 2024 04:00:00.000 
options = optimset('Display','iter','MaxIter',200,'PlotFcns',@optimplotfval);
[x,fval]=fminsearch(@lambert3,[9000,4],options);
disp(['最优机动时间为：',num2str(x(1)),'秒']);
disp(['最优机动入轨点为：',num2str(x(2))]);

%% 将最优结果呈现在STK中
% https://blog.csdn.net/weixin_57997461/article/details/136720238
J=lambert3(x);  % 通过lambert求解，后续加到卫星轨道转移中
root.ExecuteCommand('ComponentBrowser */ SetValue "Design Tools" myLambert SequenceName ones'); % 机动序列命名 ones     
root.ExecuteCommand('ComponentBrowser */ LambertConstructSequence "Design Tools" myLambert');   % 构造机动序列
root.ExecuteCommand('ComponentBrowser */ LambertAddToCB "Design Tools" myLambert');             % Add to MCS Segment
% satellite1.Unload;  % 卸载卫星1
Sat_best='blue_best';
satellite4= root.CurrentScenario.Children.New('eSatellite', Sat_best);  % 在当前场景中新建卫星
satellite4.SetPropagatorType('ePropagatorAstrogator');  % 设置卫星的轨道传播器类型
satellite4.Propagator;
root.ExecuteCommand('ComponentBrowser_RM */ GetValue "Design Tools" myLambert InitEpoch');   % 移除默认任务序列
root.ExecuteCommand('Astrogator */Satellite/blue_best SetValue MainSequence.SegmentList ones Propagate');   % 添加任务序列 ones
root.ExecuteCommand('Astrogator */Satellite/blue_best SetValue MainSequence.SegmentList.Propagate.StoppingConditions Epoch');   % 设置两种停止条件
root.ExecuteCommand(['Astrogator */Satellite/blue_best SetValue MainSequence.SegmentList.Propagate.StoppingConditions.Epoch.TripValue ',StopTime,' UTCG']);
root.ExecuteCommand('Astrogator */Satellite/blue_best SetValue MainSequence.SegmentList.Propagate.Propagator Earth_J2');
root.ExecuteCommand('Astrogator */Satellite/blue_best RunMCS');

%% 找出机动时间与消耗脉冲的关系
%% 不显示红方和蓝方的固定坐标系下的轨迹
root.ExecuteCommand('VO */Satellite/raofei OrbitSystem Modify System "InertialByWindow" Show Off');
root.ExecuteCommand('VO */Satellite/raofei OrbitSystem Add System VVLH Satellite/target Color red');
root.ExecuteCommand('VO */Satellite/target OrbitSystem Modify System "InertialByWindow" Show Off');
root.ExecuteCommand('VO */Satellite/blue_best OrbitSystem Add System VVLH Satellite/target Color red');