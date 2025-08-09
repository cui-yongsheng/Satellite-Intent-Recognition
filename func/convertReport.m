function T = convertReport(result, hasHeader)
%% CONVERTREPORT 报告数据解析函数（支持自定义表头配置和空行处理）
% 功能：将STK报告数据转换为结构化表格形式，并允许指定是否包含表头
% 输入：
%   result - STK报告原始内容（字符串数组）
%   hasHeader - 布尔值，表示输入数据是否包含表头行（true/false）
% 输出：
%   T - 解析后的table格式数据，包含数值型列数据

% 参数检查
if ~islogical(hasHeader) && ~(isscalar(hasHeader) && isnumeric(hasHeader))
    error('hasHeader参数必须为逻辑值');
end

% 过滤空行
validLines = ~cellfun('isempty', result) & ~cellfun(@(x) all(isspace(x)), result);
if ~any(validLines)
    error('输入数据中不包含有效数据行');
end
cleanedData = result(validLines);

% 将每行数据按逗号分隔成单元格数组
splitData = cellfun(@(x) strsplit(x, ','), cleanedData, 'UniformOutput', false);

% 检查splitData是否为空
if isempty(splitData)
    error('输入数据为空，无法解析');
end

% 提取表头信息或使用默认字段名
if hasHeader
    % 表头存在时提取
    headers = splitData{1};            % 第一行作为表头
    dataRows = splitData(2:end);       % 剩余行为数据行
else
    % 表头不存在时生成默认字段名
    sampleRow = splitData{1};          % 使用第一行数据确定列数
    numColumns = length(sampleRow);
    headers = matlab.lang.makeValidName(strcat('Col', string(1:numColumns))); % 默认列名
    dataRows = splitData;              % 所有行均为数据行
end

% 垂直拼接数据行
dataMatrix = vertcat(dataRows{:});

% 创建带字段名的表格
T = cell2table(dataMatrix, 'VariableNames', headers);

% 将除第一列外的所有列转换为数值类型
for i = 2:width(T)
    T.(i) = str2double(T.(i));
end
end

