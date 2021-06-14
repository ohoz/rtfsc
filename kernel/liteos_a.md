# kernel_liteos_a 源码分析

**本章节解析的文件夹及对应源码路径如下：**

| 文件夹          | gitee url                                     |
| --------------- | --------------------------------------------- |
| kernel/liteos_a | https://gitee.com/openharmony/kernel_liteos_a |

代码仓:

## 1.0 与 2.2 对比

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

## 参考

- [OSChina 专栏:鸿蒙内核源码分析](https://my.oschina.net/weharmony?tab=newest&catalogId=7082609)
