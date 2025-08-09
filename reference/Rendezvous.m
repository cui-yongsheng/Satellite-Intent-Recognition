%% ��������
clear;
clc;
close all;

%% ����STK�Դ���LAMBERT����ʵ��Ŀ�����أ����ᣩ
% �������ȡ�������е�STKӦ�ó���ʵ��
uiApplication = actxGetRunningServer('STK11.application');
% ��ȡIAgStkObjectRoot�ӿڣ����ڲ���STK����ģ�͵ĸ�
root = uiApplication.Personality2;
% ��鵱ǰ�Ƿ��д򿪵ĳ������Ծ����Ƿ���Ҫж�ػ�رյ�ǰ����
checkempty = root.Children.Count;
% �������δж�صĳ�������ж�ز��رյ�ǰ������ȷ����������Կ�ʼ�µĲ���
if checkempty ~= 0
    root.CurrentScenario.Unload
    root.CloseScenario;
end


%% �趨��������
root.NewScenario('Rendezvous');            % ����һ����Ϊ'Rendezvous'���³���
StartTime = '26 Jan 2024 04:00:00.000';    % ���峡���Ŀ�ʼʱ��
StopTime = '10 Feb 2024 04:00:00.000';     % ���峡���Ľ���ʱ��
time_step = '60';       % �������ʱ����Ϊ60��
% ���ó����ķ���ʱ���
root.ExecuteCommand(['SetAnalysisTimePeriod * "',StartTime,'" "',StopTime,'"']);
root.ExecuteCommand(' Animate * Reset');  % ���ö���

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
root.ExecuteCommand(['Astrogator */Satellite/target SetValue MainSequence.SegmentList.Propagate.StoppingConditions.Epoch.TripValue ',StopTime,' UTCG']);%
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

%% ���ݺ췽�ĳ�ʼ״̬�õ����õĹ���������յ�
% ��������ʱ�����
number_time=4320;   % ����4320���ӣ���29 Jan 04:00:00.000����
sec=4320*60;
% ���������ʱ���26 Jan 2024 04:00:00.000 �� 10 Feb 2024 04:00:00.000
mission_day=15;
mission_minute=15*24*60;
% ���ݸ�����ʱ�䣬���������λ��
data_red=root.ExecuteCommand(['Report_RM */Satellite/target Style "Inertial Position Velocity" TimePeriod "',StartTime,'" "',StopTime,'" TimeStep ',num2str(time_step)]);
% ���忪ʼʱ����ַ�����ʽ
starttime='2024-1-26 04:00:00';
% ����ʼʱ���ַ���ת��Ϊdatetime��ʽ����Ϊdatetime�����޷�ֱ�Ӷ�ȡStartTime������д��
time=datetime(starttime);
% ����һ����1������������ķ�������
minute=minutes(1:mission_minute);
% ͨ����ʼʱ����Ϸ������У������ÿ��ʱ��㣬����Ϊ�˺����ܹ�����number_time�任ʱ����׼��
option_fixtime=time+minute;
% �����ض���ֵnumber_time����ȡ��ĩ��λ�õ�ʱ��
time_end=datestr(option_fixtime(number_time));
% ��ʱ���ַ����е����ַ��滻Ϊ�ո�����STK�����ʱ���ʽƥ��
time_end=strrep(time_end,'-',' ');
% ��ʱ���ַ���ĩβ���'.000'������STK�����ʱ���ʽƥ��
time_end=string(time_end)+'.000';
% ��ȡdata_red����ļ������ԣ����ں�������
data_Line=data_red.count;
for i=1:data_Line-2
    struct=regexp(data_red.Item(i),',','split');
    End_time=string(struct(1));
    if End_time==time_end 
        End_rx=cell2mat(struct(2));
        End_ry=cell2mat(struct(3));
        End_rz=cell2mat(struct(4));
        End_vx=cell2mat(struct(5));
        End_vy=cell2mat(struct(6));
        End_vz=cell2mat(struct(7));
        break
    else
        continue
    end
end

%% ����STK��Design tools�������������������
root.ExecuteCommand(['ComponentBrowser */ Duplicate "Design Tools" "Lambert Solver" myLambert']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert InitEpoch "',StartTime,'" UTCG']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert InitPosVel.Rx ',num2str(rx),' km']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert InitPosVel.Ry ',num2str(ry),' km']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert InitPosVel.Rz ',num2str(rz),' km']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert InitPosVel.Vx ',num2str(vx),' km*sec^-1']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert InitPosVel.Vy ',num2str(vy),' km*sec^-1']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert InitPosVel.Vz ',num2str(vz),' km*sec^-1']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert FinlPosVel.Rx ',num2str(End_rx),' km']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert FinlPosVel.Ry ',num2str(End_ry),' km']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert FinlPosVel.Rz ',num2str(End_rz),' km']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert FinlPosVel.Vx ',num2str(End_vx),' km*sec^-1']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert FinlPosVel.Vy ',num2str(End_vy),' km*sec^-1']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert FinlPosVel.Vz ',num2str(End_vz),' km*sec^-1']);
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert MinimumTOF ',num2str(sec), ' sec']);
root.ExecuteCommand('ComponentBrowser */ LambertCompute "Design Tools" myLambert');

%% ��ȡ�����������̵����������
result=root.ExecuteCommand(['ComponentBrowser_RM */ GetValue "Design Tools" myLambert LambertResult']);
total_delta=result.Item(23);
% ��������������ֵ����ʼλ��
V_begin=strfind(total_delta,'=');
% ��������������ֵ�Ľ���λ��
V_end=strfind(total_delta,'m*sec^-1');
% ���ҵ�����������ֵ���ַ���ת��Ϊ��ֵ
delta_all=str2num(total_delta(V_begin+1:V_end-1));
fprintf('ת��ʱ��Ϊ%.4f sec�����ĵ�������Ϊ%.4f m/s\n',sec,delta_all);