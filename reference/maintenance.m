%% 素质三连
clear;
clc;
close all;

%% 本文实现卫星保持
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
root.NewScenario('GEOStationKeeping');
StartTime = '1 Apr 2016 00:00:00.000';    % 场景开始时间
StopTime = '18 Jul 2017 00:00:00.000';     % 场景结束时间
root.ExecuteCommand(['SetAnalysisTimePeriod * "',StartTime,'" "',StopTime,'"']);
root.ExecuteCommand(' Animate * Reset');

%% 创建参考卫星
Sat_Name='Reference';
satellite=root.CurrentScenario.Children.New('eSatellite',Sat_Name);
% 创建地球同步轨道卫星，星下点经度为190.0
root.ExecuteCommand(['OrbitWizard */Satellite/',Sat_Name,' Geosynchronous Inclination 0 SubsatellitePoint 13.0 Color green']);
% 使地固系显现出来
satellite.VO.OrbitSystems.FixedByWindow.IsVisible=1;    % 设置固定轨道系统在窗口中可见
satellite.VO.OrbitSystems.InertialByWindow.IsVisible=0; % 设置惯性轨道系统在窗口中不可见
satellite.VO.Proximity.GeoBox.IsVisible=1;  % 设置地理区域接近警告框可见
satellite.VO.Proximity.GeoBox.Longitude=13;  % 设置地理区域的经度
satellite.VO.Proximity.GeoBox.NorthSouth=0.5;   % 设置地理区域的南北跨度
satellite.VO.Proximity.GeoBox.EastWest=0.5; % 设置地理区域的东西跨度
satellite.VO.Proximity.GeoBox.Radius=42166.3;   % 设置地理区域的半径
satellite.Graphics.Attributes.Inherit=0;     % 设置图形属性不继承
satellite.Graphics.Attributes.LabelVisible=0;   % 设置标签不可见
satellite.Graphics.Attributes.IsOrbitVisible=0; % 设置轨道不可见

%% 插入机动星
Sat_Name2='GEO_Sat';
satellite2=root.CurrentScenario.Children.New('eSatellite',Sat_Name2);
satellite2.SetPropagatorType('ePropagatorAstrogator'); 
satellite2.Propagator;
% 初始化卫星的轨道参数
sma=42166.3;  % 半长轴
Ecc=0;        % 偏心率
Inc=0;        % 轨道倾角
w=0;          % 近地点幅角
LonAsc=13;    
TA=352.96;    % 真近点角
root.ExecuteCommand(['Astrogator */Satellite/',Sat_Name2,' SetValue MainSequence.SegmentList Initial_State Propagate']);
InitialState=satellite2.Propagator.MainSequence.Item(0);
root.ExecuteCommand(['Astrogator */Satellite/',Sat_Name2,' SetValue MainSequence.SegmentList.Initial_State.CoordinateType Modified Keplerian']);
root.ExecuteCommand(['Astrogator */Satellite/',Sat_Name2,' SetValue MainSequence.SegmentList.Initial_State.InitialState.Epoch ',StartTime,' UTCG']);
root.ExecuteCommand(['Astrogator */Satellite/',Sat_Name2,' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.sma ',num2str(sma),' km']);
root.ExecuteCommand(['Astrogator */Satellite/',Sat_Name2,' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.ecc ',num2str(Ecc)]);
root.ExecuteCommand(['Astrogator */Satellite/',Sat_Name2,' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.inc ',num2str(Inc),' deg']);
root.ExecuteCommand(['Astrogator */Satellite/',Sat_Name2,' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.w ',num2str(w),' deg']);
root.ExecuteCommand(['Astrogator */Satellite/',Sat_Name2,' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.LAN ',num2str(LonAsc),' deg']);
root.ExecuteCommand(['Astrogator */Satellite/',Sat_Name2,' SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.TA ',num2str(TA),' deg']);

%% 配置卫星传播参数
Propagate=satellite2.Propagator.MainSequence.Item(1);
Propagate.StoppingConditions.Item(0).Properties.Trip=86400*365.25;
Propagate.StoppingConditions.Item(0).Properties.Inherited=0;
% 添加卫星的轨道系统
satellite2.VO.OrbitSystems.Add('Satellite/Reference VVLH System');
% 隐藏轨道系统的惯性坐标系显示
satellite2.VO.OrbitSystems.InertialByWindow.IsVisible=0;
satellite2.VO.Pass.TrackData.PassData.Orbit.SetLeadDataType('eDataNone');
satellite2.VO.Pass.TrackData.PassData.Orbit.SetTrailDataType('eDataTime');
% 设置尾随数据的时间长度为720小时
satellite2.VO.Pass.TrackData.PassData.Orbit.TrailData.Time=720*3600;
% 执行卫星的轨道传播命令
root.ExecuteCommand(['Astrogator */Satellite/',Sat_Name2,' RunMCS']);

