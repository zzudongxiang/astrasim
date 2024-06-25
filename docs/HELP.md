# ASTRA-sim 帮助信息

**源码细节正在调试，暂未开放，欢迎邮件沟通 [zzudongxiang@163.com](mailto:zzudongxiang@163.com)**

**源码细节正在调试，暂未开放，欢迎邮件沟通 [zzudongxiang@163.com](mailto:zzudongxiang@163.com)**

**源码细节正在调试，暂未开放，欢迎邮件沟通 [zzudongxiang@163.com](mailto:zzudongxiang@163.com)**

ASTRA-sim 是一个分布式机器学习系统模拟器。它可以系统地研究现代深度学习系统所面临的挑战，探索瓶颈问题，并为未来不同平台上开发大型 DNN 模型提供高效的方法。

![astra_sim_overview](../images/astra_sim_overview.png)

## 1. 参数解释

在使用ASTRA-sim进行仿真之前需要对网络的以及算法相关的参数进行定义。

### 1.1 网络参数

- [astra-network-analytical-docs](https://astra-sim.github.io/astra-network-analytical-docs/input-format/input-format.html)、[astra-sim-docs](https://astra-sim.github.io/astra-sim-docs/getting-started/argument-network-config.html)

```json
{
  "dimensions-count": 1,
  "topologies-per-dim": ["FullyConnected"],
  "units-count": [8],
  "links-count": [7],
  "link-latency": [22000],
  "link-bandwidth": [20]
}
```

- **dimensions-count** 维度是数量，这里以8个Ascend组成的全连接网络为例，维度为1
- **topologies-per-dim** 每个维度的拓扑结构，可选：`FullyConnected`、`Ring`、`Swicth`等
- **units-count** 每个维度待组网的节点数量
- **links-count** 每个节点的链接数量
- **link-latency** 链接的延迟，单位ns
- **link-bandwidth** 链接的单向带宽，单位GB/s

### 1.2 系统参数

- [astra-sim-docs](https://astra-sim.github.io/astra-sim-docs/getting-started/argument-system-config.html)

```yml
scheduling-policy: LIFO
endpoint-delay: 10
active-chunks-per-dimension: 8
preferred-dataset-splits: 8
boost-mode: 1
all-reduce-implementation: direct
all-gather-implementation: direct
reduce-scatter-implementation: direct
all-to-all-implementation: direct
collective-optimization: localBWAware
```

- **scheduling-policy** 调度策略
- **endpoint-delay** 每个节点的延迟，单位是始终周期（默认时钟为1GHz，这里的单位可以视为ns）
- **active-chunks-per-dimension** 每个维度激活的块
- **preferred-dataset-splits** 数据集对象拆分的块数量
- **boost-mode** 当使用对称网络时进行快速仿真
- **all-reduce-implementation** AllReduce的实现方法，例如：`ring`、`direct`、`doubleBinaryTree`、`oneRing`、`oneDirect`.等
- **collective-optimization** 集合通信优化策略

### 1.3 负载参数

- [astra-sim-docs](https://astra-sim.github.io/astra-sim-docs/getting-started/argument-workload-config.html)、[Youtube](https://youtu.be/AVtqhMV1UOU?si=AJBpo-q7Ve8K411I)

```txt
MICRO
1
allreduce -1 1 NONE 0 1 NONE 0 1 ALLREDUCE 2147483648 1
```

- **Line 1：MICRO** 训练的loop
- **Line 2：1** 层号
- **Line 3：allreduce** `<元数据>` 层的名字
- **Line 3：-1** `<元数据> ` 保留参数
- **Line 3：1** `<前向传播>` 计算时间，单位us
- **Line 3：NONE** `<前向传播>` 通信类型
- **Line 3：0** `<前向传播>`通信数据量大小，单位Byte
- **Line 3：1** `<输入梯度>` 计算时间，单位us
- **Line 3：None** `<输入梯度>` 通信类型
- **Line 3：0** `<输入梯度>` 通信数据量大小，单位Byte
- **Line 3：1** `<权重梯度>` 计算时间，单位us
- **Line 3：ALLREDUCE** `<权重梯度>` 通信类型
- **Line 3：2147483648** `<权重梯度>` 通信数据量大小，单位Byte
- **Line 3：1** `网络层` 延迟

## 2. 参数获取

在进行仿真实验时，正确的对仿真参数进行设置将会对实验结果产生至关重要的影响，但是仿真参数的获取需要通过实际物理参数和实测数据获取。

### 2.1 链路延迟

使用P2P单向通信发送一个很小的数据包（8Byte），由于通信带宽较高，且在端处未进行任何耗时的运算，因此可以认为该时间为实际的链路延迟时间。

- 在实际测试中，使用`NPU0`向`NPU1`发送8Byte数据，重复20次，平均每次耗时约$33.254 \mu s$
- 在仿真实验中，将链路延迟参数设置为$33.254 \mu s$​

### 2.2 链路带宽

使用P2P单向发送一个很大的数据包（1GByte），由于链路延迟很小，且在端出未进行任何耗时的运算，因此可以认为该测试带宽为实际的链路带宽。

- 在实际测试中，使用`NPU0`向`NPU1`发送1GByte数据，重复20次，平均每次耗时约$52886.56 \mu s$
- 在仿真实验中，将链路带宽的参数设置为$1 G Byte / 52886.56 \mu s=18.908GB/s$​

### 2.3 修正的链路带宽

由于在进行集合通信时可能存在计算、内存复制等操作，在集合通信时的数据带宽可能无法达到理论的链路带宽值，因此使用实测的集合通信数据作为修正的链路带宽

- **allgather** 7条链路，单向传输1792MB，平均耗时$14754.66 \mu s$，则修正的链路带宽为$16.944 GB/s$​

- **allreduce** 7条链路，单向传输3584MB，平均耗时$29993.87 \mu s$，则修正的链路带宽为$16.67 GB/s$

- **alltoall** 7条链路，单向传输1792MB，平均耗时$17763.6 \mu s$，则修正的链路带宽为$13.812 GB/s$

- **reducescatter** 7条链路，单向传输1792MB，平均耗时$15802.01 \mu s$，则修正的链路带宽为$15.821 GB/s$

### 2.4 系统延迟

在进行简单的集合通信操作时，如果进行集合通信的数据量很小（8Byte ~ 64kByte），由于通信带宽较高，可以认为数据传输时间为0，则此时迭代消耗的时间为链路延迟与系统延迟之和，其中链路延迟已暂定为$33.254 \mu s$

- **allgather** 在集合通信的数据量很小时，平均耗时为$57.764 \mu s$
- **allreduce** 在集合通信的数据量很小时，平均耗时为$41.056 \mu s/2=20.528 \mu s$（每条链路发生两次传输）
- **alltoall** 在集合通信的数据量很小时，平均耗时为$116.886 \mu s$
- **reducescatter** 在集合通信的数据量很小时，平均耗时为$59.929 \mu s$​

> 在实验过程中，由于使用修正的链路带宽，因此已经把不同算法的系统延迟参数带入了修正的链路带宽参数，因此只需要将以上测试结果视为链路延迟即可
