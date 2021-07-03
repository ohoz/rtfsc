# kernel_liteos_a 源码分析

liteos_a 既然支持 ARM Cortex-A 芯片，所以首先要能够找到 ARM 和 Cortex-A 的相关手册：

| Cortex-Axx | ARMv7-A    | ARMv8-A | ARMv9 |
| ---------- | ---------- | ------- | ----- |
| 高性能     | A1x        | A7x     | A7xx  |
| 高效率     | A8, [A9][] | A5x     | A5XX  |
| 超高效     | A5, A7     | A3x     |       |

[a9]: https://developer.arm.com/ip-products/processors/cortex-a/cortex-a9

[ARM 开发者](https://developer.arm.com) 网站上可以方便的查阅非常多的手册，并且可以下载其 pdf 版本。与 Cotrex-A9 相关的推荐：

- [Cortex-A Series Programmer's Guide](https://developer.arm.com/documentation/den0013/d)
- [Cortex-A9 Technical Reference Manual](https://developer.arm.com/documentation/ddi0388/i)

Hi3516/18 为 Cotex-A9，ARM 于 2008 年推出 A9 架构，2012 年结束更新，海思的本款芯片于 2010 年左右推出，生命力已有 10+ 年。

## 参考

- [OSChina 专栏:鸿蒙内核源码分析](https://my.oschina.net/weharmony?tab=newest&catalogId=7082609)
