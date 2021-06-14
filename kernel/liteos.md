# Harmony 内核概览

**本章节解析的文件夹及对应源码路径如下：**

| 文件夹          | gitee url                                     |
| --------------- | --------------------------------------------- |
| kernel/liteos_a | https://gitee.com/openharmony/kernel_liteos_a |
| kernel/liteos_m | https://gitee.com/openharmony/kernel_liteos_m |

分支概览：

| kernel   | git 分支                  | commit  | Files |  Lines | Blank | Comment |   Code | Size |
| :------- | ------------------------- | ------- | ----: | -----: | ----: | ------: | -----: | ---: |
| liteos_a | OpenHarmony_1.0.1_release | ebe33aa |   477 | 116055 | 15014 |   27090 |  73951 |  16M |
| liteos_a | OpenHarmony-v2.2-Beta     | ebb1305 |  3162 | 427147 | 63329 |  118971 | 244847 |  32M |
| liteos_m | OpenHarmony_1.0.1_release | 0d403fc |   720 | 237977 | 33562 |   81376 | 123039 |  15M |
| liteos_m | OpenHarmony-v2.2-Beta     | bd30759 |  1359 | 210535 | 27815 |   74071 | 108649 |  46M |

上表中 git 分支 + commit 可以准确定位到具体的位置，表中数据可以看出：

- liteos_a 的 1.0 到 2.2 有大量的代码新增(331%)，体积翻倍。
- liteos_m 的 1.0 到 2.2 代码有减少(12%)，文件翻倍了，但代码量减少了，架构有大幅的精简。
