function tleStruct = readtle(file, catalog)
%% READTLE 读取NORAD两行轨道根数（TLE）文件
% 功能：从标准的NORAD TLE文件中读取卫星轨道数据
% 输入：
%   file    - TLE文件的路径（字符串）
%   catalog - 可选参数，指定需要读取的卫星NORAD目录编号数组（数值数组）
% 输出：
%   tleStruct - 包含卫星轨道信息的结构体数组，字段包括：
%     - SatelliteName: 卫星名称
%     - CatalogNumber: NORAD目录编号
%     - EpochTime: 历元时间（字符串格式）
%     - Inclination: 轨道倾角（度）
%     - RightAscensionOfAscendingNode: 升交点赤经（度）
%     - Eccentricity: 轨道偏心率
%     - ArgumentOfPeriapsis: 近地点幅角（度）
%     - MeanAnomaly: 平近点角（度）
%     - MeanMotion: 平均运动（rev/day）
%     - Period: 轨道周期（秒）
%     - SemiMajorAxis: 半长轴（米）
%     - SemiMinorAxis: 半短轴（米）

% Brett Pantalone
% North Carolina State University
% Department of Electrical and Computer Engineering
% Optical Sensing Laboratory
% mailto:bapantal@ncsu.edu
% http://research.ece.ncsu.edu/osl/

% 检查输入参数数量，若未提供catalog参数，则设置为空数组
if nargin < 2
    catalog = [];
end

% 初始化输出结构体模板
tleStruct = struct('SatelliteName', ...
                   'CatalogNumber', ...
                   'EpochTime', ...
                   'Inclination', ...
                   'RightAscensionOfAscendingNode', ...
                   'Eccentricity', ...
                   'ArgumentOfPeriapsis', ...
                   'MeanAnomaly',  ...
                   'MeanMotion', ...
                   'Period', ...
                   'SemiMajorAxis', ...
                   'SemiMinorAxis');

% 打开输入文件
fd = fopen(file, 'r');
% 如果文件无法打开，尝试添加.tle扩展名再次打开
if fd < 0
    fd = fopen([file '.tle'], 'r');
end
% 如果仍无法打开文件，抛出错误
assert(fd > 0, ['Can''t open file ' file ' for reading.'])

% 初始化卫星计数器
n = 0;

% 逐行读取文件内容
A0 = fgetl(fd); % 卫星名称
A1 = fgetl(fd); % 第一行数据（TLE Line 1）
A2 = fgetl(fd); % 第二行数据（TLE Line 2）

% 循环读取文件直到结束
while ischar(A2)
    % 获取卫星NORAD目录编号
    satnum = str2double(A1(3:7));
    
    % 如果catalog为空或当前卫星在感兴趣目录中
    if isempty(catalog) || ismember(satnum, catalog)
        % 增加计数器
        n = n + 1;
        
        % 存储卫星名称
        tleStruct(n).SatelliteName = A0;
        
        % 验证第一行校验和
        assert(chksum(A1), 'Checksum failure on line 1')
        % 验证第二行校验和
        assert(chksum(A2), 'Checksum failure on line 2')
        
        % 存储目录编号
        tleStruct(n).CatalogNumber = satnum;
        
        % 存储历元时间
        tleStruct(n).EpochTime = A1(19:32);
        
        % 解析轨道倾角（度）
        Incl = str2double(A2(9:16));
        tleStruct(n).Inclination = Incl;
        
        % 解析升交点赤经（度）
        Omega = str2double(A2(18:25));
        tleStruct(n).RightAscensionOfAscendingNode = Omega;
        
        % 解析轨道偏心率（注意格式转换）
        ecc = str2double(['.' A2(27:33)]);
        tleStruct(n).Eccentricity = ecc;
        
        % 解析近地点幅角（度）
        w = str2double(A2(35:42));
        tleStruct(n).ArgumentOfPeriapsis = w;
        
        % 解析平近点角（度）
        M = str2double(A2(44:51));
        tleStruct(n).MeanAnomaly = M;
        
        % 解析平均运动（rev/day）
        N = str2double(A2(53:63));
        tleStruct(n).MeanMotion = N;
        
        % 计算轨道周期（秒）
        T = 86400 / N;
        tleStruct(n).Period = T;
        
        % 计算半长轴（米）
        a = ((T / (2 * pi))^2 * 398.6e12)^(1/3);
        tleStruct(n).SemiMajorAxis = a;
        
        % 计算半短轴（米）
        b = a * sqrt(1 - ecc^2);
        tleStruct(n).SemiMinorAxis = b;

        % 计算真近点角（度）
        trueAnomaly = mean2trueAnomaly(M, ecc);
        tleStruct(n).TrueAnomaly = trueAnomaly;
    end
    
    % 继续读取下一行数据
    A0 = fgetl(fd);
    A1 = fgetl(fd);
    A2 = fgetl(fd);
end

% 关闭文件
fclose(fd);

end

%% 校验和验证函数
% 功能：验证TLE行的校验和
% 输入：
%   str - TLE的一行数据（字符串）
% 输出：
%   result - 校验和验证结果（逻辑值）
function result = chksum(str)
    result = false;
    c = 0;
    
    % 计算字符的校验值
    for k = 1:68
        % 数字字符累加其值
        if str(k) > '0' && str(k) <= '9'
            c = c + str(k) - 48;
        % 减号字符累加1
        elseif str(k) == '-'
            c = c + 1;
        end
    end
    
    % 验证校验和是否匹配
    if mod(c, 10) == str(69) - 48
        result = true;
    end
end
    
%% 平近点角转真近点角函数
% 功能：使用牛顿-拉斐森方法迭代求解真近点角
% 输入：
%   M: 平近点角（度）
%   e: 偏心率
% 输出：
%   true_anomaly: 真近点角（度）
function trueAnomaly = mean2trueAnomaly(meanAnomaly, eccentricity)
    % 参数检查
    if ~all(size(meanAnomaly) == size(eccentricity)) && ...
       ~(isscalar(eccentricity) || isscalar(meanAnomaly))
        error('meanAnomaly 和 eccentricity 必须具有兼容的尺寸');
    end
    
    % 将偏心率和平近点角转换为列向量进行处理
    eccentricity = eccentricity(:);
    meanAnomaly = meanAnomaly(:);
    
    % 初始化偏心近点角为平近点角
    E = deg2rad(meanAnomaly);
    
    % 牛顿-拉斐森方法迭代精度和最大迭代次数
    NREPS = 1.0E-6;              % 迭代精度
    NRITERMAX = 2000;            % 最大迭代次数
    i = 0;                       % 迭代计数器
    
    % 对每个输入值执行迭代
    for j = 1:numel(E)
        while abs(meanAnomaly(j) - rad2deg(E(j)) + deg2rad(eccentricity(j) * sin(E(j)))) >= NREPS && i < NRITERMAX
            fE = E(j) - eccentricity(j) * sin(E(j)) - deg2rad(meanAnomaly(j));
            dE = fE / (1 - eccentricity(j) * cos(E(j)));
            E(j) = E(j) - dE;
            i = i + 1;
        end
    end
    
    % 计算真近点角
    F = 2 * atan(tan(E / 2) .* sqrt((1 + eccentricity) ./ (1 - eccentricity)));
    trueAnomaly = mod(rad2deg(F'), 360);  % 转换为度并归一化到[0, 360)
end