function [visible_segments, visible_time, visible_lengths, visible_mask] = segmentVisible(pos_target, pos_obs, time_series, view_angle)
%SEGMENTVISIBLE 用于生成卫星可见段
%   输入
%       1.pos_target        被观测卫星坐标
%       2.pos_obs           观测卫星坐标
%       3.time_series       位置对应时间序列
%       4.view_angle        可视角度（度）

%   输出
%       1.visible_segments  一个包含所有可见段的位置序列
%       2.visible_time      一个包含所有可见段的时间序列
%       3.visible_lengths   可见段长度
%       4.visible_mask      可视index

% 获取最小的时间步数
num_rows = min(size(pos_target, 1), size(pos_obs, 1));
pos_target_copy = pos_target(1:num_rows,:);
pos_target = pos_target(1:num_rows,1:3);
pos_obs = pos_obs(1:num_rows,1:3);
% 将可视角度转换为弧度
view_angle_rad = deg2rad(view_angle);
% 定义相机在全局坐标系中的方向
cam_direction = pos_obs./ vecnorm(pos_obs, 2, 2); 
% 计算所有方向向量（vBA）
vBA = pos_target - pos_obs;
% 计算每个方向向量的单位向量
vBA_unit = vBA ./ vecnorm(vBA, 2, 2);
% 计算相机方向与vBA之间的夹角的余弦值
cos_alpha = sum(vBA_unit .* cam_direction,2); % 计算点积
alpha = acos(cos_alpha);
% 找到所有满足夹角小于等于可视角度的时间步
visible_mask = alpha <= view_angle_rad;
% 使用 find 和 diff 找到切换点
visible_edges = find(diff([0;visible_mask])>0); % 0 用于确保段的开始
segment_endings = find(diff([visible_mask; 0])<0); % 0 用于确保段的结束
% 提取所有可见段
visible_segments = cell(length(visible_edges),1);
visible_time = cell(length(visible_edges),1);
visible_lengths = zeros(length(visible_edges),1);
for i = 1:length(visible_edges)
    start_idx = visible_edges(i);
    end_idx = segment_endings(i);
    visible_segments{i} = pos_target_copy(start_idx:end_idx, :); % 提取该段
    visible_time{i} = time_series(start_idx:end_idx,:);
    visible_lengths(i) = end_idx-start_idx+1;
end
end
