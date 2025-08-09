function J=lambert3(x)
% x(1) 为绕飞选择的时间
% x(2) 为选择入轨点
global  root xx
%% 通过改变入轨点，修改末端进入的位置和速度
indexdot=floor(x(2));
insert_dot=xx(indexdot,:);
rrxx=insert_dot(1);
rryy=insert_dot(2);
rrzz=insert_dot(3);
vvxx=insert_dot(4);
vvyy=insert_dot(5);
vvzz=insert_dot(6);
StartTime='26 Jan 2024 04:00:00.000';
MissionTime = '5 Feb 2024 04:00:00.000';
StopTime='10 Feb 2024 04:00:00.000';
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList Initial_State Propagate');
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.CoordinateSystem "Satellite/target VVLH"');
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.CoordinateType Cartesian');
root.ExecuteCommand(['Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.X ',num2str(rrxx),' km']);
root.ExecuteCommand(['Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Y ',num2str(rryy),' km']);
root.ExecuteCommand(['Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Z ',num2str(rrzz),' km']);
root.ExecuteCommand(['Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Vx ',num2str(vvxx),' km/sec']);
root.ExecuteCommand(['Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Vy ',num2str(vvyy),' km/sec']);
root.ExecuteCommand(['Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.InitialState.Cartesian.Vz ',num2str(vvzz),' km/sec']);
root.ExecuteCommand(['Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Initial_State.InitialState.Epoch ',MissionTime,' UTCG']);
root.ExecuteCommand('Astrogator */Satellite/raofei RunMCS');
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Propagate.StoppingConditions Epoch');
root.ExecuteCommand(['Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Propagate.StoppingConditions.Epoch.TripValue ',StopTime,' UTCG']);%
root.ExecuteCommand('Astrogator */Satellite/raofei SetValue MainSequence.SegmentList.Propagate.Propagator Earth_J2');
data_raofei=root.ExecuteCommand(['Report_RM */Satellite/raofei Style "Inertial Position Velocity" TimePeriod "',MissionTime,'" "',StopTime,'" TimeStep 3600']);
struct=regexp(data_raofei.Item(1),',','split');
End_rx=str2double(cell2mat(struct(2)));
End_ry=str2double(cell2mat(struct(3)));
End_rz=str2double(cell2mat(struct(4)));
End_vx=str2double(cell2mat(struct(5)));
End_vy=str2double(cell2mat(struct(6)));
End_vz=str2double(cell2mat(struct(7)));

%% 通过改变时间推移，修改初始的位置和速度
time_step=60;   % 为后面的固定步长遍历来寻找最优来做准备
t_min=floor(x(1));
t_all=10*24*60;
sec=(t_all-t_min)*60;
data_blue=root.ExecuteCommand(['Report_RM */Satellite/blue Style "Inertial Position Velocity" TimePeriod "',StartTime,'" "',MissionTime,'" TimeStep ',num2str(time_step)]);
data_Line=data_blue.count;
for i=1:data_Line-2
    struct=regexp(data_blue.Item(i),',','split');
    Start_time(i)=struct(1);
end
Start_time_str=string(Start_time(t_min+1));% 找到对应时间对应的报告
for i=1:data_Line-2
    struct=regexp(data_blue.Item(i),',','split');
    time_start=string(struct(1));
    if time_start==Start_time_str
        rx=cell2mat(struct(2));
        ry=cell2mat(struct(3));
        rz=cell2mat(struct(4));
        vx=cell2mat(struct(5));
        vy=cell2mat(struct(6));
        vz=cell2mat(struct(7));
        break
    else
        continue
    end
end

root.ExecuteCommand(['ComponentBrowser */ SetValue "Design Tools" myLambert InitEpoch "',char(time_start),'" UTCG']);
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
root.ExecuteCommand(['ComponentBrowser */ LambertCompute "Design Tools" myLambert' ]);

%% 获取整个机动过程的总脉冲变量
result=root.ExecuteCommand('ComponentBrowser_RM */ GetValue "Design Tools" myLambert LambertResult');
total_delta=result.Item(23);
V_begin=strfind(total_delta,'=');
V_end=strfind(total_delta,'m*sec^-1');
delta_all=str2num(total_delta(V_begin+1:V_end-1));
J=delta_all;
end