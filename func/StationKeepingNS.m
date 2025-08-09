function StationKeepingNS(satellite,inclination)
%NSStationKeeping 轨道倾角保持
%   satellite
satellite.Propagator.AutoSequence.Add('NS Station Keeping');
satellite.Propagator.AutoSequence.Item(2).Sequence.Insert('eVASegmentTypeTargetSequence','NS_SK_Drift','-');
NS=satellite.Propagator.AutoSequence.Item(2).Sequence.Item(0).Segment;
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
Differential2=satellite.Propagator.AutoSequence.Item(2).Sequence.Item(0).Profiles.Item(0);
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
TOD.DesiredValue=inclination;
TOD.Tolerance=0.001;
TOD.ScalingMethod='eVADCScalingMethodTolerance';
satellite.Propagator.AutoSequence.Item(2).Sequence.Item(0).Action='eVATargetSeqActionRunActiveProfiles';
end

