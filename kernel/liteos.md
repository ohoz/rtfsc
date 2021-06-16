# Harmony 内核概览

**本章节解析的文件夹及对应源码路径如下：**

| hpm 组件名                | 源码目录        | gitee url                                     |
| ------------------------- | --------------- | --------------------------------------------- |
| [@ohos/kernel_liteos_a][] | kernel/liteos_a | https://gitee.com/openharmony/kernel_liteos_a |
| [@ohos/kernel_liteos_m][] | kernel/liteos_m | https://gitee.com/openharmony/kernel_liteos_m |

[@ohos/kernel_liteos_a]: https://hpm.harmonyos.com/#/cn/bundles/@ohos%2Fkernel_liteos_a/v/2.0.0
[@ohos/kernel_liteos_m]: https://hpm.harmonyos.com/#/cn/bundles/@ohos%2Fkernel_liteos_m/v/2.0.0

---

**代码量概览：**

| kernel   | git 分支                  | commit  | Files |  Lines | Blank | Comment |   Code | Size |
| :------- | ------------------------- | ------- | ----: | -----: | ----: | ------: | -----: | ---: |
| liteos_a | OpenHarmony_1.0.1_release | ebe33aa |   477 | 116055 | 15014 |   27090 |  73951 |  16M |
| liteos_a | OpenHarmony-v2.2-Beta     | ebb1305 |  3162 | 427147 | 63329 |  118971 | 244847 |  32M |
| liteos_m | OpenHarmony_1.0.1_release | 0d403fc |   720 | 237977 | 33562 |   81376 | 123039 |  15M |
| liteos_m | OpenHarmony-v2.2-Beta     | bd30759 |  1359 | 210535 | 27815 |   74071 | 108649 |  46M |

> git 分支 + commit 可以准确定位到具体的位置

- v2.2 的 liteos_a 代码行是 liteos_m 的 **2.4 倍**
- liteos_a 的 1.0 到 2.2 有大量的代码新增(331%)，体积翻倍。
- liteos_m 的 1.0 到 2.2 代码有减少(12%)，文件翻倍了，但代码量减少了，架构有大幅的精简。

---

**文件目录概览：**

| 对比项      | liteos_a               | liteos_m                                  |
| ----------- | ---------------------- | ----------------------------------------- |
| 领域        | IoT                    | IoT                                       |
| 对标        | Linux/Unix(FreeBSD)    | freeRTOS、uCOS                            |
| 适用 SoC    | Cortex-A(3516/18)      | Cortex-M、RISC-V(3861、w800)              |
| kernel/     | 进程、内存、IPC 等模块 | 最小功能集，含 arch、任务、队列、信号量等 |
| arch/       | arm 架构代码           | 无                                        |
| fs/         | 源于 NuttX 开源项目    | 无                                        |
| drivers/    | 内核驱动（HDF）        | 无                                        |
| bsd         | freebsd 借鉴代码       | 无                                        |
| lib/        | 内核 lib 库            | 无                                        |
| net/        | 源自 lwip 的网络模块   | 无                                        |
| platform/   | 芯片平台相关代码       | 无                                        |
| security/   | 安全相关代码           | 无                                        |
| syscall/    | 系统调用 API           | 无                                        |
| tools/      | 构建工具               | 无                                        |
| compat/     | POSIX 接口相关         | 无                                        |
| apps/       | 用户态代码             | 无                                        |
| testsuites/ | 测试用例               | 无                                        |
| kal/        | 无                     | 内核抽象层（HAL）                         |
| targets/    | 无                     | 板级工程                                  |

- liteos_a 是一个完整的 OS，liteos_m 只相当于一个 kernel
- 缺少文件系统的支持，让 liteos_m 只能工作在 flash 裸区
- liteos_m 包含了 arch 代码，去除这部分代码，仅计算传统意义的 kernel（任务、进程、调度、通信……）仅 6k 行，而 liteos_a 的 kernel 全部都是这些代码，越 28k 行，是 liteos_m 的 4.5 倍。
- liteos_a 中的虚拟内存管理、ipc、内存映射、misc ……都是 liteos_m 没有的。
