%% Mouse Tracking based on head-mounted Red LED

% 对每一帧小鼠位置识别进行了优化（采用3点平均）

%% 统计文件夹中的视频数
% 指定 behavCam*.avi 文件夹路径
currentFile = pwd;

% 获取以 behavCam开头，.avi 结尾的文件列表
files = dir(fullfile(currentFile, 'behavCam*.avi'));

% 计算视频文件数量
behavCamNumber = length(files);

disp(['文件夹中共有 ', num2str(behavCamNumber), ' 个 behavCam 视频文件。']);

%% 创建一个存储所有视频文件名的单元数组
behavCamFiles = cell(behavCamNumber, 1);

% 依次填充视频文件名到数组中
for i = 1:behavCamNumber
    behavCamFiles{i} = sprintf('behavCam%d.avi', i);
end

%% 将behavCam文件按照顺序排列

% 获取文件列表
behavCamFiles = dir('behavCam*.avi');

% 提取文件名
fileNames = {behavCamFiles.name};

% 使用正则表达式提取文件名中的数字: (\d+), tokens: 返回捕获组的内容
fileNums = regexp(fileNames, 'behavCam(\d+)\.avi', 'tokens');

% 将嵌套的元胞数组转换为数字数组
% 语法：cellfun(func, C)，其中 func 是要应用的函数，C 是单元格数组
fileNums = cellfun(@(x) str2double(x{1}), fileNums);

% 按照数字对文件名进行排序
[~, sortIdx] = sort(fileNums);

% 重新排列文件列表
behavCamFiles = behavCamFiles(sortIdx);

selectedFrameInfo = struct('videoFile', '', 'frameNumber', []);

%% 通过框 Red LED 获取框选区 roi 的位置
% 初始化窗口位置和大小变量
windowPosition = [];

% 遍历每个视频文件，选择红色LED出现的帧
for vi = 1:behavCamNumber
    videoFile = behavCamFiles(vi).name;
    videoObj = VideoReader(videoFile);
    numFrames = videoObj.NumFrames;
    
    % 从视频文件的第一帧开始，每隔50帧处理一次
    for frameNumber = 1:50:numFrames
        frame = read(videoObj, frameNumber);
        
        % 创建显示窗口
        fig = figure('Name', 'Frame Selection', 'WindowStyle', 'normal');
        if ~isempty(windowPosition)
            set(fig, 'Position', windowPosition);
        end
        imshow(frame);
        
        % 获取用户输入
        prompt = '是否根据此帧选择红色的LED区域？（请选择 yes/no）: ';
        userInput = input(prompt, 's');
        
        % 记录窗口位置和大小
        windowPosition = get(fig, 'Position');
        
        if strcmpi(userInput, 'yes') || strcmpi(userInput, 'y')
            selectedFrameInfo.videoFile = videoFile;
            selectedFrameInfo.frameNumber = frameNumber;
            title('请框选LED区域');
            h = imrect;
            roi = round(getPosition(h)); % 使用imrect获取用户框选的矩形区域
            close(fig);
            break;
        else
            close(fig);
        end
    end
    
    % 如果用户已经选择了一帧，则退出所有循环
    if ~isempty(selectedFrameInfo.videoFile)
        break;
    end
end

% 输出选择的帧信息
if ~isempty(selectedFrameInfo.videoFile)
    fprintf('选择的帧来自文件 %s 的第 %d 帧\n', selectedFrameInfo.videoFile, selectedFrameInfo.frameNumber);
else
    fprintf('没有选择任何帧\n');
end

%% 计算像素点颜色

selectFrame = frame;

% 提取框选区域中的颜色信息
ledRegion = selectFrame(roi(2):roi(2)+roi(4)-1, roi(1):roi(1)+roi(3)-1, :);

% 计算每个像素与红色的差异
considerRed = [255, 130, 165];
% considerRed = [255, 201, 213];
diff = sqrt(sum((double(ledRegion) - reshape(considerRed, [1 1 3])).^2, 3));

% 找到差异最小的10个像素点
[~, sortedIdx] = sort(diff(:));
numPixels = 10; % 取最接近红色的10个像素点
selectedIdx = sortedIdx(1:numPixels);

% 获取这些像素点的颜色值
[rows, cols] = ind2sub(size(diff), selectedIdx);
selectedColors = zeros(numPixels, 3);
for i = 1:numPixels
    selectedColors(i, :) = ledRegion(rows(i), cols(i), :);
end

% 计算这10个像素点的平均颜色
ledColor = mean(selectedColors, 1);

% 初始化一些变量
positions = []; % 用于存储小鼠位置
threshold = 30; % 颜色匹配的阈值，可以调整

%% 创建一个图像句柄和轨迹句柄
figure;
hIm = imshow(selectFrame);
hold on;
hPlot = plot(NaN, NaN, 'r.');

% 遍历视频帧
previousPosition = [];

