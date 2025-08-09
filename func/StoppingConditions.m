function StoppingConditions(satellite,lan,delta,inclination)
%STOPPINGCONDITIONS 增加停止条件
%   satellite
satellite.Propagator.MainSequence.Remove('Propagate');
satellite.Propagator.MainSequence.Insert('eVASegmentTypePropagate','Apoapsis_EW','-');
Apoapsis_EW=satellite.Propagator.MainSequence.Item(1);
Apoapsis_EW.StoppingConditions.Add('Apoapsis');
Apoapsis_EW.StoppingConditions.Remove('Duration');
Apoapsis_EW.StoppingConditions.Item(0).Properties.RepeatCount=3;
if delta>0
    Apoapsis_EW.StoppingConditions.Item(0).Properties.Sequence='EW Station Keeping';
else
    Apoapsis_EW.StoppingConditions.Item(0).Properties.Sequence='WE Station Keeping';
end

Apoapsis_EW.MaxPropagationTime=10*365.25*86400;
% 建立一个前提条件在东西站点保持的情况，我们将添加一个情况来限制航天器沿着经度的距离，
% 点击该条件的before条件，选择longitude作为停止情况，设置值为13.5deg。
Before=Apoapsis_EW.StoppingConditions.Item(0).Properties.BeforeConditions;
Before.Add('Longitude');
Before.Item(0).Properties.Trip=lan+delta;
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
MaxInclination.Value=inclination+0.2;

% Apoapsis_EW.StoppingConditions.Add('Periapsis');
% Apoapsis_EW.StoppingConditions.Item(2).Properties.RepeatCount=3;
% Apoapsis_EW.StoppingConditions.Item(2).Properties.Sequence='WE Station Keeping';
% Apoapsis_EW.MaxPropagationTime=10*365.25*86400;
% % 建立一个前提条件在东西站点保持的情况，我们将添加一个情况来限制航天器沿着经度的距离，
% % 点击该条件的before条件，选择longitude作为停止情况，设置值为13.5deg。
% Before=Apoapsis_EW.StoppingConditions.Item(2).Properties.BeforeConditions;
% Before.Add('Longitude');
% Before.Item(0).Properties.Trip=raan-0.2;
% % 添加Ascending Node NS Stopping Condition。

% 这样确保了运行会在倾角到达0.45°之前停止。
% 创建一个最大的停止情况。因为最大条件不会运行365天。
satellite.Propagator.MainSequence.Item(1).StoppingConditions.Add('AlwaysTripped');
MaxDuration=satellite.Propagator.MainSequence.Item(1).StoppingConditions.Item(2);
MaxDuration.Name='MaxDuration';
MaxDuration.Properties.Constraints.Add('UserDefined');
MaxDuration.Properties.Constraints.Item(0).Name='MaxDuration';
MaxDuration.Properties.Constraints.Item(0).Criteria='eVACriteriaGreaterThan';
MaxDuration.Properties.Constraints.Item(0).CalcObjectName='Duration';
MaxDuration.Properties.Constraints.Item(0).Value=365*86400;

end

