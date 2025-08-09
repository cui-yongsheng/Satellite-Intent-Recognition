%% 素质三连
clear;
clc;
close all;

%% 利用STK自带的LAMBERT库来实现目标拦截（交会）
% 创建或获取正在运行的STK应用程序实例
uiApplication = actxGetRunningServer('STK11.application');
% 获取IAgStkObjectRoot接口，用于操作STK对象模型的根
root = uiApplication.Personality2;
% 检查当前是否有打开的场景，以决定是否需要卸载或关闭当前场景
checkempty = root.Children.Count;
% 如果存在未卸载的场景，则卸载并关闭当前场景，确保环境清洁以开始新的操作
if checkempty ~= 0
    root.CurrentScenario.Unload
    root.CloseScenario;
end


%% 设定场景名称
root.NewScenario('Rendezvous');            % 创建一个名为'Rendezvous'的新场景
StartTime = '26 Jan 2024 04:00:00.000';    % 定义场景的开始时间
StopTime = '10 Feb 2024 04:00:00.000';     % 定义场景的结束时间
time_step = '60';       % 定义仿真时间间隔为60秒
% 设置场景的仿真时间段
root.ExecuteCommand(['SetAnalysisTimePeriod * "',StartTime,'" "',StopTime,'"']);
root.ExecuteCommand(' Animate * Reset');  % 重置动画

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
root.ExecuteCommand(['Astrogator */Satellite/target SetValue MainSequence.SegmentList.Propagate.StoppingConditions.Epoch.TripValue ',StopTime,' UTCG']);%
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

%% 根据红方的初始状态得到设置的轨道机动的终点
% 定义任务时间参数
number_time=4320;   % 经历4320分钟，即29 Jan 04:00:00.000到达
sec=4320*60;
% 整个任务的时间从26 Jan 2024 04:00:00.000 到 10 Feb 2024 04:00:00.000
mission_day=15;
mission_minute=15*24*60;
% 根据给定的时间，获得其最终位置
data_red=root.ExecuteCommand(['Report_RM */Satellite/target Style "Inertial Position Velocity" TimePeriod "',StartTime,'" "',StopTime,'" TimeStep ',num2str(time_step)]);
% 定义开始时间的字符串格式
starttime='2024-1-26 04:00:00';
% 将开始时间字符串转化为datetime格式，因为datetime函数无法直接读取StartTime变量的写法
time=datetime(starttime);
% 创建一个从1到任务分钟数的分钟序列
minute=minutes(1:mission_minute);
% 通过开始时间加上分钟序列，计算出每个时间点，这是为了后面能够根据number_time变换时间做准备
option_fixtime=time+minute;
% 根据特定的值number_time来获取其末端位置的时间
time_end=datestr(option_fixtime(number_time));
% 将时间字符串中的连字符替换为空格，以与STK软件的时间格式匹配
time_end=strrep(time_end,'-',' ');
% 在时间字符串末尾添加'.000'，以与STK软件的时间格式匹配
time_end=string(time_end)+'.000';
% 获取data_red对象的计数属性，用于后续处理
data_Line=data_red.count;
for i=1:data_Line-2
    struct=regexp(data_red.Item(i),',','split');
    End_time=string(struct(1));
    if End_time==time_end 
        End_rx=cell2mat(struct(2));
        End_ry=cell2mat(struct(3));
        End_rz=cell2mat(struct(4));
        End_vx=cell2mat(struct(5));
        End_vy=cell2mat(struct(6));
        End_vz=cell2mat(struct(7));
        break
    else
        continue
    end
end

%% 调用STK的Design tools，来完成整个问题的求解
root.ExecuteCommand(['ComponentBrowser */ Duplicate "Design Tools" "Lambert Solver" myLambert']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert InitEpoch "',StartTime,'" UTCG']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert InitPosVel.Rx ',num2str(rx),' km']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert InitPosVel.Ry ',num2str(ry),' km']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert InitPosVel.Rz ',num2str(rz),' km']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert InitPosVel.Vx ',num2str(vx),' km*sec^-1']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert InitPosVel.Vy ',num2str(vy),' km*sec^-1']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert InitPosVel.Vz ',num2str(vz),' km*sec^-1']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert FinlPosVel.Rx ',num2str(End_rx),' km']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert FinlPosVel.Ry ',num2str(End_ry),' km']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert FinlPosVel.Rz ',num2str(End_rz),' km']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert FinlPosVel.Vx ',num2str(End_vx),' km*sec^-1']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert FinlPosVel.Vy ',num2str(End_vy),' km*sec^-1']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert FinlPosVel.Vz ',num2str(End_vz),' km*sec^-1']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert MinimumTOF ',num2str(sec), ' sec']);
root.ExecuteCommand('ComponentBrowser */ LambertCompute "Design Tools" myLambert');

%% 获取整个机动过程的总脉冲变量
result=root.ExecuteCommand(['ComponentBrowser_RM */ GetValue "Design Tools" myLambert LambertResult']);
total_delta=result.Item(23);
% 查找总脉冲消耗值的起始位置
V_begin=strfind(total_delta,'=');
% 查找总脉冲消耗值的结束位置
V_end=strfind(total_delta,'m*sec^-1');
% 将找到的脉冲消耗值从字符串转换为数值
delta_all=str2num(total_delta(V_begin+1:V_end-1));
fprintf('转移时间为%.4f sec，消耗的总脉冲为%.4f m/s\n',sec,delta_all);