% % Tmaze_division中已经定义了S1, S2, S3的范围
Region_S1round = round(Region_S1);
Region_S2round = round(Region_S2);
Region_S3round = round(Region_S3);

% 创建一个与frame大小相同的逻辑矩阵，初始化为false
mask = false(size(frame, 1), size(frame, 2));

% 将S1, S2, S3范围内的像素置为true, 目的是排除led映射在墙面上的红色被纳入运算
mask(Region_S1round(2):Region_S1round(2)+Region_S1round(4)-1, Region_S1round(1):Region_S1round(1)+Region_S1round(3)-1) = true;
mask(Region_S2round(2):Region_S2round(2)+Region_S2round(4)-1, Region_S2round(1):Region_S2round(1)+Region_S2round(3)-1) = true;
mask(Region_S3round(2):Region_S3round(2)+Region_S3round(4)-1, Region_S3round(1):Region_S3round(1)+Region_S3round(3)-1) = true;

for vi = 1:behavCamNumber
    video = behavCamFiles(vi).name;
    vid = VideoReader(video);
    frameNum = vid.NumFrames;

    for i = 1:frameNum

        frame = read(vid, i);
                
        % 计算每个像素与LED颜色的差异，但仅限于mask为true的位置
        diff = sqrt(sum((double(frame) - reshape(ledColor, [1 1 3])).^2, 3));
        diff(~mask) = inf; % mask为false的位置设为inf，不参与后续计算
        
        % 找到颜色差异最小的3个点的坐标
        [minDiffs, idx] = mink(diff(:), 3);
        currentPositions = NaN(3, 2);
        for j = 1:3
            if minDiffs(j) < threshold
                [y, x] = ind2sub(size(diff), idx(j));
                currentPositions(j, :) = [x, y]; % 记录当前帧的位置
            else
                currentPositions(j, :) = [NaN, NaN]; % 无效位置
            end
        end

        
        % 若3个点都不是NaN，分别计算两两之间的距离
        point1 = currentPositions(1,:);
        point2 = currentPositions(2,:);
        point3 = currentPositions(3,:);
        ledRegion = 10; % Red LED 的像素长宽一般不会大于这个值

        if all([~isnan(point1), ~isnan(point2), ~isnan(point3)])
            distance12 = calculateDistance(point1,point2);
            distance13 = calculateDistance(point1,point3);
            distance23 = calculateDistance(point2,point3);
            if all([(distance12 <= ledRegion), (distance13 <= ledRegion), (distance23 <= ledRegion)])
                currentPosition = (point1 + point2 + point3)/3;
            else
                currentPosition = [NaN,NaN];
            end           
        else
            currentPosition = [NaN,NaN];
        end
                
        positions = [positions; currentPosition];

        previousPosition = currentPosition; % 更新前一帧的位置
        
        % 更新图像和轨迹
        set(hIm, 'CData', frame);
        
        % 只显示最近100帧的轨迹
        if size(positions, 1) > 100
            recentPositions = positions(end-99:end, :);
        else
            recentPositions = positions;
        end
        set(hPlot, 'XData', recentPositions(:, 1), 'YData', recentPositions(:, 2));
        
        drawnow;
    end
end
hold off;
title('小鼠运动轨迹');

%% 插值填充 NaN
nanInd = any(isnan(positions), 2); % 找到包含 NaN 的行
positions(nanInd, :) = interp1(find(~nanInd), positions(~nanInd, :), find(nanInd), 'linear'); % 使用线性插值填充 NaN
% positions = round(positions);

% 填充 NaN
nanInd = any(isnan(positions), 2); % 找到包含 NaN 的行
for i = 1:length(nanInd)
    if nanInd(i)
        if i == 1
            % positions(i, :) = round(positions(find(~nanInd, 1, 'first'), :));
            positions(i, :) = (positions(find(~nanInd, 1, 'first'), :));
        else
            % positions(i, :) = round(positions(i - 1, :));
            positions(i, :) = (positions(i - 1, :));
        end
    end
end

%% 绘制小鼠原始路径
x = positions(:,1);
y = positions(:,2);

figure
plot(x,y);
% save("mouseTrajectory_origin.png");
% close

%% 用高斯滤波对小鼠路径进行平滑处理
% 高斯滤波器
sigma = 1.5; % 标准差，可以根据需要调整, 之前是1
positions_smoothed(:, 1) = imgaussfilt(positions(:, 1), sigma);
positions_smoothed(:, 2) = imgaussfilt(positions(:, 2), sigma);

x_smoothed = positions_smoothed(:, 1);
y_smoothed = positions_smoothed(:, 2);

figure
plot(x_smoothed, y_smoothed);
% save("mouseTrajectory_smooth.png");
% close

%%
save("mouseTrajectory.mat","positions","positions_smoothed");
movefile('mouseTrajectory.mat', 'FrameCount2');

