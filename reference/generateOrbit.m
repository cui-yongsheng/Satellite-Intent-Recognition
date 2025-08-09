uiApplication = actxGetRunningServer('STK11.application');
% Get our IAgStkObjectRoot interface
root = uiApplication.Personality2;
checkempty = root.Children.Count;
if checkempty ~= 0
    root.CurrentScenario.Unload
    root.CloseScenario;
end
%% 根据你的需要设定场景的名称
root.NewScenario('optimal_control');

StartTime = '26 Jan 2024 04:00:00.000';    % 场景开始时间
StopTime = '10 Feb 2024 04:00:00.000';     % 场景结束时间
root.ExecuteCommand(['SetAnalysisTimePeriod * "',StartTime,'" "',StopTime,'"']);
root.ExecuteCommand(' Animate * Reset')

Sat_name1='blue';
satellite1= root.CurrentScenario.Children.New('eSatellite', Sat_name1);
satellite1.SetPropagatorType('ePropagatorAstrogator'); 
satellite1.Propagator

root.ExecuteCommand(['Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.CoordinateSystem "CentralBody/Earth J2000"']);
root.ExecuteCommand(['Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.ElementType "Kozai-Izsak Mean"']);
root.ExecuteCommand(['Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.Period 86169.6 sec']);
root.ExecuteCommand(['Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.ecc 0.1']);
root.ExecuteCommand(['Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.inc 10 deg']);
root.ExecuteCommand(['Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.TA 0 deg']);
root.ExecuteCommand(['Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.w 120 deg']);
root.ExecuteCommand(['Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.LAN 165 deg']);

root.ExecuteCommand(['Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Propagate.StoppingConditions Epoch']);
root.ExecuteCommand(['Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Propagate.StoppingConditions.Epoch.TripValue ',StopTime,' UTCG']);
root.ExecuteCommand(['Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Propagate.Propagator Earth_J2']);

root.ExecuteCommand(['Astrogator */Satellite/blue RunMCS']);