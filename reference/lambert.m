function J=lambert(t_min)
global root rx ry rz vx vy vz; % ����ȫ�ֱ���
time_step=60;   % �Ż�����
t_min=floor(t_min); % �����������ת��Ϊ������
% Todo : ���������Ż�
StartTime='26 Jan 2024 04:00:00.000';
StopTime = '10 Feb 2024 04:00:00.000';  
sec=t_min*60;
data_red=root.ExecuteCommand(['Report_RM */Satellite/target Style "Inertial Position Velocity" TimePeriod "',StartTime,'" "',StopTime,'" TimeStep ',num2str(time_step)]);
data_Line=data_red.count;
for i=1:data_Line-2
    struct=regexp(data_red.Item(i),',','split');
    End_time(i)=struct(1);
end
End_time_str=string(End_time(t_min+1));% �ҵ���Ӧʱ���Ӧ�ı���
for i=1:data_Line-2
    struct=regexp(data_red.Item(i),',','split');
    time_end=string(struct(1));
    if time_end==End_time_str
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
result=root.ExecuteCommand('ComponentBrowser_RM */ GetValue "Design Tools" myLambert LambertResult');
total_delta=result.Item(23);
V_begin=strfind(total_delta,'=');
V_end=strfind(total_delta,'m*sec^-1');
delta_all=str2num(total_delta(V_begin+1:V_end-1));
J=delta_all;
end