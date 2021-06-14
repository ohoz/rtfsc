# kernel_liteos_m 源码分析

**本章节解析的文件夹及对应源码路径如下：**

| 文件夹          | gitee url                                     |
| --------------- | --------------------------------------------- |
| kernel/liteos_m | https://gitee.com/openharmony/kernel_liteos_m |

## 1.0 与 2.2 对比

```bash
liteos_m_OpenHarmony_1.0.1_release $ du -sh kernel/arch/risc-v/*
92K  kernel/arch/risc-v/riscv32
liteos_m_OpenHarmony-v2.2-Beta $ du -sh kernel/arch/risc-v/*
37M     kernel/arch/risc-v/nuclei
92K     kernel/arch/risc-v/riscv32
```

```bash
liteos_m_OpenHarmony_1.0.1_release $ du -sh targets/*
96K     targets/cortex-m3_stm32f103_simulator_keil
4.8M    targets/cortex-m4_stm32f429ig_fire-challenger_iar
5.3M    targets/cortex-m7_nucleo_f767zi_gcc
12K     targets/riscv_sifive_fe310_gcc
liteos_m_OpenHarmony-v2.2-Beta $ du -sh targets/*
412K    targets/riscv_nuclei_demo_soc_gcc
1.6M    targets/riscv_nuclei_gd32vf103_soc_gcc
12K     targets/riscv_sifive_fe310_gcc
```

- 去掉了意法的 3 块开发板（stm32f103、stm32f429、nucleo）的支持。
- 增加了 nuclei（芯来科技）的 2 款开发板，全球第一家 RISC-V 公司 sifive 的 fe310 得以保留，没有 cortex 的了。
- nuclei 的库文件整体上传，新增了 37M，看来鸿蒙全力芯来和 RISC-V 了。

> NMSIS：Nuclei Microcontroller Software Interface Standard（芯来微控制器软件接口标准）：是为芯来科技 RISC-V 处理器定义的厂商无关的硬件抽象层，定义了通用工具接口并提供持续的处理器设备支持，以及简洁的处理器和外设的软件访问接口 API。NMSIS 包含了 Core、DSP、NN 三大组件: 分别定义处理器核心、DSP Library、卷积神经网络 3 方面的 API。
> NMSIS 协议及源码：[github](https://github.com/Nuclei-Software/NMSIS)、[在线文档](https://doc.nucleisys.com/nmsis)
> NMSIS SDK：[nuclei-sdk](https://github.com/Nuclei-Software/nuclei-sdk)、[在线文档](https://doc.nucleisys.com/nuclei_sdk)
> NMSIS 开发板: [dev board](https://doc.nucleisys.com/nuclei_board_labs/)
