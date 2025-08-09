%% ��������
clear;
clc;
close all;

%% ����ʵ�����Ǳ���
% �������ȡ�������е�STKӦ�ó���ʵ��
uiApplication = actxserver('STK11.application');
uiApplication.Visible = true;
% ��ȡIAgStkObjectRoot�ӿڣ����ڲ���STK����ģ�͵ĸ�
root = uiApplication.Personality2;
% ��鵱ǰ�Ƿ��д򿪵ĳ������Ծ����Ƿ���Ҫж�ػ�رյ�ǰ����
checkempty = root.Children.Count;
% �������δж�صĳ�������ж�ز��رյ�ǰ������ȷ����������Կ�ʼ�µĲ���
if checkempty ~= 0
    root.CurrentScenario.Unload;
    root.CloseScenario;
end

%% ���������Ҫ�趨����������
root.NewScenario('GEOStationKeeping');
StartTime = '1 Apr 2016 00:00:00.000';    % ������ʼʱ��
StopTime = '18 Jul 2017 00:00:00.000';     % ��������ʱ��
root.ExecuteCommand(['SetAnalysisTimePeriod * "',StartTime,'" "',StopTime,'"']);
root.ExecuteCommand(' Animate * Reset');

%% �����ο�����
Sat_Name='Reference';
satellite=root.CurrentScenario.Children.New('eSatellite',Sat_Name);
% ��������ͬ��������ǣ����µ㾭��Ϊ190.0
root.ExecuteCommand(['OrbitWizard */Satellite/',Sat_Name,' Geosynchronous Inclination 0 SubsatellitePoint 13.0 Color green']);
% ʹ�ع�ϵ���ֳ���
satellite.VO.OrbitSystems.FixedByWindow.IsVisible=1;    % ���ù̶����ϵͳ�ڴ����пɼ�
satellite.VO.OrbitSystems.InertialByWindow.IsVisible=0; % ���ù��Թ��ϵͳ�ڴ����в��ɼ�
satellite.VO.Proximity.GeoBox.IsVisible=1;  % ���õ�������ӽ������ɼ�
satellite.VO.Proximity.GeoBox.Longitude=13;  % ���õ�������ľ���
satellite.VO.Proximity.GeoBox.NorthSouth=0.5;   % ���õ���������ϱ����
satellite.VO.Proximity.GeoBox.EastWest=0.5; % ���õ�������Ķ������
satellite.VO.Proximity.GeoBox.Radius=42166.3;   % ���õ�������İ뾶
satellite.Graphics.Attributes.Inherit=0;     % ����ͼ�����Բ��̳�
satellite.Graphics.Attributes.LabelVisible=0;   % ���ñ�ǩ���ɼ�
satellite.Graphics.Attributes.IsOrbitVisible=0; % ���ù�����ɼ�

%% ���������
Sat_Name2='GEO_Sat';
satellite2=root.CurrentScenario.Children.New('eSatellite',Sat_Name2);
satellite2.SetPropagatorType('ePropagatorAstrogator'); 
satellite2.Propagator;
% ��ʼ�����ǵĹ������
sma=42166.3;  % �볤��
Ecc=0;        % ƫ����
Inc=0;        % ������
w=0;          % ���ص����
LonAsc=13;    
TA=352.96;    % ������
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

%% �������Ǵ�������
Propagate=satellite2.Propagator.MainSequence.Item(1);
Propagate.StoppingConditions.Item(0).Properties.Trip=86400*365.25;
Propagate.StoppingConditions.Item(0).Properties.Inherited=0;
% ������ǵĹ��ϵͳ
satellite2.VO.OrbitSystems.Add('Satellite/Reference VVLH System');
% ���ع��ϵͳ�Ĺ�������ϵ��ʾ
satellite2.VO.OrbitSystems.InertialByWindow.IsVisible=0;
satellite2.VO.Pass.TrackData.PassData.Orbit.SetLeadDataType('eDataNone');
satellite2.VO.Pass.TrackData.PassData.Orbit.SetTrailDataType('eDataTime');
% ����β�����ݵ�ʱ�䳤��Ϊ720Сʱ
satellite2.VO.Pass.TrackData.PassData.Orbit.TrailData.Time=720*3600;
% ִ�����ǵĹ����������
root.ExecuteCommand(['Astrogator */Satellite/',Sat_Name2,' RunMCS']);

