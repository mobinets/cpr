# Cooperative Packet Recovery in Multi-gateway LoRa Networks

This project is the open-source code used in the paper ``Recovering Packet Collisions below the Noise Floor in Multi-gateway LoRa Networks''.
请复制以下内容信息以进行引用：
```
@INPROCEEDINGS{10229010,
  author={Mao, Wenliang and Zhao, Zhiwei and Zheng, Kaiwen and Min, Geyong},
  booktitle={IEEE INFOCOM 2023 - IEEE Conference on Computer Communications}, 
  title={Recovering Packet Collisions below the Noise Floor in Multi-gateway LoRa Networks}, 
  year={2023},
  volume={},
  number={},
  pages={1-10},
  keywords={Degradation;Smart cities;Symbols;Interference;Logic gates;Feature extraction;Media Access Protocol;LoRa network;packet collision recovery;below the noise floor;multi-gateway},
  doi={10.1109/INFOCOM53939.2023.10229010}}

```

# 介绍
该项目为《Recovering Packet Collisions below the Noise Floor in Multi-gateway LoRa Networks》matlab源代码，适用于论文中的cpr系统信号解调流程，并赋有整个室内实验的噪声仿真流程实现，实验的室外采样信号数据请联系第一第二作者获取

# 环境要求
```
matlab >= matlab2021a
```

# 文件结构说明
```
config：存放针对不同SF，BW信号的配置文件
config_experiment：存放室外实验使用的配置文件
Gateway_demodulate_function：自定义的函数库
samples：采样文件demo（非所有采样文件）
symbol_simulation：实验代码，包含使用
```

# 配置文件和采样文件格式说明
参考sigMF格式：https://github.com/sigmf/SigMF  
配置文件：使用json方式存放配置信息  
采样文件：实部（float32）+虚部（float32）储存在一个字节中
