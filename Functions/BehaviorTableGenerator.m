%% Behavior Table Generator

mousePositions = positions_smoothed;

TotalFrames = size(mousePositions,1);

% mousePositions = behav.position;
% 
% TotalFrames = size(mousePositions,1);


%%
zoneLabel = [];

for i = 1:TotalFrames
   mousePositionX = mousePositions(i,1);
   mousePositionY = mousePositions(i,2);

   % 给不同的zone贴标签
   if (mousePositionY > boundary_S1S2)
       if mousePositionY > boundary_S1
           zoneLabel = vertcat(zoneLabel,"S1 Terminal");
       else
           zoneLabel = vertcat(zoneLabel,"S1");
       end
   
   elseif (mousePositionY <= boundary_S1S2) && (mousePositionY >= boundary_S2S3)
       zoneLabel = vertcat(zoneLabel,"S2");
   
   elseif (mousePositionY < boundary_S2S3)
       if (mousePositionX < boundary_S3left)
           zoneLabel = vertcat(zoneLabel,"S3 Lefterminal");
       elseif (mousePositionX > boundary_S3right)
           zoneLabel = vertcat(zoneLabel,"S3 Righterminal");
       else
           zoneLabel = vertcat(zoneLabel,"S3");
       end
   end
end

%%
S1_start = []; S1_end = [];
S2_start = []; S2_end = [];
S3_start = []; S3_end = [];
% S1_start_correctTrials01 = [];

for i = 1:TotalFrames

   if (i == 1) || ((zoneLabel(i-1) == "S2") && (zoneLabel(i) == "S1"))
       S1_start = vertcat(S1_start,i);
   % elseif ((zoneLabel(i-1) == "S1 Terminal") && (zoneLabel(i) == "S1"))
   %     S1_start_correctTrials01 = vertcat(S1_start_correctTrials01,i);
   elseif (zoneLabel(i-1) == "S1") && (zoneLabel(i) == "S2")
       S1_end = vertcat(S1_end,i-1);
       S2_start = vertcat(S2_start, i);
   elseif (zoneLabel(i-1) == "S2") && (zoneLabel(i) == "S3")
       S2_end = vertcat(S2_end,i-1);
       S3_start = vertcat(S3_start,i);
   elseif (zoneLabel(i-1) == "S3") && ((zoneLabel(i) == "S3 Lefterminal") || (zoneLabel(i) == "S3 Righterminal"))
       S3_end = vertcat(S3_end,i);
   end

end

%%
% S1_start, S1_end, S2_start, S2_end, S3_start, S3_end 已定义为列向量
% 为每个向量添加对应的标签
labels = {'S1_start', 'S1_end', 'S2_start', 'S2_end', 'S3_start', 'S3_end'};

% 将所有的值和对应的标签放在一个矩阵中
candidateFrames = [S1_start; S1_end; S2_start; S2_end; S3_start; S3_end];
candidateLabels = [repmat(labels(1), length(S1_start), 1); ...
                   repmat(labels(2), length(S1_end), 1); ...
                   repmat(labels(3), length(S2_start), 1); ...
                   repmat(labels(4), length(S2_end), 1); ...
                   repmat(labels(5), length(S3_start), 1); ...
                   repmat(labels(6), length(S3_end), 1)];

% 按照candidateFrames排序
[sortedFrames, sortIdx] = sort(candidateFrames);
sortedLabels = candidateLabels(sortIdx);

% 定义所需的标签顺序
% requiredSequence = {'S1_start', 'S1_end', 'S2_start', 'S2_end', 'S3_start', 'S3_end'};
requiredSequence = {'S2_start', 'S2_end', 'S3_start'};

seqLength = length(requiredSequence);

% 初始化用于存储结果的数组
FrameCount = [];
TrialNum = 0;

