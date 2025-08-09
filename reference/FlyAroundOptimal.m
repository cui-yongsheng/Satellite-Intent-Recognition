%% ��������
clear;
clc;
close all;
global root xx

%% ����ʵ���������Ƶ���ĩλ��Ϊ��Ŀ���Ʒ�����Ҫ��ʱ��͵ص�
% �������ȡ�������е�STKӦ�ó���ʵ��
uiApplication = actxserver('STK11.application');
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
root.NewScenario('FlyAroundOptimal');  % ����һ���µĳ���������Ϊ'FlayAroundOptimal'
StartTime = '26 Jan 2024 04:00:00.000';    % ������ʼʱ��
StopTime = '10 Feb 2024 04:00:00.000';     % ��������ʱ��
time_step = 60;                          % �������ʱ����Ϊ60��
root.ExecuteCommand(['SetAnalysisTimePeriod * "',StartTime,'" "',StopTime,'"']);

%% ���������Ǻ����غ췽�ǵĳ�ʼ�������
% ���������ǣ�����ΪeSatellite������Ϊ'blue'
Sat_name1='blue';     % �����һ�����ǵ�����
satellite1= root.CurrentScenario.Children.New('eSatellite', Sat_name1);
satellite1.SetPropagatorType('ePropagatorAstrogator');  % �������ǵĹ������������
satellite1.Propagator;   % �������ǵĴ�����
% ��ʼ�����ǹ������
e=0;Sat_TA=0;Sat_LAN=165;
% ����Astrogatorģ��ĳ�ʼ״̬�ʹ�������
root.ExecuteCommand('Astrogator */Satellite/blue SetValue MainSequence.SegmentList Initial_State Propagate');   % �ӳ�ʼ״̬���й��������
root.ExecuteCommand('Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.CoordinateType Modified Keplerian'); % ��ʼ״̬��������Ϊ���������չ��
root.ExecuteCommand(['Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Epoch ',StartTime,' UTCG']);    % ���ó�ʼ��Ԫ��Epoch��ʱ��
root.ExecuteCommand('Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.ElementType "Kozai-Izsak Mean"');   % �����չ��Ҫ������Ϊ Kozai-Izsak ƽ�������Ԫ��
root.ExecuteCommand('Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.Period 86169.6 sec');   % ���ù������Ϊ 86169.6 ��
root.ExecuteCommand(['Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.ecc ',num2str(e)]);    % ���ù��ƫ����
root.ExecuteCommand('Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.inc 0 deg');    % ���ù�����
root.ExecuteCommand('Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.w 0 deg');  % ���ý��ص����
root.ExecuteCommand(['Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.TA ',num2str(Sat_TA),' deg']); % ����������
root.ExecuteCommand(['Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Initial_State.InitialState.Keplerian.LAN ',num2str(Sat_LAN),' deg']);   % ����������ྭ
root.ExecuteCommand('Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Propagate.StoppingConditions Epoch');    % ���ô�������ֹͣ����Ϊָ����Ԫʱ��
root.ExecuteCommand(['Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Propagate.StoppingConditions.Epoch.TripValue ',StopTime,' UTCG']); % ���ô�������ʱ��
root.ExecuteCommand('Astrogator */Satellite/blue SetValue MainSequence.SegmentList.Propagate.Propagator Earth_J2'); % ���ô�����ģ��
root.ExecuteCommand('Astrogator */Satellite/blue RunMCS');
% ����������Ŀ�����ǣ�����ΪeSatellite������Ϊ'target'
Sat_name2='target';
satellite2= root.CurrentScenario.Children.New('eSatellite', Sat_name2);
satellite2.SetPropagatorType('ePropagatorAstrogator'); 
satellite2.Propagator;
% ��ʼ�����ǹ������
e=0;Sat_TA=0;Sat_LAN=105;
% ����Astrogatorģ��ĳ�ʼ״̬�ʹ�������
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

%% ��������Ŀ���ǵ�ʱ��ȷ���Ʒɵ�λ�� 
Mission_time='5 Feb 2024 04:00:00';     %�ڸ�������ĵ�ʮ��Ҫ�󵽴��λ��

