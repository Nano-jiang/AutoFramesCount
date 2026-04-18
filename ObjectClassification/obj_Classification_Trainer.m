%% 训练一个二元分类器来分类物体1和物体2
% 指定图像文件夹路径
imageDir = 'D:\Code\AutoFramesCount\ObjectClassification\';

% 创建 imageDatastore 对象
imds = imageDatastore(imageDir, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

% 显示数据集的类别数目及每个类别的图像数目
tbl = countEachLabel(imds);
disp(tbl);

% 自定义读取函数，用于调整图像大小
imds.ReadFcn = @(filename)imresize(imread(filename), [224, 224]);

% % 读取并显示一张图像
% img = readimage(imds, 1);
% imshow(img);

% 将数据集随机划分为训练集（70%）和测试集（30%）
[trainingSet, testSet] = splitEachLabel(imds, 0.7, 'randomize');

% 检查划分后的数据集
disp('Training set:');
disp(countEachLabel(trainingSet));

disp('Test set:');
disp(countEachLabel(testSet));

%%
% 加载预训练的深度学习网络（例如，ResNet-50）
net = resnet50;

% 调整图像数据存储以适应网络输入大小
augimdsTrain = augmentedImageDatastore([224 224], trainingSet);
augimdsTest = augmentedImageDatastore([224 224], testSet);

% 提取特征
layer = 'fc1000';
featuresTrain = activations(net, augimdsTrain, layer, 'OutputAs', 'rows');
featuresTest = activations(net, augimdsTest, layer, 'OutputAs', 'rows');

% 获取标签
labelsTrain = trainingSet.Labels;
labelsTest = testSet.Labels;

% 训练分类器（例如，支持向量机）
obj_classifier = fitcecoc(featuresTrain, labelsTrain);

% 评估分类器
predictedLabels = predict(obj_classifier, featuresTest);
accuracy = mean(predictedLabels == labelsTest);
disp(['Test accuracy: ', num2str(accuracy)]);

%%
save('obj_classifier3.mat','obj_classifier');