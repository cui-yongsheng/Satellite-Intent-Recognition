%% 素质三连
clear;
clc;
close all;
global End_rx End_ry End_rz End_vx End_vy End_vz root

%% 本文实现兰伯特制导，末位置为对目标绕飞所需要的时间和地点
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

%% 根据你的需要设定场景的名称
root.NewScenario('FlayAround');
StartTime = '26 Jan 2024 04:00:00.000';    % 场景开始时间
StopTime = '10 Feb 2024 04:00:00.000';     % 场景结束时间
time_step = 60;       % 定义仿真时间间隔为60秒
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

%% 给出到达目标星的时间确定绕飞的位置 
Mission_time='5 Feb 2024 04:00:00';
data_red=root.ExecuteCommand(['Report_RM */Satellite/target Style "Inertial Position Velocity" TimePeriod "',StartTime,'" "',Mission_time,'" TimeStep ',num2str(time_step)]);
data_Line=data_red.count;
for i=1:data_Line-2
    struct=regexp(data_red.Item(i),',','split');
    End_time(i)=struct(1);
end
End_time_str=string(End_time(end));% 找到对应时间对应的报告
for i=1:data_Line-2
    struct=regexp(data_red.Item(i),',','split');
    time_end=string(struct(1));
    if time_end==End_time_str
        End_rx=str2double(cell2mat(struct(2)));
        End_ry=str2double(cell2mat(struct(3)));
        End_rz=str2double(cell2mat(struct(4)));
        End_vx=str2double(cell2mat(struct(5)));
        End_vy=str2double(cell2mat(struct(6)));
        End_vz=str2double(cell2mat(struct(7)));
        break
    else
        continue
    end
end


%% 利用STK报表的方式生成一个该时刻绕飞的卫星
VMC_SatName='raofei';
% https://blog.csdn.net/u011575168/article/details/116991086
R_norm=sqrt(End_rx^2+End_ry^2+End_rz^2);    % 计算卫星位置矢量的模
V_norm=sqrt(End_vx^2+End_vy^2+End_vz^2);    % 计算卫星速度矢量的模
R_vec=[End_rx,End_ry,End_rz]/R_norm;        % 卫星位置单位矢量
V_vec=[End_vx,End_vy,End_vz]/V_norm;        % 卫星速度单位矢量
Z_vec=-R_vec;                               % 卫星Z轴矢量
Y_vec=cross(Z_vec,V_vec);                   % 卫星Y轴矢量
X_vec=cross(Y_vec,Z_vec);                   % 卫星X轴矢量
miu=3.986e5;                                % 地球引力常数
omega=sqrt(miu/R_norm^3);                   % 计算卫星的角速度
z=10;                                       % 绕飞短半轴
dx=2*omega*z;                               % 计算绕飞椭圆的X轴速度分量(科里奥利力)
satellite3= root.CurrentScenario.Children.New('eSatellite', VMC_SatName);
satellite3.SetPropagatorType('ePropagatorAstrogator'); 
satellite3.Propagator;
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList Initial_State Propagate');   % 将初始状态设置为传播模式
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.CoordinateSystem "Satellite/target VVLH"'); % 设置坐标系为“VVLH”
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.CoordinateType Cartesian'); % 设置坐标类型为笛卡尔坐标
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.X 0 km');   % X轴方向的初始位置为0公里
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Y 0 km');   % Y轴方向的初始位置为0公里
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Z 10 km');  % Z轴方向的初始位置为10公里
root.ExecuteCommand(['Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Vx ',num2str(dx),' km/sec']); % X轴方向的初始速度为dx
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Vy 0 km/sec'); % Y轴方向的初始速度为0公里/秒
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Vz 0 km/sec'); % Z轴方向的初始速度为0公里/秒
root.ExecuteCommand(['Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.InitialState.Epoch ',Mission_time,' UTCG']); % 设置初始历元（Epoch）时间为任务时间
root.ExecuteCommand('Astrogator */Satellite/raofei RunMCS'); % 运行Astrogator模块的Monte Carlo仿真
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Propagate.StoppingConditions Epoch'); % 设置传播器的停止条件为指定历元时间
root.ExecuteCommand(['Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Propagate.StoppingConditions.Epoch.TripValue ',StopTime,' UTCG']);% 设置传播结束时间
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Propagate.Propagator Earth_J2'); % 设置传播器模型为地球J2模型
% 该绕飞卫星的初始时刻位置，即为LAMBERT航天器需要到达的末端位置
data_raofei=root.ExecuteCommand(['Report_RM */Satellite/raofei Style "Inertial Position Velocity" TimePeriod "',Mission_time,'" "',StopTime,'" TimeStep 3600']);
struct=regexp(data_raofei.Item(1),',','split');
End_rx=str2double(cell2mat(struct(2)));
End_ry=str2double(cell2mat(struct(3)));
End_rz=str2double(cell2mat(struct(4)));
End_vx=str2double(cell2mat(struct(5)));
End_vy=str2double(cell2mat(struct(6)));
End_vz=str2double(cell2mat(struct(7)));
root.ExecuteCommand('ComponentBrowser */ Duplicate "Design Tools" "Lambert Solver" myLambert');

%% 利用函数优化的方法找到最优机动时刻，已知初始出发时间为26 Jan 2024 04:00:00.000 
lb=0;ub=9*24*60;
options = optimset('Display','iter','MaxIter',200,'PlotFcns',@optimplotfval);
[x,fval]=fminbnd(@lambert2,lb,ub,options);
% 输出最优解和目标函数值
fprintf('最优机动时间为：%d 分钟\n', x);
fprintf('最小脉冲值为：%.4f\n', fval);