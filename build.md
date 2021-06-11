# Harmony 组件的编译、构建

## gn 和 ninja

[ninja](https://ninja-build.org/) （忍者），google chromium 团队出品，致力于比 make 更快速很多倍的编译系统，可以把其他编译系统的输出作为输入，比如可以使用 Kati 工具把 Makefile 转化成 Ninja files，然后用 ninja 编译。

ninja 首次在 Android N（2016 年）在 Android 中使用，当前被广泛应用在希望从编译耗时中解脱出来的大型项目中。

gn 是一种元构建系统，生成 Ninja 构建文件（Ninja build files），gn 的文件后缀为 `.gn`、`.gni`。

类似 cmake 会生成 makefile，gn 会生成 ninja 文件，减少了手工写 ninja 文件的工作量，另外如上所述，cmake 也能生成 ninja 能够使用的文件。

gn 非常灵活，可以随便指定目录来输出：

```
gn gen out/test
```

- ninja：[文档](https://ninja-build.org/manual.html)、[Ninja 构建系统 -- ninja 创始人的文章](https://blog.csdn.net/yujiawang/article/details/72627121)
- gn 文档：

## harmony 编译流程

有多种获取和编译 harmony 源码的方式

| 编译\获取             | `repo ...` | `hpm i @xxx/xxx` | DevEco New Project |
| --------------------- | ---------- | ---------------- | ------------------ |
| `python build.py xxx` |            |                  |                    |
| `hpm build/dist`      |            |                  |                    |
| `hb set`, `hb build`  |            |                  |                    |
| DevEco build          |            |                  |                    |

/home/kevin/.deveco-device-tool/core/deveco-venv/bin/hos run --project-dir /home/kevin/workspace/harmony/src/bearpi --environment bearpi_hm_nano
