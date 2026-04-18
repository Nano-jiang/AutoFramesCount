% mouseTracePlot

%%
trialFrame = cell(size(BehaviorTable,1),1);
trialStamp = cell(size(BehaviorTable,1),1);
for i = 1:size(BehaviorTable,1)
    trialFrame{i} = BehaviorTable(i,1):BehaviorTable(i,6);
    trialStamp{i} = positions_smoothed(BehaviorTable(i,1):BehaviorTable(i,6),:);
end

CorrectTrial_idx = find(BehaviorTable(:,9) == 1);
ErrorTrial_idx = find(BehaviorTable(:,9) == 0);
LeftTrial_idx = find(BehaviorTable(:,8) == 1);
RightTrial_idx = find(BehaviorTable(:,8) == 2);

%%
% figure;
% numTrials = length(trialStamp);
% rows = 7;
% cols = 6;
% 
% for i = 1:numTrials
%     subplot(rows, cols, i);  % 创建子图
%     rectangle('Position', Region_S1, 'EdgeColor', [0.7 0.7 0.7]);
%     rectangle('Position', Region_S2, 'EdgeColor', [0.7 0.7 0.7]);
%     rectangle('Position', Region_S3, 'EdgeColor', [0.7 0.7 0.7]);
%     hold on;
%     X = trialStamp{i}(:,1);
%     Y = trialStamp{i}(:,2);
%     plot(X, Y, 'r');
%     axis equal;
%     axis tight;
%     set(gca, 'YDir', 'reverse');  % 翻转 Y 轴
%     axis off;                     % 隐藏坐标轴
%     title(['Trial ' num2str(i)]);
%     hold off;
% end
% 
% saveas(gcf, 'TrajectoryCheckPlot2.fig');
% movefile('TrajectoryCheckPlot2.fig', 'FrameCount2');
%%
numTrials = length(trialStamp);
rows = 8;
cols = 6;

figure('Units', 'normalized', 'Position', [0, 0, 1, 1]);

% 间距参数
hGap = 0.002;
vGap = 0.01;

% 预留顶部空白（为标题留出空间）
topMargin = 0.01;  % ↑↑↑ 关键改动：顶部边距
bottomMargin = 0.01;
height = (1 - topMargin - bottomMargin - (rows - 1) * vGap) / rows;
width = (1 - (cols + 1) * hGap) / cols;

for i = 1:numTrials
    row = floor((i - 1) / cols);
    col = mod((i - 1), cols);
    
    left = hGap + col * (width + hGap);
    bottom = bottomMargin + (rows - 1 - row) * (height + vGap);
    
    ax = subplot('Position', [left, bottom, width, height * 0.93]);
    rectangle('Position', Region_S1, 'EdgeColor', [0.7 0.7 0.7]);
    rectangle('Position', Region_S2, 'EdgeColor', [0.7 0.7 0.7]);
    rectangle('Position', Region_S3, 'EdgeColor', [0.7 0.7 0.7]);
    hold on;
    X = trialStamp{i}(:,1);
    Y = trialStamp{i}(:,2);
    plot(X, Y, '');
    axis equal tight;
    set(gca, 'YDir', 'reverse');
    axis off;
    title(['Trial ' num2str(i)], 'FontSize', 10);
    hold off;
end

saveas(gcf, 'TrajectoryCheckPlot2.fig');
movefile('TrajectoryCheckPlot2.fig', 'FrameCount2');
