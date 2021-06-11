# OpenHarmony 简介

本文档将 Harmony（鸿蒙）分为 2 个概念：

1. 大鸿蒙：下图中红色 + 蓝色部分，HW 于 2021.06.02 发布的 HarmonyOS2.0 即是此概念
2. 小鸿蒙：下图中红色部分，HW 贡献给 [OpenHarmony（原子社区）](https://gitee.com/openharmony)的代码

![](images/position.svg)

鸿蒙开发者相对应也被分为几类：

1. 大鸿蒙 APP 开发：可平滑移植 AOSP 上 Android APP 开发，因为 HW 移植了 AOSP，接口保持了一致，这部分开发使用 DevEco Studio 工具，查看 [HarmonyOS Develope](https://developer.harmonyos.com/cn/home/) 网站文档。与安卓开发不同的是，这部分开发大量使用 js、ts，而不是 JAVA，更类似微信小程序的开发。
2. 小鸿蒙嵌入式开发：使用 DevEco Device Tool 工具或直接 Docker 中编译，查看 [HarmonyOS Device](https://device.harmonyos.com/cn/home) 和 [HPM](https://hpm.harmonyos.com/#/cn/home) 两个网站，这部分开发模式与传统的嵌入式开发几乎没有区别：搭建环境、编译、烧录版本、JTAG 调试……

本文档旨在拆解、分析小鸿蒙的源代码，为嵌入式开发提供学习资料和解决思路。

本文档分析的代码拉取方式：

```
mkdir HarmonyOS
cd HarmonyOS
repo init -u https://gitee.com/openharmony/manifest.git  -b OpenHarmony_1.0.1_release --no-repo-verify
repo sync -c
```