%% 选择Inclination，点击Duplicate，重新命名为TOD Inclination。选择坐标系为Earth TOD
% 利用Utilities的菜单，选择Component Browser的选项，选择Calculation Objects的目录，选择Keplerian Elems的目录
root.ExecuteCommand('ComponentBrowser */ Duplicate "Calculation Objects" Inclination "TOD"');
root.ExecuteCommand('ComponentBrowser */ SetValue "Calculation Objects" "TOD" CoordSystem "CentralBody/Earth TOD"');

%% 添加一个East-West位置保持的程序自动序列
% 定义AutoSequence，首先插入一个Sequence，重命名为EW_Station_Keeping。
satellite2.Propagator.AutoSequence.Add('EW Station Keeping');
satellite2.Propagator.AutoSequence.Item(1).Sequence.Insert('eVASegmentTypeSequence','EW_Station_Keeping','-');
EW=satellite2.Propagator.AutoSequence.Item(1).Sequence.Item(0).Segment;
% 在Sequence下面添加一个Propagate，把它命名为Apogee，把Propagate颜色设置为红色，
EW.Insert('eVASegmentTypePropagate','Stop_on_Apogee','-');
EW.Item(0).Properties.Color=255;
% 把其停止情况设置为Apoapsis，取消Duration
stopcondition=EW.Item(0).StoppingConditions;
stopcondition.Add('Apoapsis');
stopcondition.Remove('Duration');
% 添加一个目标序列，命名为Target Turn Around
% 仅在返回段位于目标序列内时可用。返回段在从目标序列配置文件（例如，一个差分校正器）运行时将被忽略，此时该段不活动。
EW.Insert('eVASegmentTypeTargetSequence','Target_Turn_Around','-');
Target=EW.Item(1).Segment;
% 在目标序列下添加一个机动，命名为EW_Burn
Target.Insert('eVASegmentTypeManeuver','EW_Burn','-');
% 在目标序列下添加一个传播序列，命名为Prop to Second Node
Target.Insert('eVASegmentTypePropagate','Prop_to_Second_Node','-');
Prop_to_Second_Node=Target.Item(1);
Prop_to_Second_Node.Properties.Color=42495;
% 在目标序列下添加一个return序列，种类为Enable(except Profiles bypass)
Target.Insert('eVASegmentTypeReturn','return','-');
Return=Target.Item(2);
Return.ReturnControlToParentSequence='eVAReturnControlEnableExceptProfilesBypass';
% 在目标序列下添加一个Propagate，命名为Prop to Asending Nod
Target.Insert('eVASegmentTypePropagate','Prop_to_Asending_Node','-');
Prop_to_Asending_Node=Target.Item(3);
Prop_to_Asending_Node.Properties.Color=65535;
% 修改EW Burn 将其转换为Attitude Control to Thrust Vector，将施加坐标转换为VNC(Earth)，选择X（Velocity）作为控制变量。
Maneuver=Target.Item(0);
Maneuver.Maneuver.SetAttitudeControlType('eVAAttitudeControlThrustVector');
Maneuver.Maneuver.AttitudeControl.ThrustAxesName='Satellite VNC(Earth)';
Maneuver.EnableControlParameter('eVAControlManeuverImpulsiveCartesianX');
% 定义Prop to Second Node部分 。添加一个Ascending Node停止情况。
Prop_to_Second_Node.StoppingConditions.Add('AscendingNode');
Prop_to_Second_Node.StoppingConditions.Remove('Duration');
% 指定在传播停止之前需要达到停止条件多少次
Prop_to_Second_Node.StoppingConditions.Item(0).Properties.RepeatCount=2;
% 选择参考坐标系为Earth TOD。移除Duration情况
Prop_to_Second_Node.StoppingConditions.Item(0).Properties.CoordSystem='CentralBody/Earth TOD';
% 定义Prop to Ascending Node部分，添加一个Ascending Node停止情况，
% 将坐标设置为TOD，添加约束条件，选择UserDefined选项，将其重新命名为Min_Longitude，
% 将Criteria的值设置为Greater Than Minimum。
% 将CalcObject设置为Geodetc>Longitude，将Tolerance设置为0.05；
Prop_to_Asending_Node.StoppingConditions.Add('AscendingNode');
Prop_to_Asending_Node.StoppingConditions.Item(1).Properties.CoordSystem='CentralBody/Earth TOD';
Prop_to_Asending_Node.StoppingConditions.Item(1).Properties.Constraints.Add('UserDefined');
Prop_to_Asending_Node.StoppingConditions.Item(1).Properties.Constraints.Item(0).Name='Min_Longitude';
Prop_to_Asending_Node.StoppingConditions.Item(1).Properties.Constraints.Item(0).Criteria='eVACriteriaGreaterThanMinimum';
Prop_to_Asending_Node.StoppingConditions.Item(1).Properties.Constraints.Item(0).CalcObjectName='Longitude';
Prop_to_Asending_Node.StoppingConditions.Item(1).Properties.Constraints.Item(0).Tolerance=0.05;
Prop_to_Asending_Node.StoppingConditions.Remove('Duration');
% 选择结果，选择Prop to Ascending Node部分。
% 添加Math作为独立的变量，改变ComponentName名字为Minimum_Longitude，将计算对象设置为Longitude。
Prop_to_Asending_Node.Results.Add('Minimum_Value');
Prop_to_Asending_Node.Results.Item(0).Name='Minimum_longitude';
Prop_to_Asending_Node.Results.Item(0).CalcObjectName='Longitude';
% 选择目标序列，打开Differential Corrector。
% 将ImpulsiveMnver.Cartesian.X的组件作为控制参数。
% 选择Pertubation为0.01m/s，MaxStep为1m/s。
% 这个卫星将会进行小的调整来保持轨道，我们想要我们最大步长和摄动在一个小的规模下。
% 将Minimum_Longitude作为结果，将期望值调整到12.55°。
% 这颗卫星在它机动期间会保持在盒子里，我们允许保护边界来设置我们期望的值到12.55°，将Tolerance设置为0.001deg，
% 将Action field设置为Run active profiles
Differential=EW.Item(1).Profiles.Item(0);
ControlParameters=Differential.ControlParameters;
Results=Differential.Results;
Vx=ControlParameters.Item(0);
Vx.Enable=1;
Vx.Perturbation=0.01;
Vx.MaxStep=1;
Min_lon=Results.Item(0);
Min_lon.Enable=1;
Min_lon.DesiredValue=12.5;
Min_lon.Tolerance=0.001;
EW.Item(1).Action='eVATargetSeqActionRunActiveProfiles';

