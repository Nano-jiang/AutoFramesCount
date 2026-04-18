 % clear
 % close all
 % clc

%%
position1 = behav.position;

%%

trialkeep = (1:size(labelbehav0,1));

labelframe02 = labelframe00(trialkeep,:);
labelbehav = labelbehav0(trialkeep,:);
positionS = cell(length(trialkeep),3);
positionfms = cell(length(trialkeep),3);
for i1 = 1:3
    for j1 =  1:length(trialkeep)
        fms_temp = labelframe02(j1,(i1-1)*2+1):labelframe02(j1,i1*2);
        positionS{j1,i1} = position1(fms_temp,:);
        positionfms{j1,i1} = fms_temp';
    end
end

%% 显示某一条trajectory
% figure
% Show entire trajectory and S2 trajecotry
% 
% imshow(behav.background),hold on
% 
% pos_scale = [ behav.trackLength/behav.ROI(3), behav.trackLength/behav.ROI(4)];
% position1 = behav.position;
% 
% j1 = 33; % 输入需要检测的trajectory
%     postemp = positionS{j1,1};
%     plot(postemp(:,1) / pos_scale(1), postemp(:,2) / pos_scale(2), 'r');
%     postemp = positionS{j1,2};
%     plot(postemp(:,1)/pos_scale(1),postemp(:,2)/pos_scale(2),'b')
%     postemp = positionS{j1,3};
%     plot(postemp(:,1)/pos_scale(1),postemp(:,2)/pos_scale(2),'g')
%     hold on
% 
% axis ij

%% 显示所有trajectory
% 显示背景图像
imshow(behav.background), hold on

% 计算位置缩放比例
pos_scale = [behav.trackLength / behav.ROI(3), behav.trackLength / behav.ROI(4)];
position1 = behav.position;

numCols = 6; % 网格中的列数
numRows = ceil(length(positionS) / numCols); % 网格中的行数

% 设置每个子图的边距和间距
margin = 0.01; % 边距
spacing = 0.01; % 间距

% 计算每个子图的宽度和高度
subplotWidth = (1 - (numCols + 1) * margin) / numCols;
subplotHeight = (1 - (numRows + 1) * margin) / numRows;

for j1 = 1:length(positionS)
    % 计算当前子图的位置
    row = ceil(j1 / numCols);
    col = mod(j1 - 1, numCols) + 1;
    
    % 计算子图的左下角坐标
    left = margin + (col - 1) * (subplotWidth + margin);
    bottom = 1 - row * (subplotHeight + margin);
    
    % 创建子图
    subplot('Position', [left, bottom, subplotWidth, subplotHeight]);
    
    % 显示背景图像
    imshow(behav.background), hold on
    
    % 绘制轨迹
    postemp = positionS{j1,1};
    plot(postemp(:,1) / pos_scale(1), postemp(:,2) / pos_scale(2), 'w');

    postemp = positionS{j1,2};
    plot(postemp(:,1) / pos_scale(1), postemp(:,2) / pos_scale(2), 'b');
    
    postemp = positionS{j1,3};
    plot(postemp(:,1) / pos_scale(1), postemp(:,2) / pos_scale(2), 'g');
    
    hold on
    
    % 标记子图
    title(['Iteration ' num2str(j1)]);
    
    axis ij;
end

%%
saveas(gcf, 'TrajectoryCheckPlot.fig');
movefile('TrajectoryCheckPlot.fig', 'FrameCount');
