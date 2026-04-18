%% AutoFrameCount_v4
% 上传 Github 版本
% Modified in 2026/04/18
close all; clear; clc;

%% 1. 加载环境路径
% 获取主脚本所在文件夹
rootPath = fileparts(mfilename('fullpath')); 

folders = {'Functions', 'ObjectClassification'};
for i = 1:length(folders)
    target = fullfile(rootPath, folders{i});
    if exist(target, 'dir')
        addpath(genpath(target));
    else
        fprintf('提示：未在当前目录下找到 %s 文件夹\n', folders{i});
    end
end

%% 2. 选择视频所在文件夹
fprintf('请选择视频文件所在的文件夹...\n');
selectedDir = uigetdir(pwd, '选择视频所在文件夹');
if isequal(selectedDir, 0)
    disp('用户取消了选择，程序停止。');
    return;
end
cd(selectedDir);
currentFile = pwd;

%% 3. 初始化区域与LED设置
Tmaze_division
SelectLED_OF

%% 4. 物体识别配置
% 加载分类器
if exist('obj_classifier3.mat', 'file')
    load('obj_classifier3.mat');
else
    error('错误：找不到 obj_classifier3.mat，请确认该文件在 ObjectClassification 文件夹内。');
end

videoFile = 'behavCam1.avi';
video = VideoReader(videoFile);
firstFrame = readFrame(video);

% 图像窗口交互
fprintf('\n请在弹出的图中框选物体区域，双击确认...\n');
figure('Name', '框选物体区域'), imshow(firstFrame);
h = imrect;
objPosition = wait(h); % position = [xmin ymin width height]
close(gcf);

ObjectPredictedLabels = [];
ObjectFrameNums = [];
samplingRate = 50;
net = resnet50;

% 保存设置并移动至指定目录
save('object_selection.mat');
if ~exist('FrameCount2', 'dir'), mkdir('FrameCount2'); end
movefile('object_selection.mat', 'FrameCount2');

targetFolder = fullfile(currentFile, 'FrameCount2');
load(fullfile(targetFolder, 'TmazeRegion.mat'));
load(fullfile(targetFolder, 'Boundary.mat'));
load(fullfile(targetFolder, 'LED_selection.mat'));
load(fullfile(targetFolder, 'object_selection.mat'));

%% 5. 路径追踪与分析
fprintf('\n正在进行小鼠路径追踪...\n');
mouseTracking_redLED_Multi
close all

fprintf('\n正在进行物体识别，请稍后...\n');
obj_Recognition_forBehavCams03

% 生成结果
BehaviorTableGenerator2
TrajectoryCheck2

fprintf('\n分析完成，ヽ(✿ﾟ▽ﾟ)ノ\n');