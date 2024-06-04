# ASTRA-sim

ASTRA-sim 是一个分布式机器学习系统模拟器。它可以系统地研究现代深度学习系统所面临的挑战，探索瓶颈问题，并为未来不同平台上开发大型 DNN 模型提供高效的方法。

<div align="center">
    <img src="./images/astra_sim_overview.png"/>
</div>

## 1. 安装过程

### 1.1 安装依赖

- 使用apt安装系统依赖组件

  ```bash
  # 更新apt源
  apt update
  apt upgrade
  # 使用apt安装依赖
  apt install -y gcc g++ make cmake mpich
  apt install -y nano git git-lfs python3 python3-pip
  apt install -y libboost-dev libboost-program-options-dev
  apt install -y libprotobuf-dev protobuf-compiler
  ```

- 安装conda环境**（可选）**

  ```bash
  # 创建conda环境
  conda create -n astra-sim python=3.7 -y
  # 激活conda环境
  conda activate astra-sim
  ```

- 安装python依赖

  ```bash
  # 更新pip工具
  pip install --upgrade pip
  # 安装python组件
  pip install protobuf==3.6.1 pydot -i https://pypi.tuna.tsinghua.edu.cn/simple
  pip install pandas matplotlib seaborn -i https://pypi.tuna.tsinghua.edu.cn/simple
  ```

### 1.2 编译源码

> [!CAUTION]
>
> - 不建议使用较新的Ubuntu系统版本，请使用`gcc -v`检查gcc版本，如果超过gcc-11，后续的工作可能会遇到编译错误！！！
> - 请勿使用root用户编译ASTRA-sim项目，可能会导致ns-3模块编译失败！！！
> - 如果当前正在以root用户登录，请参考`编译失败`章节中的添加普通用户处理过程

#### A. 通过本仓库（推荐）

- 下载astra-sim仓库

  ```bash
  # 使用脚本拉取asplos2023版本的代码
  bash ./clone_astra_sim.sh
  ```

- 如果clone过程中出现网络问题导致遍历clone未完成，可使用如下命令更新子模块

  ```bash
  # 更新子模块
  git submodule update --init --recursive
  ```

- 编译项目

  ```bash
  # 使用Analytical Network作为后端编译
  bash ./build_analytical.sh
  # 使用阻塞的Analytical作为后端编译
  bash ./build_congestion.sh
  ```

#### C. 通过ASTRA-sim

- 下载源码**（需要提前在github上配置ssh密钥）**

  ```bash
  # clone源码仓库以及其相关的依赖仓库
  git clone --recurse-submodules git@github.com:astra-sim/astra-sim.git
  ```

- 编译源码

  ```bash
  # 切换到源码仓库的文件夹
  cd astra-sim
  # 使用Analytical Network作为后端编译
  bash ./build/astra_analytical/build.sh
  # 使用NS3 Network Backend作为后端编译
  bash ./build/astra_ns3/build.sh -c
  ```

- ASTRA-sim 生成后，可执行文件 `${BINARY}` 位于：

  ```bash
  # 当使用Analytical Network作为后端编译时
  ${ASTRA_SIM}/build/astra_analytical/build/AnalyticalAstra/bin/AnalyticalAstra
  ```

## 2. 仿真验证

### 2.1 设置仿真参数

在使用ASTRA-sim进行仿真之前需要对网络的以及算法相关的参数进行定义。

#### A. 网络参数

- https://astra-sim.github.io/astra-network-analytical-docs/input-format/input-format.html
- https://astra-sim.github.io/astra-sim-docs/getting-started/argument-network-config.html

```json
{
  "dimensions-count": 1,
  "topologies-per-dim": ["FullyConnected"],
  "units-count": [8],
  "links-count": [7],
  "link-latency": [22000],
  "link-bandwidth": [19]
}
```

- **dimensions-count** 维度是数量，这里以8个Ascend组成的全连接网络为例，维度为1
- **topologies-per-dim** 每个维度的拓扑结构，可选：`FullyConnected`、`Ring`、`Swicth`等
- **units-count** 每个维度待组网的节点数量
- **links-count** 每个节点的链接数量
- **link-latency** 链接的延迟，单位ns
- **link-bandwidth** 链接的单向带宽，单位GB/s

#### B. 系统参数

- https://astra-sim.github.io/astra-sim-docs/getting-started/argument-system-config.html

