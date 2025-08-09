function X_t=CW(X_0,n,t)
%% 参考链接
% https://blog.csdn.net/weixin_57997461/article/details/136787786
% X_0 为初始状态
% n   为角速度
% t   为时间
Matrix=[1,           0,  6*n*t - 6*sin(n*t), (4*sin(n*t) - 3*n*t)/n,          0, -(2*cos(n*t) - 2)/n;
        0,    cos(n*t),                   0,                      0, sin(n*t)/n,                   0;
        0,           0,      4 - 3*cos(n*t),     (2*cos(n*t) - 2)/n,          0,          sin(n*t)/n;
        0,           0, -6*n*(cos(n*t) - 1),         4*cos(n*t) - 3,          0,          2*sin(n*t);
        0, -n*sin(n*t),                   0,                      0,   cos(n*t),                   0;
        0,           0,        3*n*sin(n*t),            -2*sin(n*t),          0,            cos(n*t)];
X_t=Matrix*X_0;
end

