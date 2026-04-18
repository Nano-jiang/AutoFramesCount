%% 将 Tmaze 区域划分

% 将 Tmaze 划分成 S1，S2，S3 三个区域，保存这 3 个区域各自的范围
% 计算并保存重要的交界线："boundary_S1","boundary_S3left","boundary_S3right","boundary_S1S2","boundary_S2S3"

% 读取视频
videoPath = 'behavCam1.avi';
video = VideoReader(videoPath);

% 读取第一帧
firstFrame = readFrame(video);

% 在第一帧中使用鼠标框选Tmaze区域
disp('请用鼠标框选Tmaze区域');
imshow(firstFrame);
r1 = imrect;
position = wait(r1); % position = [xmin ymin width height]
close(gcf);

%%
% 框选区 position
xmin = position(1); ymin = position(2);
width = position(3); height = position(4);

% S1, S2, S3 各自长宽
height_S1 = 15; width_S1 = 15;
height_S2 = 21; width_S2 = 7;
height_S3 = 16; width_S3 = 47;

% Tmaze (52*47 cm^2)
L = height_S1 + height_S2 + height_S3;
W = width_S3;

% Tmaze position [xmin_T ymin_T width_T height_T]
% width_T/W = height_T/L
xmin_T = xmin; ymin_T = ymin;
width_T = height * (W/L); height_T = height;

% S1 position [xmin_S1 ymin_S1 width_S1zoom height_S1zoom]
xmin_S1 = xmin_T + (W - height_S1)/2 * (width_T/W);
ymin_S1 = ymin_T + (height_S2 + height_S3) * (height_T/L);
width_S1zoom = width_S1 * (width_T/W);
height_S1zoom = height_S1 * (height_T/L);

% S2 position [xmin_S2 ymin_S2 width_S2zoom height_S2zoom]
xmin_S2 = xmin_T + (W - width_S2)/2 * (width_T/W);
ymin_S2 = ymin_T + height_S3 * (height_T/L);
width_S2zoom = width_S2 * (width_T/W);
height_S2zoom = height_S2 * (height_T/L);

% S3 position [xmin_S3 ymin_S3 width_S3zoom height_S3zoom]
xmin_S3 = xmin_T;
ymin_S3 = ymin_T;
height_S3zoom = height_S3 * (width_T/W);
width_S3zoom = width_S3 * (height_T/L);

%%
imshow(firstFrame);

rectangle('Position', [xmin_S1 ymin_S1 width_S1zoom height_S1zoom], 'EdgeColor', 'r', 'FaceColor', [1 0 0 0.3]);
rectangle('Position', [xmin_S2 ymin_S2 width_S2zoom height_S2zoom], 'EdgeColor', 'g', 'FaceColor', [0 1 0 0.3]);
rectangle('Position', [xmin_S3 ymin_S3 width_S3zoom height_S3zoom], 'EdgeColor', 'b', 'FaceColor', [0 0 1 0.3]);

hold on;

Region_S1 = [xmin_S1 ymin_S1 width_S1zoom height_S1zoom];
Region_S2 = [xmin_S2 ymin_S2 width_S2zoom height_S2zoom];
Region_S3 = [xmin_S3 ymin_S3 width_S3zoom height_S3zoom];

%% bowl_o
disp('请选择 bowl_o 圆心位置');
[cx_o, cy_o] = ginput(1);

% 提示用户选择圆上一点以确定半径
disp('请选择 bowl_o 圆上一点');
[x_o, y_o] = ginput(1);

% 计算半径
radius_o = sqrt((x_o - cx_o)^2 + (y_o - cy_o)^2);

% 绘制绿色透明圆形
theta_o = linspace(0, 2*pi, 100);
x_circle_o = cx_o + radius_o * cos(theta_o);
y_circle_o = cy_o + radius_o * sin(theta_o);
fill(x_circle_o, y_circle_o, 'g', 'FaceAlpha', 0.3, 'EdgeColor', 'g', 'LineWidth', 2);