% 找到所有连续的标签序列
for i = 1:length(sortedLabels) - seqLength + 1
    if isequal(sortedLabels(i:i+seqLength-1), requiredSequence')
        TrialNum = TrialNum + 1;
        FrameCount = [FrameCount; sortedFrames(i:i+seqLength-1)'];
    end
end

%% 确定 'S2_start', 'S2_end', 'S3_start', 'S3_end'

S2_start = FrameCount(:,1);
S2_end = FrameCount(:,2);
S3_start = FrameCount(:,3);

% 寻找与 S3_start 最接近的 S3_end
S3_end_new = [];
for i = 1:length(S3_start)
    for j = 1:length(S3_end)
        if S3_end(j) - S3_start(i) > 0
            S3_end_new = [S3_end_new; S3_end(j)];
            break
        end
    end
end

% 对 S3_end_new，如果存在重复元素，则保留最后一个
% 这一步是为了排除未到达 S3_end 的路径抢夺下一个 S3_end 的情况
[S3_end, S3_end_keep] = unique(S3_end_new, 'last');

S2_start = S2_start(S3_end_keep);
S2_end = S2_end(S3_end_keep);
S3_start = S3_start(S3_end_keep);

%% 寻找 S1_start 和 S1_end

if length(S1_start) > length(S1_end)
    S1_start = S1_start(1:end-1);
end

Time_S1 = [];
trialBelong = [];

if ~(length(S1_end) == length(S2_end))
    
    % 寻找和 S1_end 最接近的 S2_start 的 trial 序号
    for i = 1:length(S1_end)
        Time_S1 = [Time_S1; S1_end(i) - S1_start(i)];
        for j = 1:length(S2_start)
            if S2_start(j) - S1_end(i) > 0
                trialBelong = [trialBelong; j];
                break
            end
        end
    end

    % 寻找 trialBelong 中重复元素的索引
    % 对于每个重复元素，选出它们中对应最大 Time_S1 的，该重复元素在 trialBelong 中的索引被保留 
    [uniqueElements, ~, indices] = unique(trialBelong);
    duplicateIndices = find(histc(indices, 1:numel(uniqueElements)) > 1);
    repeatedElements = uniqueElements(duplicateIndices);
    repIdx1 = arrayfun(@(x) find(trialBelong == x), repeatedElements, 'UniformOutput', false);

    repIdx2 = [];
    for i = 1:length(repeatedElements)
        repIdx1_mat = cell2mat(repIdx1(i));
        [maxVal, maxIdx] = max(Time_S1(repIdx1_mat));
        repIdx2 = [repIdx2; repIdx1_mat(maxIdx)];
    end

    % 寻找 trialBelong 中唯一元素的索引
    elementCounts = accumarray(indices, 1);
    uniqueOnceElements = uniqueElements(elementCounts == 1);
    repIdx3 = find(ismember(trialBelong, uniqueOnceElements));

    unionIdx = union(repIdx2, repIdx3);
    
    S1_start = S1_start(unionIdx);
    S1_end = S1_end(unionIdx);

end

%% 拼接
FrameCount = [S1_start, S1_end, S2_start, S2_end, S3_start, S3_end];
TrialNum = size(FrameCount,1);

%% 确定每一个 Trial 的 Location
Frames_S3_end = S3_end;
Locations = [];
for i = 1:TrialNum
    if zoneLabel(Frames_S3_end(i)) ==  "S3 Lefterminal"
        Locations = vertcat(Locations,1);
    elseif zoneLabel(Frames_S3_end(i)) == "S3 Righterminal"
        Locations = vertcat(Locations,2);
    end
end

Locations = double(Locations);
%% 确定每一个 Trial 的 Object
Frames_S2_end = S2_end;

% 初始化用于存储结果的向量
ObjectFrames = zeros(size(Frames_S2_end));
Objects = [];

% 遍历Frames_S2_end中的每个元素，找到在ObjectFrameNums中最接近的元素
for i = 1:TrialNum
    [~, idx_obj] = min(abs(ObjectFrameNums - Frames_S2_end(i)));
    ObjectFrames(i) = ObjectFrameNums(idx_obj);
    if ObjectFrames(i) == 1
        ObjectLabel = ObjectPredictedLabels(ObjectFrames(i));
    elseif ObjectFrames(i) > 1
        ObjectLabel = ObjectPredictedLabels(ObjectFrames(i)/samplingRate);
    end
    Objects = vertcat(Objects,ObjectLabel);
end

Objects = double(Objects);

%% 确定每一个 Trial 的 Behavior
% Behavior == 1，正确
% Behavior == 0，错误

Behaviors = zeros(size(Objects));

for i = 1:length(Objects)
    if Objects(i) == Locations(i)
        Behaviors(i) = 1;
    else
        Behaviors(i) = 0;
    end
end

%% 根据上一个 trial 的正确与否重新替换部分 S1_start

% S1_start_correctTrials02 = zeros(length(S1_end)-1, 1);
% 
% for i = 2:length(S1_end)
%     S1_start_candidate = S1_start_correctTrials01(S1_start_correctTrials01 < S1_end(i));
%     if ~isempty(S1_start_candidate)
%         max_S1_start_candidate = max(S1_start_candidate);
%         S1_start_correctTrials02(i-1) = max_S1_start_candidate;
%     else
%         S1_start_correctTrials02(i-1) = NaN;
%     end
% end
% 
% for i = 2:TrialNum
% % 如果上一个 Trial 为 correct，就将 S1_start 替换为对应的 S1_start_correctTrials2
%     if Behaviors(i-1) == 1
%         S1_start(i) = S1_start_correctTrials02(i-1);
%     end
% end

%% 整理表格 BehaviorTable

Set = ones(size(Behaviors)); % 可根据需要的Set更换

% S1_start, S1_end, S2_start, S2_end, S3_start, S3_end, Objects, Locations, Behaviors
BehaviorTable = horzcat(FrameCount, Objects, Locations, Behaviors, Set);

% 于 2025/5/12 新加条件，将S1期间一晃而过的trial删除掉
S1_Time = 60; % 在S1所处的时间至少需要 60 frames
diffs = BehaviorTable(:,2) - BehaviorTable(:,1);
BehaviorTable(diffs < S1_Time, :) = [];

correctTrials = sum(BehaviorTable(:,9) == 1);
totalTrials = size(BehaviorTable,1);
Performance = correctTrials/totalTrials;

save("BehaviorResults.mat", "BehaviorTable", "Performance","correctTrials","totalTrials");

% 将矩阵保存为 Excel 表格
writematrix(BehaviorTable, 'BehaviorTable.xlsx');

movefile('BehaviorResults.mat', 'FrameCount');
movefile('BehaviorTable.xlsx', 'FrameCount');

