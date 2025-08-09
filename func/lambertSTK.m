function J=lambertSTK(x, vars)
% x(1) 为绕飞选择的时间
% x(2) 为选择入轨点

%% 参数导入
xx = vars.xx;               % 入轨点数据
StopTime = vars.StopTime;   % 场景结束时间
MissionTime = vars.MissionTime; % 任务结束时间
VMC_SatName = vars.VMC_SatName; % VMC卫星名称
timeStep = vars.timeStep;       % 时间步长
data = vars.data;               % STK报告数据
root = vars.root;   

%% 对参数进行检查
% 判断x是否在给定范围内
if x(1) < 1 || x(1) > size(data, 1)
    J =  inf;
    return;
end
if x(2) < 1 || x(2) > size(xx, 1)
    J =  inf;
    return;
end

%% 通过改变入轨点，修改末端进入的位置和速度
indexdot=floor(x(2));
insert_dot=xx(indexdot,:);
rrxx=insert_dot(1);
rryy=insert_dot(2);
rrzz=insert_dot(3);
vvxx=insert_dot(4);
vvyy=insert_dot(5);
vvzz=insert_dot(6);
root.ExecuteCommand(['Astrogator */Satellite/',VMC_SatName,' SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.X ',num2str(rrxx),' km']);
root.ExecuteCommand(['Astrogator */Satellite/',VMC_SatName,' SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Y ',num2str(rryy),' km']);
root.ExecuteCommand(['Astrogator */Satellite/',VMC_SatName,' SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Z ',num2str(rrzz),' km']);
root.ExecuteCommand(['Astrogator */Satellite/',VMC_SatName,' SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Vx ',num2str(vvxx),' km/sec']);
root.ExecuteCommand(['Astrogator */Satellite/',VMC_SatName,' SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Vy ',num2str(vvyy),' km/sec']);
root.ExecuteCommand(['Astrogator */Satellite/',VMC_SatName,' SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Vz ',num2str(vvzz),' km/sec']);
root.ExecuteCommand(['Astrogator */Satellite/',VMC_SatName,' RunMCS']);

data_raofei=root.ExecuteCommand(['Report_RM */Satellite/',VMC_SatName,' Style "Inertial Position Velocity" TimePeriod "',MissionTime,'" "',StopTime,'" TimeStep ',num2str(timeStep*10)]);
struct=regexp(data_raofei.Item(1),',','split');
End_rx=str2double(cell2mat(struct(2)));
End_ry=str2double(cell2mat(struct(3)));
End_rz=str2double(cell2mat(struct(4)));
End_vx=str2double(cell2mat(struct(5)));
End_vy=str2double(cell2mat(struct(6)));
End_vz=str2double(cell2mat(struct(7)));

%% 通过改变时间推移，修改初始的位置和速度
t_min=floor(x(1));
mission_start_time=data{t_min,1};% 找到对应时间对应的报告
rx=data{t_min,2};
ry=data{t_min,3};
rz=data{t_min,4};
vx=data{t_min,5};
vy=data{t_min,6};
vz=data{t_min,7};
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert InitEpoch "',char(mission_start_time),'" UTCG']);
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
mission_start = datetime(mission_start_time, 'InputFormat', 'dd MMM yyyy HH:mm:ss.SSS', 'Locale', 'en_US');    % 任务开始时间
mission_end = datetime(MissionTime, 'InputFormat', 'dd MMM yyyy HH:mm:ss.SSS', 'Locale', 'en_US');    % 任务结束时间
sec = seconds(mission_end - mission_start);
% 显示固定时间解的期望持续时间。这里的“最小”一词是为了应对未来可能对该工具进行的扩展。
root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert MinimumTOF ',num2str(sec), ' sec']);
root.ExecuteCommand('ComponentBrowser */ LambertCompute "Design Tools" myLambert');

%% 获取整个机动过程的总脉冲变量
result=root.ExecuteCommand('ComponentBrowser_RM */ GetValue "Design Tools" myLambert LambertResult');
total_delta=result.Item(23);
V_begin=strfind(total_delta,'=');
V_end=strfind(total_delta,'m*sec^-1');
J=str2double(total_delta(V_begin+1:V_end-1));
end