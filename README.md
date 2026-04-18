# AutoFramesCount

动态目标追踪与自动化逻辑判定系统

<img width="1339" height="502" alt="Tmaze范式" src="https://github.com/user-attachments/assets/8f03082a-578e-4a41-8579-e8f89ad874e4" />
范式描述：小鼠在 T-迷宫 中执行任务，规则定义为当分叉路口出现 物体A 时,小鼠需要向左拐，而当出现 物体B 时，小鼠则需要向右拐
该工具包集成了T-迷宫区域划分、小鼠追踪、物体分类和行为判定等功能

使用方法：
1. 下载 AutoFramesCount
2. 在 MATLAB 中打开 AutoFramesCount_v4 并运行
3. 按照要求选择需要处理的视频系列集所在的文件夹，这里提供了 Demos 以便调试
4. 框选 T-迷宫，并依次选择 起始盒 bowl-o，左臂末端 bowl-left 和 右臂末端 bowl-right
<img width="552" height="560" alt="Tmaze_devision-ezgif com-video-to-gif-converter" src="https://github.com/user-attachments/assets/3bf9a9d7-bbc7-4780-8200-ee47c20b5f4f" />
5. 在命令行窗口切换到 小鼠头部红色LED 出现的帧，尽量准确地选择范围
![Uploading 小鼠追踪.gif…]()
6. 框选T-迷宫分岔口的物体，接下来将自动解析
<img width="546" height="554" alt="框选物体" src="https://github.com/user-attachments/assets/5c617138-9b8b-4fc6-a87c-cc5e606528f4" />