```yml
scheduling-policy: LIFO
endpoint-delay: 10
active-chunks-per-dimension: 1
preferred-dataset-splits: 8
boost-mode: 1
all-reduce-implementation: direct
all-gather-implementation: direct
reduce-scatter-implementation: direct
all-to-all-implementation: direct
collective-optimization: localBWAware
```

- **scheduling-policy** 调度策略
- **endpoint-delay** 每个节点的延迟，单位ns
- **active-chunks-per-dimension** 每个维度激活的块
- **preferred-dataset-splits** 数据集对象拆分的块数量
- **boost-mode** 当使用对称网络时进行快速仿真
- **all-reduce-implementation** AllReduce的实现方法，例如：`ring`、`direct`、`doubleBinaryTree`、`oneRing`、`oneDirect`.等
- **collective-optimization** 集合通信优化策略

#### C. 负载参数

- **注意版本，以下链接仅适用于最新版本的workload参数生成**
  - https://astra-sim.github.io/astra-sim-docs/getting-started/argument-workload-config.html

- **以下Youtube视频适用于本仓库的workload参数设置**
  - https://youtu.be/AVtqhMV1UOU?si=AJBpo-q7Ve8K411I


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

### 2.2 仿真结果

根据测试数据，修改仿真参数如下：

- 链接延迟为22us
- 单向带宽为19GB/s
- AllReduce通信量为2GB
- 集合通信算法选择direct

| TotalTime(us) | ExposedCommunicationTime(us) | TotalMessageSize(MB) |
| :-----------: | :--------------------------: | :------------------: |
|   26669.625   |          26669.625           |       3584.00        |

### 2.3 实际测试结果

- 数据参考：https://gitee.com/zzudongxiang/ascend.cl/tree/master/data/trace_log/prof

- 实测数据显示：
  - 每个Epoch耗时29.871ms，仿真结果为26.670ms，相差3.201ms（11%）
  - 每个Epoch通过HCCL传输数据3584MB与仿真结果一致

### 2.4 其他通信算法的仿真时间对比

- 只改变通信算法不改变其他参数的情况下

|     通信算法     | 通信时间 (ms) |
| :--------------: | :-----------: |
|      direct      |    26.670     |
|    oneDirect     |    26.670     |
|       ring       |    186.686    |
|     oneRing      |    186.686    |
| doubleBinaryTree |    632.699    |

## 常见问题处理

### 编译失败

- **extern/…/gtest-death-test.cc:1294:24: error: ‘dummy’ may be used uninitialized…**

  打开文件`astra-sim/extern/googletest/googletest/src/gtest-death-test.cc`找到第`1294`行，发现这里的函数调用之前只做了声明，未进行赋值，给参数`dump`一个默认值`0`即可

  ![image-20240529192151756](./images/image-20240529192151756.png)

- **extern/…/ChunkIdGenerator.hh:16:23: error: ‘uint64_t’ does not name a type…**

  打开文件`astra-sim/extern/network_backend/analytical/congestion/api/ChunkIdGenerator.hh`并在文件的第11行添加`#include <cstdint>`

  ![image-20240529192630456](./images/image-20240529192630456.png)

- **extern/…/et_def.pb.h:17:2: error: #error This file was generated by an older…**

  一般是protoc工具的版本问题，如果使用的是Anaconda环境，需要检查环境是否正确，如果不正确的话，请使用`conda avtivate astra-sim`激活已经配置好的Anaconda环境
  
- **Exception: Refusing to run as root. --enable-sudo will request your password when needed**

  一般是因为使用了root用户进行编译操作导致的，请勿使用root用户登录并编译该文件，请切换为普通用户后尝试

  - 可以使用`adduser astrasim`创建普通用户
  - 然后使用`su astrasim`切换到普通用户后执行

  使用普通用户编译完成后记得需要使用`cp -r <src_path> <dst_path>`命令复制编译后的产物到指定路径，然后使用`chown -R root <dst_path>`修改文件夹的权限

### 运行失败

- **AnalyticalAstra: /…libstdc++.so.6: version `GLIBCXX_3.4.32' not found…**

  使用`strings xxx/anaconda3/lib/libstdc++.so.6 | grep GLIBCXX`发现输出的GLIBC版本中缺少指定的3.4.32版本的标记，通过`find /usr -name libstdc++.so.6`搜索其他`libstdc++.so.6`文件所在的位置，并使用如下命令将其导入动态链接库环境变量中即可

  ```bash
  # 如有必要，可以将以下内容添加至~/.bashrc文件中
  export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
  ```

