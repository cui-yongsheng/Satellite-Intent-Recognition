clear;clc
%% 本文将实现兰伯特制导，末位置为对目标绕飞所需要的时间和地点
uiApplication = actxGetRunningServer('STK11.application');
% Get our IAgStkObjectRoot interface
root = uiApplication.Personality2;
checkempty = root.Children.Count;
if checkempty ~= 0
    root.CurrentScenario.Unload
    root.CloseScenario;
end
%% 根据你的需要设定场景的名称
root.NewScenario('Spiral_to_GEO_Optimal_Finite');
StartTime = '15 Dec 2018 17:00:00.000';    % 场景开始时间
StopTime = '17 Dec 2018 17:00:00.000';     % 场景结束时间
root.ExecuteCommand(['SetAnalysisTimePeriod * "',StartTime,'" "',StopTime,'"']);
root.ExecuteCommand(' Animate * Reset');

%% 利用Component Browser生成发动机模型
root.ExecuteCommand(['ComponentBrowser */ Duplicate "Engine Models" "Constant Acceleration and Isp" MyEngine']);
bb=root.ExecuteCommand(['ComponentBrowser_RM */ GetValue "Engine Models" MyEngine']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Engine Models" MyEngine Acceleration 9.8 cm*sec^-2' ]);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Engine Models" MyEngine Isp 3000 s' ]);

Sat_name='Finite_Maneuver';
satellite= root.CurrentScenario.Children.New('eSatellite', Sat_name);
satellite.SetPropagatorType('ePropagatorAstrogator'); 
satellite.Propagator
root.ExecuteCommand(['Astrogator */Satellite/Finite_Maneuver SetValue MainSequence.SegmentList Initial_State Maneuver Propagate']);
root.ExecuteCommand(['Astrogator */Satellite/Finite_Maneuver SetValue MainSequence.SegmentList.Initial_State.CoordinateType Modified Keplerian']);
root.ExecuteCommand(['Astrogator */Satellite/Finite_Maneuver SetValue MainSequence.SegmentList.Initial_State.InitialState.Epoch ',StartTime,' UTCG']);
root.ExecuteCommand(['Astrogator */Satellite/Finite_Maneuver SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.ElementType "Kozai-Izsak Mean"']);
root.ExecuteCommand(['Astrogator */Satellite/Finite_Maneuver SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.sma 7000 km ']);
root.ExecuteCommand(['Astrogator */Satellite/Finite_Maneuver SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.ecc 0']);
root.ExecuteCommand(['Astrogator */Satellite/Finite_Maneuver SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.inc 28.5 deg']);
root.ExecuteCommand(['Astrogator */Satellite/Finite_Maneuver SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.w 0 deg']);
root.ExecuteCommand(['Astrogator */Satellite/Finite_Maneuver SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.TA 140 deg']);
root.ExecuteCommand(['Astrogator */Satellite/Finite_Maneuver SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.RAAN 0 deg'])

root.ExecuteCommand(['Astrogator */Satellite/Finite_Maneuver SetValue MainSequence.SegmentList.Maneuver.MnvrType Finite']);
root.ExecuteCommand(['Astrogator */Satellite/Finite_Maneuver SetValue MainSequence.SegmentList.Maneuver.FiniteMnvr.Propagator "Earth Point Mass"']);
root.ExecuteCommand(['Astrogator */Satellite/Finite_Maneuver SetValue MainSequence.SegmentList.Maneuver.FiniteMnvr.AttitudeControl Thrust Vector']);
root.ExecuteCommand(['Astrogator */Satellite/Finite_Maneuver SetValue MainSequence.SegmentList.Maneuver.FiniteMnvr.AttitudeUpdate Update during burn']);

root.ExecuteCommand(['Astrogator */Satellite/Finite_Maneuver SetValue MainSequence.SegmentList.Maneuver.FiniteMnvr.ThrustAxes "Satellite/Finite_Maneuver ICR.Axes"']);
root.ExecuteCommand(['Astrogator */Satellite/Finite_Maneuver SetValue MainSequence.SegmentList.Maneuver.FiniteMnvr.Spherical.Azimuth 42 deg']);
root.ExecuteCommand(['Astrogator */Satellite/Finite_Maneuver SetValue MainSequence.SegmentList.Maneuver.FiniteMnvr.Spherical.Elevation 27 deg']);

root.ExecuteCommand(['Astrogator */Satellite/Finite_Maneuver SetValue MainSequence.SegmentList.Maneuver.FiniteMnvr.EngineModel MyEngine'])
root.ExecuteCommand(['Astrogator */Satellite/Finite_Maneuver SetValue MainSequence.SegmentList.Maneuver.FiniteMnvr.StoppingConditions.Duration.TripValue 18 hr'])

root.ExecuteCommand(['Astrogator */Satellite/Finite_Maneuver SetValue MainSequence.SegmentList.Propagate.StoppingConditions.Duration.TripValue 1 day']);
root.ExecuteCommand(['Astrogator */Satellite/Finite_Maneuver RunMCS']);