%% bowl_left
disp('请选择 bowl_left 圆心位置');
[cx_left, cy_left] = ginput(1);

% 提示用户选择圆上一点以确定半径
disp('请选择 bowl_left 圆上一点');
[x_left, y_left] = ginput(1);

% 计算半径
radius_left = sqrt((x_left - cx_left)^2 + (y_left - cy_left)^2);

% 绘制绿色透明圆形
theta_left = linspace(0, 2*pi, 100);
x_circle_left = cx_left + radius_left * cos(theta_left);
y_circle_left = cy_left + radius_left * sin(theta_left);
fill(x_circle_left, y_circle_left, 'g', 'FaceAlpha', 0.3, 'EdgeColor', 'g', 'LineWidth', 2);

%% bowl_right
disp('请选择 bowl_right 圆心位置');
[cx_right, cy_right] = ginput(1);

% 提示用户选择圆上一点以确定半径
disp('请选择 bowl_right 圆上一点');
[x_right, y_right] = ginput(1);

% 计算半径
radius_right = sqrt((x_right - cx_right)^2 + (y_right - cy_right)^2);

% 绘制绿色透明圆形
theta_right = linspace(0, 2*pi, 100);
x_circle_right = cx_right + radius_right * cos(theta_right);
y_circle_right = cy_right + radius_right * sin(theta_right);
fill(x_circle_right, y_circle_right, 'g', 'FaceAlpha', 0.3, 'EdgeColor', 'g', 'LineWidth', 2);

%% Tmaze terminal

Yterm_S1 = cy_o - radius_o;
Xterm_S3left = cx_left + radius_left;
Xterm_S3right = cx_right - radius_right;

% S1 terminal [xmin_S1term ymin_S1term width_S1term height_S1term]
xmin_S1term = xmin_S1;
ymin_S1term = Yterm_S1;
width_S1term = width_S1zoom;
height_S1term = height_S1zoom - (Yterm_S1 - ymin_S1);
rectangle('Position', [xmin_S1term ymin_S1term width_S1term height_S1term], 'EdgeColor', 'w', 'FaceColor', [0 0 0 0.3]);

% S3 left terminal [xmin_S3lefterm ymin_S3lefterm width_S3lefterm height_S3lefterm]
xmin_S3lefterm = xmin_S3;
ymin_S3lefterm = ymin_S3;
width_S3lefterm = Xterm_S3left - xmin_S3;
height_S3lefterm = height_S3zoom;
rectangle('Position', [xmin_S3lefterm ymin_S3lefterm width_S3lefterm height_S3lefterm], 'EdgeColor', 'w', 'FaceColor', [0 0 0 0.3]);

% S3 right terminal [xmin_S3righterm ymin_S3righterm width_S3righterm height_S3righterm]
xmin_S3righterm = Xterm_S3right;
ymin_S3righterm = ymin_S3;
width_S3righterm = xmin_S3 + width_S3zoom - Xterm_S3right;
height_S3righterm = height_S3zoom;
rectangle('Position', [xmin_S3righterm ymin_S3righterm width_S3righterm height_S3righterm], 'EdgeColor', 'w', 'FaceColor', [0 0 0 0.3]);

hold off;

%% 基本交界线

% S1 terminal
boundary_S1 = ymin_S1term;

% S3 left terminal
boundary_S3left = xmin_S3lefterm + width_S3lefterm;

% S3 right terminal
boundary_S3right = xmin_S3righterm;

% S1,S2
boundary_S1S2 = ymin_S1;

% S2,S3
boundary_S2S3 = ymin_S2;

%%
save("TmazeRegion.mat","Region_S1","Region_S2","Region_S3");
save("Boundary.mat","boundary_S1","boundary_S3left","boundary_S3right","boundary_S1S2","boundary_S2S3");

mkdir('FrameCount2');
movefile('TmazeRegion.mat', 'FrameCount2');
movefile('Boundary.mat', 'FrameCount2');