%% ����STK����ķ�ʽ����һ����ʱ���Ʒɵ�����
VMC_SatName='raofei';
miu=3.986e5;            % ������������
omega=2*pi/86169.6;     % ���ǽ��ٶȣ����ǹ������86169.6sec
z=10;                   % �Ʒɶ̰���
dx=2*omega*z;           % �����Ʒ���Բ��X���ٶȷ���(���������)

%% ����CW����ѡ�����Ʒɵĵ�
% https://blog.csdn.net/weixin_57997461/article/details/136787786
t=0:time_step:86169.6;
X=[0,0,z,dx,0,0]';      % ��ʼ״̬����������λ�ú��ٶ�
xx=zeros(length(t),6);  % ����һ��6�еľ������ڱ�����
for i=1:length(t)
    t=(i-1)*60;
    xx(i,:)=CW(X,omega,t);
end

%% ����STK����ķ�ʽ����һ����ʱ���Ʒɵ�����
satellite3= root.CurrentScenario.Children.New('eSatellite', VMC_SatName);
satellite3.SetPropagatorType('ePropagatorAstrogator'); 
satellite3.Propagator;
root.ExecuteCommand('ComponentBrowser */ Duplicate "Design Tools" "Lambert Solver" myLambert');

%% ���ú����Ż��ķ����ҵ����Ż���ʱ���Լ��������㣬��֪��ʼ����ʱ��Ϊ26 Jan 2024 04:00:00.000 
options = optimset('Display','iter','MaxIter',200,'PlotFcns',@optimplotfval);
[x,fval]=fminsearch(@lambert3,[9000,4],options);
disp(['���Ż���ʱ��Ϊ��',num2str(x(1)),'��']);
disp(['���Ż�������Ϊ��',num2str(x(2))]);

%% �����Ž��������STK��
% https://blog.csdn.net/weixin_57997461/article/details/136720238
J=lambert3(x);  % ͨ��lambert��⣬�����ӵ����ǹ��ת����
root.ExecuteCommand('ComponentBrowser */ SetValue "Design Tools" myLambert SequenceName ones'); % ������������ ones     
root.ExecuteCommand('ComponentBrowser */ LambertConstructSequence "Design Tools" myLambert');   % �����������
root.ExecuteCommand('ComponentBrowser */ LambertAddToCB "Design Tools" myLambert');             % Add to MCS Segment
% satellite1.Unload;  % ж������1
Sat_best='blue_best';
satellite4= root.CurrentScenario.Children.New('eSatellite', Sat_best);  % �ڵ�ǰ�������½�����
satellite4.SetPropagatorType('ePropagatorAstrogator');  % �������ǵĹ������������
satellite4.Propagator;
root.ExecuteCommand('ComponentBrowser_RM */ GetValue "Design Tools" myLambert InitEpoch');   % �Ƴ�Ĭ����������
root.ExecuteCommand('Astrogator */Satellite/blue_best SetValue MainSequence.SegmentList ones Propagate');   % ����������� ones
root.ExecuteCommand('Astrogator */Satellite/blue_best SetValue MainSequence.SegmentList.Propagate.StoppingConditions Epoch');   % ��������ֹͣ����
root.ExecuteCommand(['Astrogator */Satellite/blue_best SetValue MainSequence.SegmentList.Propagate.StoppingConditions.Epoch.TripValue ',StopTime,' UTCG']);
root.ExecuteCommand('Astrogator */Satellite/blue_best SetValue MainSequence.SegmentList.Propagate.Propagator Earth_J2');
root.ExecuteCommand('Astrogator */Satellite/blue_best RunMCS');

%% �ҳ�����ʱ������������Ĺ�ϵ
%% ����ʾ�췽�������Ĺ̶�����ϵ�µĹ켣
root.ExecuteCommand('VO */Satellite/raofei OrbitSystem Modify System "InertialByWindow" Show Off');
root.ExecuteCommand('VO */Satellite/raofei OrbitSystem Add System VVLH Satellite/target Color red');
root.ExecuteCommand('VO */Satellite/target OrbitSystem Modify System "InertialByWindow" Show Off');
root.ExecuteCommand('VO */Satellite/blue_best OrbitSystem Add System VVLH Satellite/target Color red');