%% ѡ��Inclination�����Duplicate����������ΪTOD Inclination��ѡ������ϵΪEarth TOD
% ����Utilities�Ĳ˵���ѡ��Component Browser��ѡ�ѡ��Calculation Objects��Ŀ¼��ѡ��Keplerian Elems��Ŀ¼
root.ExecuteCommand('ComponentBrowser */ Duplicate "Calculation Objects" Inclination "TOD"');
root.ExecuteCommand('ComponentBrowser */ SetValue "Calculation Objects" "TOD" CoordSystem "CentralBody/Earth TOD"');

%% ���һ��East-Westλ�ñ��ֵĳ����Զ�����
% ����AutoSequence�����Ȳ���һ��Sequence��������ΪEW_Station_Keeping��
satellite2.Propagator.AutoSequence.Add('EW Station Keeping');
satellite2.Propagator.AutoSequence.Item(1).Sequence.Insert('eVASegmentTypeSequence','EW_Station_Keeping','-');
EW=satellite2.Propagator.AutoSequence.Item(1).Sequence.Item(0).Segment;
% ��Sequence�������һ��Propagate����������ΪApogee����Propagate��ɫ����Ϊ��ɫ��
EW.Insert('eVASegmentTypePropagate','Stop_on_Apogee','-');
EW.Item(0).Properties.Color=255;
% ����ֹͣ�������ΪApoapsis��ȡ��Duration
stopcondition=EW.Item(0).StoppingConditions;
stopcondition.Add('Apoapsis');
stopcondition.Remove('Duration');
% ���һ��Ŀ�����У�����ΪTarget Turn Around
% ���ڷ��ض�λ��Ŀ��������ʱ���á����ض��ڴ�Ŀ�����������ļ������磬һ�����У����������ʱ�������ԣ���ʱ�öβ����
EW.Insert('eVASegmentTypeTargetSequence','Target_Turn_Around','-');
Target=EW.Item(1).Segment;
% ��Ŀ�����������һ������������ΪEW_Burn
Target.Insert('eVASegmentTypeManeuver','EW_Burn','-');
% ��Ŀ�����������һ���������У�����ΪProp to Second Node
Target.Insert('eVASegmentTypePropagate','Prop_to_Second_Node','-');
Prop_to_Second_Node=Target.Item(1);
Prop_to_Second_Node.Properties.Color=42495;
% ��Ŀ�����������һ��return���У�����ΪEnable(except Profiles bypass)
Target.Insert('eVASegmentTypeReturn','return','-');
Return=Target.Item(2);
Return.ReturnControlToParentSequence='eVAReturnControlEnableExceptProfilesBypass';
% ��Ŀ�����������һ��Propagate������ΪProp to Asending Nod
Target.Insert('eVASegmentTypePropagate','Prop_to_Asending_Node','-');
Prop_to_Asending_Node=Target.Item(3);
Prop_to_Asending_Node.Properties.Color=65535;
% �޸�EW Burn ����ת��ΪAttitude Control to Thrust Vector����ʩ������ת��ΪVNC(Earth)��ѡ��X��Velocity����Ϊ���Ʊ�����
Maneuver=Target.Item(0);
Maneuver.Maneuver.SetAttitudeControlType('eVAAttitudeControlThrustVector');
Maneuver.Maneuver.AttitudeControl.ThrustAxesName='Satellite VNC(Earth)';
Maneuver.EnableControlParameter('eVAControlManeuverImpulsiveCartesianX');
% ����Prop to Second Node���� �����һ��Ascending Nodeֹͣ�����
Prop_to_Second_Node.StoppingConditions.Add('AscendingNode');
Prop_to_Second_Node.StoppingConditions.Remove('Duration');
% ָ���ڴ���ֹ֮ͣǰ��Ҫ�ﵽֹͣ�������ٴ�
Prop_to_Second_Node.StoppingConditions.Item(0).Properties.RepeatCount=2;
% ѡ��ο�����ϵΪEarth TOD���Ƴ�Duration���
Prop_to_Second_Node.StoppingConditions.Item(0).Properties.CoordSystem='CentralBody/Earth TOD';
% ����Prop to Ascending Node���֣����һ��Ascending Nodeֹͣ�����
% ����������ΪTOD�����Լ��������ѡ��UserDefinedѡ�������������ΪMin_Longitude��
% ��Criteria��ֵ����ΪGreater Than Minimum��
% ��CalcObject����ΪGeodetc>Longitude����Tolerance����Ϊ0.05��
Prop_to_Asending_Node.StoppingConditions.Add('AscendingNode');
Prop_to_Asending_Node.StoppingConditions.Item(1).Properties.CoordSystem='CentralBody/Earth TOD';
Prop_to_Asending_Node.StoppingConditions.Item(1).Properties.Constraints.Add('UserDefined');
Prop_to_Asending_Node.StoppingConditions.Item(1).Properties.Constraints.Item(0).Name='Min_Longitude';
Prop_to_Asending_Node.StoppingConditions.Item(1).Properties.Constraints.Item(0).Criteria='eVACriteriaGreaterThanMinimum';
Prop_to_Asending_Node.StoppingConditions.Item(1).Properties.Constraints.Item(0).CalcObjectName='Longitude';
Prop_to_Asending_Node.StoppingConditions.Item(1).Properties.Constraints.Item(0).Tolerance=0.05;
Prop_to_Asending_Node.StoppingConditions.Remove('Duration');
% ѡ������ѡ��Prop to Ascending Node���֡�
% ���Math��Ϊ�����ı������ı�ComponentName����ΪMinimum_Longitude���������������ΪLongitude��
Prop_to_Asending_Node.Results.Add('Minimum_Value');
Prop_to_Asending_Node.Results.Item(0).Name='Minimum_longitude';
Prop_to_Asending_Node.Results.Item(0).CalcObjectName='Longitude';
% ѡ��Ŀ�����У���Differential Corrector��
% ��ImpulsiveMnver.Cartesian.X�������Ϊ���Ʋ�����
% ѡ��PertubationΪ0.01m/s��MaxStepΪ1m/s��
% ������ǽ������С�ĵ��������ֹ����������Ҫ������󲽳����㶯��һ��С�Ĺ�ģ�¡�
% ��Minimum_Longitude��Ϊ�����������ֵ������12.55�㡣
% ����������������ڼ�ᱣ���ں���������������߽�����������������ֵ��12.55�㣬��Tolerance����Ϊ0.001deg��
% ��Action field����ΪRun active profiles
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