%% 添加南北位置保持部分
satellite2.Propagator.AutoSequence.Add('NS Station Keeping');
satellite2.Propagator.AutoSequence.Item(2).Sequence.Insert('eVASegmentTypeTargetSequence','NS_SK_Drift','-');
NS=satellite2.Propagator.AutoSequence.Item(2).Sequence.Item(0).Segment;
NS.Insert('eVASegmentTypeManeuver','NS_Burn','-');
% 将姿态控制设置为Thrust Vector，设置控制系为VNC(Earth)，选择X和Y作为的控制变量，设置Y为-200m/s。
% 定义结果为NS Burn部分，选择结果为Math-Difference作为变量，选择ComponentName为SMA_Diff。
% 改变CalcObject为Semimajor Axis。设置DifferenceOrder为CurrentMinusInitial。
% 将Elems>TOD Inclination为second component variable.s
Maneuver2=NS.Item(0);
Maneuver2.Maneuver.SetAttitudeControlType('eVAAttitudeControlThrustVector');
Maneuver2.EnableControlParameter('eVAControlManeuverImpulsiveCartesianX');
Maneuver2.EnableControlParameter('eVAControlManeuverImpulsiveCartesianY');
% Maneuver2.Maneuver.FiniteMnvr.Cartesian.Y=-200;
% 定义边界条件
Maneuver2.Results.Add('Difference');
Maneuver2.Results.Item(0).Name='SMA_Diff';
Maneuver2.Results.Item(0).DifferenceOrder='eVADifferenceOrderCurrentMinusInitial';
Maneuver2.Results.Item(0).CalcObjectName='Semimajor Axis';
Maneuver2.Results.Add('TOD');
%定义Thrust Component
% 选择NS SK Drift。双击Differential Corrector，将ImpulsiveMnvr.Cartesian.X,Y。
% 将X，Y component，摄动设置为0.1m/s，最大步数为10m/s。
% 同时设置好SMA_Diff的期望值为0，允许程度为0.01km。
% 将生成模式改为By tolerance，将模式改为Run Active Profiles
Differential2=satellite2.Propagator.AutoSequence.Item(2).Sequence.Item(0).Profiles.Item(0);
ControlParameters2=Differential2.ControlParameters;
Results2=Differential2.Results;
Vx=ControlParameters2.Item(0);
Vx.Enable=1;
Vx.Perturbation=0.1;
Vx.MaxStep=10;
Vy=ControlParameters2.Item(1);
Vy.Enable=1;
Vy.Perturbation=0.1;
Vy.MaxStep=10;
SMA_Diff=Results2.Item(0);
SMA_Diff.Enable=1;
SMA_Diff.DesiredValue=0;
SMA_Diff.Tolerance=0.01;
SMA_Diff.ScalingMethod='eVADCScalingMethodTolerance';
TOD=Results2.Item(1);
TOD.Enable=1;
TOD.DesiredValue=0;
TOD.Tolerance=0.001;
TOD.ScalingMethod='eVADCScalingMethodTolerance';
satellite2.Propagator.AutoSequence.Item(2).Sequence.Item(0).Action='eVATargetSeqActionRunActiveProfiles';

