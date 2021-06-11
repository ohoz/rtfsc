# Harmony 内核

## 概览

| git 分支                           | commit  | 日期     | Files |  Lines | Blank | Comment |   Code | Size |
| :--------------------------------- | ------- | -------- | ----: | -----: | ----: | ------: | -----: | ---: |
| liteos_a_OpenHarmony_1.0.1_release | ebe33aa | 20210609 |   477 | 116055 | 15014 |   27090 |  73951 |  16M |
| liteos_a_OpenHarmony-v2.2-Beta     | ebb1305 | 20210609 |  3162 | 427147 | 63329 |  118971 | 244847 |  32M |
| liteos_m_OpenHarmony_1.0.1_release | 0d403fc | 20210425 |   720 | 237977 | 33562 |   81376 | 123039 |  15M |
| liteos_m_OpenHarmony-v2.2-Beta     | bd30759 | 20210607 |  1359 | 210535 | 27815 |   74071 | 108649 |  46M |

上表中 git 分支 + commit 可以准确定位到具体的位置，表中数据可以看出：

- liteos_a 的 1.0 到 2.2 有大量的代码新增(331%)，体积翻倍。
- liteos_m 的 1.0 到 2.2 代码有减少(12%)，文件翻倍了，但代码量减少了，架构有大幅的精简。

## kernel_liteos_a

代码仓: https://gitee.com/openharmony/kernel_liteos_a

### 1.0 与 2.2 对比

```bash
liteos_a_OpenHarmony_1.0.1_release $ du -sh * |sort -rh | head -n3
11M     tools
2.0M    kernel
892K    fs
liteos_a_OpenHarmony-v2.2-Beta $ du -sh *|sort -rh | head -n3
16M     testsuites
11M     tools
2.0M    kernel
liteos_a_OpenHarmony-v2.2-Beta $ loc testsuites
--------------------------------------------------------------------------------
 Language             Files        Lines        Blank      Comment         Code
--------------------------------------------------------------------------------
 Total                 2677       311680        48375        92099       171206
--------------------------------------------------------------------------------
```

2.2 比 1.0 多写了 17 万行的测试用例(testsuites)。

### 参考

- [OSChina 专栏:鸿蒙内核源码分析](https://my.oschina.net/weharmony?tab=newest&catalogId=7082609)

## kernel_liteos_m

代码仓: https://gitee.com/openharmony/kernel_liteos_m

### 1.0 与 2.2 对比

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
