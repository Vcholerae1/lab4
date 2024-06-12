clear;

% 本代码用于重力数据的综合处理，包括固体潮校正、地形校正、纬度校正值、
% 中间层校正、高度校正
% 输入文件需要保持和示例文件同样的格式
% 重要：假设你已经完成了平差的内容，输入文件的观测值为平差之后的重力值
% 
% 作者：V.cholerae
%
% 如果对你有帮助请在github上为这个项目添加一个Star
% https://github.com/Vcholerae1/lab4

%%
% 以下为用户自行修改内容

% 在这里修改你的文件名
tablename = "重力实验.xlsx";

% 在这里选择是否进行地形矫正（要求必须存在对应的八分位高程数据）
is_terrain = true;
% 在这里添加八分位高程数据的文件名（不校正保持空字符串即可）
terrain_table_name = "地形";


% 建议不修改下面的内容
%% 提取数据部分
% 将表格读取为cell类型
celldata = readcell(tablename);


% 从cell中提出有用的信息为数组
Longtitude = cell2mat(celldata(2:end,3));
Latitude = cell2mat(celldata(2:end,2));
height = cell2mat(celldata(2:end,4));
year = cell2mat(celldata(2:end,5));
mouth = cell2mat(celldata(2:end,6));
day = cell2mat(celldata(2:end,7));

% 这里将提取类似"HH：mm"格式的时间数据的小时数据
timeData = celldata(2:end,8);
% 将数值格式的时间数据转换为字符串格式
timeStrings = cellfun(@(x) datestr(x, 'HH:MM'), timeData, 'UniformOutput', false);
% 将字符串格式的时间数据转换为 datetime 类型并提取Hour
Hour = datetime(timeStrings, 'InputFormat', 'HH:mm').Hour;

grav = cell2mat(celldata(2:end,9));

%% 固体潮校正

% 预分配数组提高效率
earthtide = zeros(size(grav));

% 计算固体潮校正值，单位为mGal 
for i = 1:size(height,1)
earthtide(i) = Tide_Correction(Longtitude(i),Latitude(i),[year(i),mouth(i),day(i)],Hour(i));
end

%% 地形校正（可选）

if is_terrain == true
   t_data = readcell(terrain_table_name);
% 提取数据并转换为矩阵
angles = [2, 3, 4, 5, 6, 7, 8, 9];
t_values = cell2mat(t_data(2:end, angles));
% 计算 delta_t
G = 6.67e-11;
constant = 2 * pi * G * 2.67 * 10 * 1e8;
delta_t = constant * sum(1 - sqrt(100 ./ (100 + t_values.^2)), 2);   
else 
    delta_t = 0;
end

%% 纬度校正（正常场校正）

% 小面积测量采用相对改正
% 首先计算xy坐标(基于WGS84坐标系)
% 这里需要使用matlab的Mapping ToolBox
% 没装的话可以在网上转换之后手动编辑x，y数组
proj = projcrs(32610);
[x,y] = projfwd(proj,Latitude,Longtitude);

% 以第一个点为总基点，进行改正
x_ref = x(1);
% 单位：km
x_shift = (x - x_ref)/1000;
% 单位：mGal
delta_g_phi = -8.14*sin(2 * Latitude) .* x_shift ./ 10;

%% 中间层校正

% 密度取地壳平均密度 2.67 g/cm^3
% 单位 mGal
delta_g_sigma = -0.419 * 2.67 * height ./ 10;

%% 高度校正

% 单位：mGal
delta_g_h = 3.086 * height ./ 10;

%% 布格改正

% 单位：mGal
delta_b = delta_g_sigma + delta_g_h;

%% 布格重力异常

% 这里还是用第一个数据作为总基点
g_ref = grav(1);

delta_g = grav - g_ref + delta_g_h + delta_t + delta_g_phi + delta_g_sigma;

%% 将结果写入表格

% 创建新的表格，将原始数据和新计算的数据合并
output_data = [celldata(2:end,:), num2cell(earthtide), num2cell(delta_t), num2cell(delta_g_phi), num2cell(delta_g_sigma), num2cell(delta_g_h), num2cell(delta_b), num2cell(delta_g)];

% 添加列标题
header = [celldata(1,:), {'固体潮改正值', '地形改正值', '正常场改正值', 
    '中间层改正值', '高度改正值', '布格改正', '相对布格重力异常'}];
output_data = [header; output_data];

% 写入Excel文件
writecell(output_data, '重力数据处理结果.xlsx');

disp('处理完成，结果已保存为重力数据处理结果.xlsx');











