function X_t=CW(X_0,n,t)
%% CW 轨道相对动力学传播函数
% 功能：基于Clohessy-Wiltshire方程计算轨道动力学状态传播
%       参考链接：https://blog.csdn.net/weixin_57997461/article/details/136787786
% 输入：
%   X_0 - 初始状态向量 [x y z vx vy vz]
%   n   - 轨道角速度 (rad/s)
%   t   - 传播时间 (s)
% 输出：
%   X_t - 经过时间t后的新状态向量 [x y z vx vy vz]
%
% 示例：
%   X_0 = [100; 200; 50; 0.1; 0.2; 0.05]; % 初始状态
%   n = sqrt(mu/a^3);                    % 轨道角速度计算
%   t = 600;                             % 传播时间10分钟
%   X_t = CW(X_0, n, t);                 % 计算新状态
%
% 注意事项：
% - 本函数基于线性化的CW方程，适用于近距离相对运动
% - 所有角度参数需以弧度为单位
% - 状态向量包含位置和速度分量，顺序为[x y z vx vy vz]

% 构建状态转移矩阵
Matrix=[1,           0,  6*n*t - 6*sin(n*t), (4*sin(n*t) - 3*n*t)/n,          0, -(2*cos(n*t) - 2)/n;
        0,    cos(n*t),                   0,                      0, sin(n*t)/n,                   0;
        0,           0,      4 - 3*cos(n*t),     (2*cos(n*t) - 2)/n,          0,          sin(n*t)/n;
        0,           0, -6*n*(cos(n*t) - 1),         4*cos(n*t) - 3,          0,          2*sin(n*t);
        0, -n*sin(n*t),                   0,                      0,   cos(n*t),                   0;
        0,           0,        3*n*sin(n*t),            -2*sin(n*t),          0,            cos(n*t)];

% 计算新状态
X_t=Matrix*X_0;
end

