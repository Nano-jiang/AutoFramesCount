%% 识别 Object 1 和 Object 2

% 每间隔 50 帧对 object 1 和 object 2 进行分类
% ObjectClassificationResults.mat: "ObjectFrameNums","ObjectPredictedLabels"

%% 加载分类器: obj_classifier2.mat
% % 改成相应文件夹
% % obj_classifier2 和 obj_classifier3 相同
% load('D:\Code\AutoFramesCount\ObjectClassification\obj_classifier3.mat');
% 
% % 读取视频
% videoFile = 'behavCam1.avi';
% video = VideoReader(videoFile);
% 
% % 读取第一帧
% firstFrame = readFrame(video);
% 
% % 在第一帧中使用鼠标框选区域
% disp("请用鼠标框选物体所在的大致区域")
% figure, imshow(firstFrame);
% h = imrect;
% objPosition = wait(h); % position = [xmin ymin width height]
% close(gcf);
% 
% % 设置采样率
% ObjectPredictedLabels = [];
% ObjectFrameNums = [];
% samplingRate = 50;
% 
% % 加载预训练的深度学习网络（例如，ResNet-50）
% net = resnet50;
% 
% save('object_selection.mat');
% movefile('object_selection.mat', 'FrameCount2');

%% 逐帧处理视频

% 用于保存上一次的预测标签
prevPredictedLabel = []; 

for vi = 1:behavCamNumber
% for vi = 1:behav.camNumber
    video = behavCamFiles(vi).name;
    vid = VideoReader(video);
    frameNum = vid.NumFrames;

    for i = 1:frameNum
        frame = read(vid,i);
    
        % 每samplingRate帧进行一次处理
        if mod(i, samplingRate) == 0 || (vi == 1 && i == 1)
            
            % 提取框选区中的图片特征
            % 提取ROI
            roi = imcrop(frame, objPosition);
                    
            % 加载和预处理新图片
            newImage = roi;  % 替换为你的图片路径
            newImage = imresize(newImage, [224 224]);    % 调整大小以适应网络输入
            
            % 如果需要，将图片转换为RGB（ResNet-50期望输入为RGB图像）
            if size(newImage, 3) == 1
                newImage = cat(3, newImage, newImage, newImage);
            end
            
            % 将图片数据存储到一个augmentedImageDatastore中
            augimdsNewImage = augmentedImageDatastore([224 224], newImage);
            
            % 提取新图片的特征（使用与训练相同的网络层）
            layer = 'fc1000';
            featuresNewImage = activations(net, augimdsNewImage, layer, 'OutputAs', 'rows');
            
            
            % 使用训练好的分类器进行分类
            predictedLabel = predict(obj_classifier, featuresNewImage); 
            prevPredictedLabel = predictedLabel;
            ObjectPredictedLabels = vertcat(ObjectPredictedLabels,predictedLabel);
            ObjectFrameNums = vertcat(ObjectFrameNums, (vi-1)*1000 + i);
        end
    end
end

%%
save("ObjectClassificationResults.mat","ObjectFrameNums","ObjectPredictedLabels","samplingRate");
movefile('ObjectClassificationResults.mat', 'FrameCount2');

