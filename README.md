# AutoFramesCount

> **动态目标追踪与自动化逻辑判定系统：**  一套基于 MATLAB 的全流程行为学分析方案，集成 T-迷宫区域划分、小鼠实时追踪、深度学习物体分类及自动化行为逻辑判定。

---

## 📑 范式描述
在标准 **T-迷宫 (T-maze)** 实验中，系统根据分叉路口出现的刺激物自动判定小鼠决策的正确性：
* **规则定义**：若路口出现 **物体 A** $\rightarrow$ 正确决策为 **向左拐**；若出现 **物体 B** $\rightarrow$ 正确决策为 **向右拐**。

<p align="center">
  <img src="https://github.com/user-attachments/assets/8f03082a-578e-4a41-8579-e8f89ad874e4" width="80%" title="Tmaze范式">
</p>

---

## 🚀 快速开始

### 1. 环境准备
* 确保安装了 **MATLAB (R2021a 或更高版本)**。
* 需安装 **Deep Learning Toolbox**（用于 ResNet-50 物体分类）。

### 2. 操作流程

1.  **启动程序** 下载仓库并解压，在 MATLAB 中运行主脚本 `AutoFramesCount_v4.m`。
    
2.  **选择数据源** 在弹出的交互窗口中选择视频系列集所在的文件夹。*（建议初次使用时选择提供的 `Demos` 文件夹进行调试）*

3.  **划定 T-迷宫区域** 根据提示框选迷宫整体，并依次标记：**起始盒 (bowl-o)**、**左臂末端 (bowl-left)** 及 **右臂末端 (bowl-right)**。
    <p align="center">
      <img src="https://github.com/user-attachments/assets/3bf9a9d7-bbc7-4780-8200-ee47c20b5f4f" width="400" alt="Tmaze划分演示">
    </p>

4.  **配置 LED 追踪信号** 在命令行窗口切换至小鼠头部红色 LED 出现的帧，并尽量准确地框选 LED 信号范围。系统将以此为基准进行全时段坐标追踪。
    <p align="center">
      <img src="https://github.com/user-attachments/assets/ce2a4425-734b-449e-a9c4-3dfeb18833c8" width="400" alt="小鼠追踪演示">
    </p>

5.  **物体识别与解析** 框选 T-迷宫分岔口的物体目标。系统将调用预训练的分类模型自动解析物体类型，并结合路径数据生成最终的行为判定报告。
    <p align="center">
      <img src="https://github.com/user-attachments/assets/5c617138-9b8b-4fc6-a87c-cc5e606528f4" width="400" alt="物体识别演示">
    </p>

---

## 📊 输出结果
分析完成后，系统将在 `FrameCount2` 文件夹下生成：
* **BehaviorTable**: 包含每轮次的阶段(S1/S2/S3)的耗时、决策方向(1/2)、物体类型(1/2)、正确与否(0/1)等数据。
* **Trajectory Map**: 可视化的小鼠运动轨迹图。

---

## 💾 Demo 数据下载
由于示例数据集较大（约 2GB），未直接上传至 GitHub 仓库。请通过以下链接下载：
* **下载链接**：[百度网盘 - Demos.rar](https://pan.baidu.com/s/1NRketc98rKlxwb4p-p6yFw?pwd=nf82) 
* **提取码**：`nf82`
> **注意**：下载后请将 `Demos.rar` 解压，并确保 `Demos` 文件夹位于项目的根目录下，以便程序能够正确识别路径。

---

## 🛠️ 技术支撑
* **追踪算法**: 基于颜色空间阈值的多目标质心追踪。
* **分类模型**: 基于 ResNet-50 的迁移学习模型。
* **逻辑判定**: 自定义空间拓扑逻辑算法。
