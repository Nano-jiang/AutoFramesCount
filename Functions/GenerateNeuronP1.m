%% 加载相应文件

currentFolder = pwd;

load("behav_new.mat");
disp("成功加载文件：behav_new.mat")

filePattern = fullfile(currentFolder, 'full_prediction_dF_traces*.mat');
files = dir(filePattern);
if ~isempty(files)
    filePath = fullfile(files(1).folder, files(1).name);    
    load(filePath);
    disp("成功加载文件：full_prediction_dF_traces.mat")
else
    disp("未找到文件：full_prediction_dF_traces.mat")
end

filePattern = fullfile(currentFolder, '**', 'NewMr_results.mat');
files = dir(filePattern);

filePattern_overexp = fullfile(currentFolder, 'NewMr_results1.mat');
files_overexp = dir(filePattern_overexp);

if ~isempty(files)
    filePath = fullfile(files(1).folder, files(1).name);    
    load(filePath);
    disp("成功加载文件：NewMr_results.mat")
else
    disp("未找到文件：NewMr_results.mat")
end

if ~isempty(files_overexp)
    filePath = fullfile(files_overexp(1).folder, files_overexp(1).name);    
    load(filePath);
    disp("成功加载文件(Overexp)：NewMr_results1.mat")
else
    disp("未找到文件(Overexp)：NewMr_results1.mat")
end

%% 生成 Date_No.Mouse_C

a = BehaviorTable;

labelbehav0 = a(:,[7 8 9 10]);
labelframe00 = a(:,1:6);
NeuronS = neuron.S;
NeuronC = neuron.C;

NeuronP = spike_prob*30;
NeuronP(isnan(spike_prob))=0;

NeuronP1 = (NeuronP);
NeuronC1 = (NeuronC);
NeuronS1 = (NeuronS);

NeuronA = reshape(neuron.A,Ysiz(1),Ysiz(2),[]);

%%
currentFolder = pwd;
tokens = regexp(currentFolder, '[^\\/]+$', 'match');
if ~isempty(tokens)
    currentFolderName = tokens{1};
    disp(currentFolderName);
else
    disp('无法解析当前文件夹名称');
end

FileName1 = char(currentFolderName +"_C");

%%
save([FileName1,'.mat'], 'NeuronC1','NeuronS1','NeuronA','NeuronP1','labelbehav0', 'labelframe00')