%% ����ϱ�λ�ñ��ֲ���
satellite2.Propagator.AutoSequence.Add('NS Station Keeping');
satellite2.Propagator.AutoSequence.Item(2).Sequence.Insert('eVASegmentTypeTargetSequence','NS_SK_Drift','-');
NS=satellite2.Propagator.AutoSequence.Item(2).Sequence.Item(0).Segment;
NS.Insert('eVASegmentTypeManeuver','NS_Burn','-');
% ����̬��������ΪThrust Vector�����ÿ���ϵΪVNC(Earth)��ѡ��X��Y��Ϊ�Ŀ��Ʊ���������YΪ-200m/s��
% ������ΪNS Burn���֣�ѡ����ΪMath-Difference��Ϊ������ѡ��ComponentNameΪSMA_Diff��
% �ı�CalcObjectΪSemimajor Axis������DifferenceOrderΪCurrentMinusInitial��
% ��Elems>TOD InclinationΪsecond component variable.s
Maneuver2=NS.Item(0);
Maneuver2.Maneuver.SetAttitudeControlType('eVAAttitudeControlThrustVector');
Maneuver2.EnableControlParameter('eVAControlManeuverImpulsiveCartesianX');
Maneuver2.EnableControlParameter('eVAControlManeuverImpulsiveCartesianY');
% Maneuver2.Maneuver.FiniteMnvr.Cartesian.Y=-200;
% ����߽�����
Maneuver2.Results.Add('Difference');
Maneuver2.Results.Item(0).Name='SMA_Diff';
Maneuver2.Results.Item(0).DifferenceOrder='eVADifferenceOrderCurrentMinusInitial';
Maneuver2.Results.Item(0).CalcObjectName='Semimajor Axis';
Maneuver2.Results.Add('TOD');
%����Thrust Component
% ѡ��NS SK Drift��˫��Differential Corrector����ImpulsiveMnvr.Cartesian.X,Y��
% ��X��Y component���㶯����Ϊ0.1m/s�������Ϊ10m/s��
% ͬʱ���ú�SMA_Diff������ֵΪ0������̶�Ϊ0.01km��
% ������ģʽ��ΪBy tolerance����ģʽ��ΪRun Active Profiles
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

