%% ��������
clear;
clc;
close all;
global End_rx End_ry End_rz End_vx End_vy End_vz root

%% ����ʵ���������Ƶ���ĩλ��Ϊ��Ŀ���Ʒ�����Ҫ��ʱ��͵ص�
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
root.NewScenario('FlayAround');
StartTime = '26 Jan 2024 04:00:00.000';    % ������ʼʱ��
StopTime = '10 Feb 2024 04:00:00.000';     % ��������ʱ��
time_step = 60;       % �������ʱ����Ϊ60��
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

%% ��������Ŀ���ǵ�ʱ��ȷ���Ʒɵ�λ�� 
Mission_time='5 Feb 2024 04:00:00';
data_red=root.ExecuteCommand(['Report_RM */Satellite/target Style "Inertial Position Velocity" TimePeriod "',StartTime,'" "',Mission_time,'" TimeStep ',num2str(time_step)]);
data_Line=data_red.count;
for i=1:data_Line-2
    struct=regexp(data_red.Item(i),',','split');
    End_time(i)=struct(1);
end
End_time_str=string(End_time(end));% �ҵ���Ӧʱ���Ӧ�ı���
for i=1:data_Line-2
    struct=regexp(data_red.Item(i),',','split');
    time_end=string(struct(1));
    if time_end==End_time_str
        End_rx=str2double(cell2mat(struct(2)));
        End_ry=str2double(cell2mat(struct(3)));
        End_rz=str2double(cell2mat(struct(4)));
        End_vx=str2double(cell2mat(struct(5)));
        End_vy=str2double(cell2mat(struct(6)));
        End_vz=str2double(cell2mat(struct(7)));
        break
    else
        continue
    end
end


%% ����STK����ķ�ʽ����һ����ʱ���Ʒɵ�����
VMC_SatName='raofei';
% https://blog.csdn.net/u011575168/article/details/116991086
R_norm=sqrt(End_rx^2+End_ry^2+End_rz^2);    % ��������λ��ʸ����ģ
V_norm=sqrt(End_vx^2+End_vy^2+End_vz^2);    % ���������ٶ�ʸ����ģ
R_vec=[End_rx,End_ry,End_rz]/R_norm;        % ����λ�õ�λʸ��
V_vec=[End_vx,End_vy,End_vz]/V_norm;        % �����ٶȵ�λʸ��
Z_vec=-R_vec;                               % ����Z��ʸ��
Y_vec=cross(Z_vec,V_vec);                   % ����Y��ʸ��
X_vec=cross(Y_vec,Z_vec);                   % ����X��ʸ��
miu=3.986e5;                                % ������������
omega=sqrt(miu/R_norm^3);                   % �������ǵĽ��ٶ�
z=10;                                       % �Ʒɶ̰���
dx=2*omega*z;                               % �����Ʒ���Բ��X���ٶȷ���(���������)
satellite3= root.CurrentScenario.Children.New('eSatellite', VMC_SatName);
satellite3.SetPropagatorType('ePropagatorAstrogator'); 
satellite3.Propagator;
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList Initial_State Propagate');   % ����ʼ״̬����Ϊ����ģʽ
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.CoordinateSystem "Satellite/target VVLH"'); % ��������ϵΪ��VVLH��
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.CoordinateType Cartesian'); % ������������Ϊ�ѿ�������
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.X 0 km');   % X�᷽��ĳ�ʼλ��Ϊ0����
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Y 0 km');   % Y�᷽��ĳ�ʼλ��Ϊ0����
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Z 10 km');  % Z�᷽��ĳ�ʼλ��Ϊ10����
root.ExecuteCommand(['Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Vx ',num2str(dx),' km/sec']); % X�᷽��ĳ�ʼ�ٶ�Ϊdx
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Vy 0 km/sec'); % Y�᷽��ĳ�ʼ�ٶ�Ϊ0����/��
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Vz 0 km/sec'); % Z�᷽��ĳ�ʼ�ٶ�Ϊ0����/��
root.ExecuteCommand(['Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.InitialState.Epoch ',Mission_time,' UTCG']); % ���ó�ʼ��Ԫ��Epoch��ʱ��Ϊ����ʱ��
root.ExecuteCommand('Astrogator */Satellite/raofei RunMCS'); % ����Astrogatorģ���Monte Carlo����
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Propagate.StoppingConditions Epoch'); % ���ô�������ֹͣ����Ϊָ����Ԫʱ��
root.ExecuteCommand(['Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Propagate.StoppingConditions.Epoch.TripValue ',StopTime,' UTCG']);% ���ô�������ʱ��
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Propagate.Propagator Earth_J2'); % ���ô�����ģ��Ϊ����J2ģ��
% ���Ʒ����ǵĳ�ʼʱ��λ�ã���ΪLAMBERT��������Ҫ�����ĩ��λ��
data_raofei=root.ExecuteCommand(['Report_RM */Satellite/raofei Style "Inertial Position Velocity" TimePeriod "',Mission_time,'" "',StopTime,'" TimeStep 3600']);
struct=regexp(data_raofei.Item(1),',','split');
End_rx=str2double(cell2mat(struct(2)));
End_ry=str2double(cell2mat(struct(3)));
End_rz=str2double(cell2mat(struct(4)));
End_vx=str2double(cell2mat(struct(5)));
End_vy=str2double(cell2mat(struct(6)));
End_vz=str2double(cell2mat(struct(7)));
root.ExecuteCommand('ComponentBrowser */ Duplicate "Design Tools" "Lambert Solver" myLambert');

%% ���ú����Ż��ķ����ҵ����Ż���ʱ�̣���֪��ʼ����ʱ��Ϊ26 Jan 2024 04:00:00.000 
lb=0;ub=9*24*60;
options = optimset('Display','iter','MaxIter',200,'PlotFcns',@optimplotfval);
[x,fval]=fminbnd(@lambert2,lb,ub,options);
% ������Ž��Ŀ�꺯��ֵ
fprintf('���Ż���ʱ��Ϊ��%d ����\n', x);
fprintf('��С����ֵΪ��%.4f\n', fval);