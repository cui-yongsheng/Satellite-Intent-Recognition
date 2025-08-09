function StationKeepingWE(satellite,lan,delta)
%WESTATIONKEEPING 东西经度保持
%   satellite
%% 添加一个East-West位置保持的程序自动序列
% 定义AutoSequence，首先插入一个Sequence，重命名为WE_Station_Keeping。
satellite.Propagator.AutoSequence.Add('WE Station Keeping');
satellite.Propagator.AutoSequence.Item(1).Sequence.Insert('eVASegmentTypeSequence','WE_Station_Keeping','-');
WE=satellite.Propagator.AutoSequence.Item(1).Sequence.Item(0).Segment;
% 在Sequence下面添加一个Propagate，把它命名为Apogee，把Propagate颜色设置为红色，
WE.Insert('eVASegmentTypePropagate','Stop_on_Apogee','-');
% 把其停止情况设置为Apoapsis，取消Duration
stopcondition=WE.Item(0).StoppingConditions;
stopcondition.Add('Apoapsis');
stopcondition.Remove('Duration');
% 添加一个目标序列，命名为Target Turn Around
% 仅在返回段位于目标序列内时可用。返回段在从目标序列配置文件（例如，一个差分校正器）运行时将被忽略，此时该段不活动。
WE.Insert('eVASegmentTypeTargetSequence','Target_Turn_Around','-');
Target=WE.Item(1).Segment;
% 在目标序列下添加一个机动，命名为WE_Burn
Target.Insert('eVASegmentTypeManeuver','WE_Burn','-');
% 在目标序列下添加一个传播序列，命名为Prop to Second Node
Target.Insert('eVASegmentTypePropagate','Prop_to_Second_Node','-');
Prop_to_Second_Node=Target.Item(1);
% 在目标序列下添加一个return序列，种类为Enable(except Profiles bypass)
Target.Insert('eVASegmentTypeReturn','return','-');
Return=Target.Item(2);
Return.ReturnControlToParentSequence='eVAReturnControlEnableExceptProfilesBypass';
% 在目标序列下添加一个Propagate，命名为Prop to Asending Nod
Target.Insert('eVASegmentTypePropagate','Prop_to_Descending_Node','-');
Prop_to_Descending_Node=Target.Item(3);
% 修改WE Burn 将其转换为Attitude Control to Thrust Vector，将施加坐标转换为VNC(Earth)，选择X（Velocity）作为控制变量。
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
Prop_to_Descending_Node.StoppingConditions.Add('AscendingNode');
Prop_to_Descending_Node.StoppingConditions.Item(1).Properties.CoordSystem='CentralBody/Earth TOD';
Prop_to_Descending_Node.StoppingConditions.Item(1).Properties.Constraints.Add('UserDefined');
Prop_to_Descending_Node.StoppingConditions.Item(1).Properties.Constraints.Item(0).Name='Max_Longitude';
Prop_to_Descending_Node.StoppingConditions.Item(1).Properties.Constraints.Item(0).Criteria='eVACriteriaLessThanMaximum';
Prop_to_Descending_Node.StoppingConditions.Item(1).Properties.Constraints.Item(0).CalcObjectName='Longitude';
Prop_to_Descending_Node.StoppingConditions.Item(1).Properties.Constraints.Item(0).Tolerance=0.05;
Prop_to_Descending_Node.StoppingConditions.Remove('Duration');
% 选择结果，选择Prop to Ascending Node部分。
% 添加Math作为独立的变量，改变ComponentName名字为Minimum_Longitude，将计算对象设置为Longitude。
Prop_to_Descending_Node.Results.Add('Maximum_Value');
Prop_to_Descending_Node.Results.Item(0).Name='Maximum_longitude';
Prop_to_Descending_Node.Results.Item(0).CalcObjectName='Longitude';
% 选择目标序列，打开Differential Corrector。
% 将ImpulsiveMnver.Cartesian.X的组件作为控制参数。
% 选择Pertubation为0.01m/s，MaxStep为1m/s。
% 这个卫星将会进行小的调整来保持轨道，我们想要我们最大步长和摄动在一个小的规模下。
% 将Minimum_Longitude作为结果，将期望值调整到13.55°。
% 这颗卫星在它机动期间会保持在盒子里，我们允许保护边界来设置我们期望的值到13.55°，将Tolerance设置为0.001deg，
% 将Action field设置为Run active profiles
Differential=WE.Item(1).Profiles.Item(0);
ControlParameters=Differential.ControlParameters;
Results=Differential.Results;
Vx=ControlParameters.Item(0);
Vx.Enable=1;
Vx.Perturbation=0.01;
Vx.MaxStep=1;
Max_lon=Results.Item(0);
Max_lon.Enable=1;
Max_lon.DesiredValue=lan+delta;
Max_lon.Tolerance=0.001;
WE.Item(1).Action='eVATargetSeqActionRunActiveProfiles';
end