%% ��������ֹͣʱ��
% �ڶ�������վλ���ֵ��Զ����к���������רע�������в��֡�
% ���ǽ�����µ�ֹͣ����������������ι�������ͬʱ�������鷢����
% ���ǽӽ���GEO���ӵ��ﶫ�߽磬EW StationKeeping�������������ǽӽ���GEO���ӵ����ϱ߽硣
% һ��NS StationKeeping����������
% ����һ�������ֹͣ��������GEO_Sat's���ǵ�Orbit��ѡ��Propagate���֣����Apoapsisֹͣ��������������ΪApoapsis EW��
% ��Sequence����EW Station Keeping�����ظ���������Ϊ3�Σ�ѡ�����Ԥ��ʱ��10yr��ѡ��OK�رա�
satellite2.Propagator.MainSequence.Remove('Propagate');
satellite2.Propagator.MainSequence.Insert('eVASegmentTypePropagate','Apoapsis_EW','-');
Apoapsis_EW=satellite2.Propagator.MainSequence.Item(1);
Apoapsis_EW.StoppingConditions.Add('Apoapsis');
Apoapsis_EW.StoppingConditions.Remove('Duration');
Apoapsis_EW.StoppingConditions.Item(0).Properties.RepeatCount=3;
Apoapsis_EW.StoppingConditions.Item(0).Properties.Sequence='EW Station Keeping';
Apoapsis_EW.MaxPropagationTime=10*365.25*86400;
% ����һ��ǰ�������ڶ���վ�㱣�ֵ���������ǽ����һ����������ƺ��������ž��ȵľ��룬
% �����������before������ѡ��longitude��Ϊֹͣ���������ֵΪ13.5deg��
Before=Apoapsis_EW.StoppingConditions.Item(0).Properties.BeforeConditions;
Before.Add('Longitude');
Before.Item(0).Properties.Trip=13.5;
% ���Ascending Node NS Stopping Condition��

% ���������һ��ֹͣ�������North South StationKeeping �������С�
% ���һ��AscendingNodeֹͣ���������ΪAscendingNode NS��ѡ������ΪNS Station Keeping��
% ������ϵ����ΪEarth TOD���������ʱ��Ϊ10yr��
Apoapsis_EW.StoppingConditions.Add('AscendingNode');
Apoapsis_EW.StoppingConditions.Item(1).Properties.Sequence='NS Station Keeping';
Apoapsis_EW.StoppingConditions.Item(1).Properties.CoordSystem='CentralBody/Earth TOD';
% ���һ��Լ������ΪNS Station Keeping��
% ���ǽ����һ��Լ�����������ƺ������Ĺ����ǡ�
% ѡ���Լ������ΪUserDefined��˫��ComponentName������ΪMaxInclination��
% ѡ��CriteriaΪGreat than��
% ��CalcObject����Keplerian TOD Inclination��������ϵ����ΪEarth TOD����ϵ���������ValuesΪ0.45��
Constraint1=Apoapsis_EW.StoppingConditions.Item(1).Properties.Constraint;
Constraint1.Add('UserDefined');
Constraint1.Item(0).Name='MaxInclination';
Constraint1.Item(0).Criteria='eVACriteriaGreaterThan';
MaxInclination=Constraint1.Item(0);
MaxInclination.CalcObjectName='TOD';
MaxInclination.Value=0.5;
% ����ȷ�������л�����ǵ���0.45��֮ǰֹͣ��
% ����һ������ֹͣ�������Ϊ���������������450�졣
satellite2.Propagator.MainSequence.Item(1).StoppingConditions.Add('AlwaysTripped');
MaxDuration=satellite2.Propagator.MainSequence.Item(1).StoppingConditions.Item(2);
MaxDuration.Name='MaxDuration';
MaxDuration.Properties.Constraints.Add('UserDefined');
MaxDuration.Properties.Constraints.Item(0).Name='MaxDuration';
MaxDuration.Properties.Constraints.Item(0).Criteria='eVACriteriaGreaterThan';
MaxDuration.Properties.Constraints.Item(0).CalcObjectName='Duration';
MaxDuration.Properties.Constraints.Item(0).Value=360*86400;
% Clear Graphic �������MCS���ٵ��Clear Graphic���Ƴ����õĹ켣
root.ExecuteCommand(['Astrogator */Satellite/',Sat_Name2,' RunMCS']);
root.ExecuteCommand(['Astrogator */Satellite/',Sat_Name2,' ClearDWCGraphics']);

% %% �ر�
% uiApplication.Quit;
% clear uiApplication root