%% 创造额外的停止时间
% 在定义两个站位保持的自动序列后，我们现在专注于主序列部分。
% 我们将添加新的停止条件来限制卫星如何工作。在同时两件事情发生。
% 卫星接近了GEO盒子到达东边界，EW StationKeeping机动被需求。卫星接近了GEO盒子到达南边界。
% 一个NS StationKeeping机动被需求
% 创建一个额外的停止条件。把GEO_Sat's卫星的Orbit，选择Propagate部分，添加Apoapsis停止条件，把它命名为Apoapsis EW。
% 在Sequence部分EW Station Keeping，将重复次数设置为3次，选择最大预报时间10yr。选择OK关闭。
satellite2.Propagator.MainSequence.Remove('Propagate');
satellite2.Propagator.MainSequence.Insert('eVASegmentTypePropagate','Apoapsis_EW','-');
Apoapsis_EW=satellite2.Propagator.MainSequence.Item(1);
Apoapsis_EW.StoppingConditions.Add('Apoapsis');
Apoapsis_EW.StoppingConditions.Remove('Duration');
Apoapsis_EW.StoppingConditions.Item(0).Properties.RepeatCount=3;
Apoapsis_EW.StoppingConditions.Item(0).Properties.Sequence='EW Station Keeping';
Apoapsis_EW.MaxPropagationTime=10*365.25*86400;
% 建立一个前提条件在东西站点保持的情况，我们将添加一个情况来限制航天器沿着经度的距离，
% 点击该条件的before条件，选择longitude作为停止情况，设置值为13.5deg。
Before=Apoapsis_EW.StoppingConditions.Item(0).Properties.BeforeConditions;
Before.Add('Longitude');
Before.Item(0).Properties.Trip=13.5;
% 添加Ascending Node NS Stopping Condition。

% 接下来添加一个停止情况触发North South StationKeeping 自由序列。
% 添加一个AscendingNode停止情况，命名为AscendingNode NS，选择序列为NS Station Keeping。
% 将坐标系设置为Earth TOD。设置最大时间为10yr。
Apoapsis_EW.StoppingConditions.Add('AscendingNode');
Apoapsis_EW.StoppingConditions.Item(1).Properties.Sequence='NS Station Keeping';
Apoapsis_EW.StoppingConditions.Item(1).Properties.CoordSystem='CentralBody/Earth TOD';
% 添加一个约束条件为NS Station Keeping。
% 我们将添加一个约束条件来限制航天器的轨道倾角。
% 选择该约束条件为UserDefined，双击ComponentName，改名为MaxInclination。
% 选择Criteria为Great than。
% 将CalcObject换成Keplerian TOD Inclination，将坐标系设置为Earth TOD坐标系，最后设置Values为0.45°
Constraint1=Apoapsis_EW.StoppingConditions.Item(1).Properties.Constraint;
Constraint1.Add('UserDefined');
Constraint1.Item(0).Name='MaxInclination';
Constraint1.Item(0).Criteria='eVACriteriaGreaterThan';
MaxInclination=Constraint1.Item(0);
MaxInclination.CalcObjectName='TOD';
MaxInclination.Value=0.5;
% 这样确保了运行会在倾角到达0.45°之前停止。
% 创建一个最大的停止情况。因为最大条件不会运行450天。
satellite2.Propagator.MainSequence.Item(1).StoppingConditions.Add('AlwaysTripped');
MaxDuration=satellite2.Propagator.MainSequence.Item(1).StoppingConditions.Item(2);
MaxDuration.Name='MaxDuration';
MaxDuration.Properties.Constraints.Add('UserDefined');
MaxDuration.Properties.Constraints.Item(0).Name='MaxDuration';
MaxDuration.Properties.Constraints.Item(0).Criteria='eVACriteriaGreaterThan';
MaxDuration.Properties.Constraints.Item(0).CalcObjectName='Duration';
MaxDuration.Properties.Constraints.Item(0).Value=360*86400;
% Clear Graphic 点击运行MCS，再点击Clear Graphic来移除画好的轨迹
root.ExecuteCommand(['Astrogator */Satellite/',Sat_Name2,' RunMCS']);
root.ExecuteCommand(['Astrogator */Satellite/',Sat_Name2,' ClearDWCGraphics']);

% %% 关闭
% uiApplication.Quit;
% clear uiApplication root

