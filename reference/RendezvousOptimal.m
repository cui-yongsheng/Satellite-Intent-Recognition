%% ��������
clear;
clc;
close all;
global root rx ry rz vx vy vz; % ����ȫ�ֱ���
%% ����STK�Դ���LAMBERT����ʵ��Ŀ�����أ����ᣩ
% �������ȡ�������е�STKӦ�ó���ʵ��
uiApplication = actxGetRunningServer('STK11.application');
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
root.NewScenario('RendezvousOptimal');     % ����һ����Ϊ'RendezvousOptimal'���³���
StartTime = '26 Jan 2024 04:00:00.000';    % ������ʼʱ��
StopTime = '10 Feb 2024 04:00:00.000';     % ��������ʱ��
root.ExecuteCommand(['SetAnalysisTimePeriod * "',StartTime,'" "',StopTime,'"']);
root.ExecuteCommand(' Animate * Reset');

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

%% ���������ĳ�ʼ״̬�õ����õĹ�����������
% ͨ��ִ�������ȡ���������ڹ�������ϵ�е�λ�ú��ٶ���Ϣ
data_blue=root.ExecuteCommand(['Report_RM */Satellite/blue Style "Inertial Position Velocity" TimePeriod "',StartTime,'" "',StopTime,'" TimeStep 3600']);
% �Ի�ȡ�����ݽ��д�����ȡλ�ú��ٶ���Ϣ
struct=regexp(data_blue.Item(1),',','split');
rx=str2double(cell2mat(struct(2)));
ry=str2double(cell2mat(struct(3)));
rz=str2double(cell2mat(struct(4)));
vx=str2double(cell2mat(struct(5)));
vy=str2double(cell2mat(struct(6)));
vz=str2double(cell2mat(struct(7)));
root.ExecuteCommand('ComponentBrowser */ Duplicate "Design Tools" "Lambert Solver" myLambert');

%% �Ŵ��㷨�������Ż���ʱ��
% ����ο���Χ��lb=24*60;ub=15*24*60;
x0 = 9000; % ��ʼ�²�ֵ
options = optimset('Display','iter','MaxIter',200,'PlotFcns',@optimplotfval);
% Todo: �����Ż���parfeval
[x,fval] = fminsearch(@lambert,x0,options);
% ������Ž��Ŀ�꺯��ֵ
fprintf('���Ż���ʱ��Ϊ��%d ����\n', x);
fprintf('��С����ֵΪ��%.4f\n', fval);