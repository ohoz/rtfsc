# Harmony 组件的编译、构建

**本章节解析的文件夹及对应源码路径如下：**

| hpm 组件名       | 源码目录   | gitee url                                            |
| ---------------- | ---------- | ---------------------------------------------------- |
| @ohos/build_lite | build/lite | https://openharmony.gitee.com/openharmony/build_lite |

获取源码（本文以 `hpm i @ohos/hispark_pegasus` 为例）后，如果想编译通过，需要走这样几步：

1. 先安装编译器(LLVM、clang)、构建工具（ninja、gn）、python、nodejs 等，并且要选择正确的版本 —— 使用 docker 跳过此步。
2. `cd build/lite; python3 -m pip install --user build/lite` 安装本组件的 cli，即 hb 命令 —— 使用 docker 跳过此步。
3. `hb set` 选择要编译的 target
4. `python3 build.py [build]` 或 `hb build` 编译结果放在 `out/` 目录

我们先从 ninja 说起。

## gn 和 ninja

[ninja](https://ninja-build.org/) （忍者），google chromium 团队出品，致力于比 make 更快的编译系统，可以与其他编译系统配合，如可以使用 Kati 工具把 Makefile 转化成 Ninja files，然后用 ninja 编译；也可以把其他编译系统的输出作为输入，如 CMake + Ninja。

ninja 首次在 2016 年的 Android N 中使用，当前被广泛应用在希望从编译耗时中解脱出来的大型项目中。

gn 意思是 generate ninja，即生成 Ninja 所需的文件（meta data），所以 gn 自称为元数据构建（meta-build）系统，也是 google chromium 团队出品，gn 的文件后缀为 `.gn`、`.gni`。类似 cmake 生成 makefile，gn 会生成 ninja 文件，都是为了减少手工写 make/ninja 文件的工作量。

如果使用 harmony 提供的 docker，gn 和 ninja 都已经安装好了：

```bash
root@90065f887932:/home/openharmony# gn --version
1717 (2f6bc197)
root@90065f887932:/home/openharmony# ninja --version
1.9.0
```

- ninja：[文档](https://ninja-build.org/manual.html)、[Ninja 构建系统 -- ninja 创始人的文章](https://blog.csdn.net/yujiawang/article/details/72627121)
- gn：[github](https://github.com/o-lim/generate-ninja)

gn 的总体流程是：

- 在指定目录查找 `.gn` 文件，如果不存在则向上找直到找到一个，并将其设为 root
- 解析 root 下的 gn 文件以获取 build confing 文件名称，执行 build config 文件（这是一个默认工具链）
- 解析 root 下的 `BUILD.gn` 文件，加载其依赖的其它目录下的 `BUILD.gn` 文件
- 编译出.ninja 文件保存到 `out/`下，如： `./out/arm/obj/ui/web_dialogs/web_dialogs.ninja`;
- 当所有的目标都解决了， 编译出一个根 build.ninja 文件存放在 `out/` 根目录下。

## hb

hb 是 @ohos/build_lite 组件的主要组成部分，python 语言。在 docker 中或 `hpm i` 安装的源码中可以看到其源码：

- docker 中：

```bash
root@90065f887932:/home/openharmony# python3 -c 'import inspect,hb; print(inspect.getfile(hb))'
/root/.local/lib/python3.8/site-packages/hb/__init__.py
root@90065f887932:/home/openharmony# ls /root/.local/lib/python3.8/site-packages/hb
build  clean  common  cts  deps  env  __init__.py  __main__.py  __pycache__  set
```

- 源码中：

```bash
$ ls build/lite/hb
__init__.py __pycache__ clean       cts         env
__main__.py build       common      deps        set
```

hb 将每个子命令的实现放在一个文件夹中：set、build、clean、env……

hb 的构建总体流程：

![](images/hb.jpg)

当执行 `hb set`、`hb build` 的时候进入每个文件夹中执行 `exec_command()` 函数。

### `hb set`

执行 `build/lite/hb/set/set.py` 中的 `exec_command()` 函数:

```python
def exec_command(args):
    return set_root_path() == 0 and set_product() == 0
```

`set_root_path()` 和 `set_product()` 分别解析出 root 路径和产品相关信息，写入 ohos_config.json 文件中。

```python
def set_root_path(root_path=None):
    config = Config()
    if root_path is None:
        root_path = get_input('[OHOS INFO] Input code path: ')
    config.root_path = root_path
    return 0
```

命令行里执行 `hb set` 给出的提示即此上面函数打印。`Config` 是一个单例 class（即：此函数配置的 config 实例值，其他函数都可获取）：

```python
class Config(metaclass=Singleton):
```

Config 单例定义了多个属性：root_path、board、kernel、product、product_path、device_path、out_path……,当做左值的时候会写入 ohos_config.json 文件。

另外一个函数 `set_product()` 即是为了配置 Product，`Product` 是 hb 为产品定义的 class，包含几个静态方法，基本都是解析出配置值，写入 ohos_config.json 文件：

```bash
$ cat common/product.py|grep -B1 'def '
    @staticmethod
    def get_products():
--
    @staticmethod
    def get_device_info(product_json):
--
    @staticmethod
    def get_features(product_json):
--
    @staticmethod
    def get_components(product_json, subsystems):
```

静态方法望文知意:

- `get_products()`: 获取产品信息，递归查找 `vender/` 下包含 config.json 文件的目录，每找到一个即算一个 Product，其中的 config.json 通常包括 vender 预先定义好的发行版配置。

```bash
$ find vendor/ -name config.json
vendor/hisilicon/hispark_aries/config.json
vendor/hisilicon/hispark_pegasus/config.json
vendor/hisilicon/hispark_taurus/config.json
```

上面是 `repo sync` 获取的源码中的 vender 情况，所以在执行 `hb set` 时会提示 3 个选项：

```bash
$ hb set
[OHOS INFO] Input code path: .
OHOS Which product do you need?  (Use arrow keys)

hisilicon
 ❯ ipcamera_hispark_aries
   wifiiot_hispark_pegasus
   ipcamera_hispark_taurus
```

- `get_device_info()`、`get_features()`、`get_components()`: 获取 vender 定义的 config.json 中的各种信息，比如:

```bash
$ cat vendor/hisilicon/hispark_pegasus/config.json | head -n18
{
    "product_name": "wifiiot_hispark_pegasus",
    "ohos_version": "OpenHarmony 1.0",
    "device_company": "hisilicon",
    "board": "hispark_pegasus",
    "kernel_type": "liteos_m",
    "kernel_version": "",
    "subsystems": [
      {
        "subsystem": "applications",
        "components": [
          { "component": "wifi_iot_sample_app", "features":[] }
        ]
      },
      {
        "subsystem": "iot_hardware",
        "components": [
          { "component": "iot_controller", "features":[] }
```

前面 `hb set` 给出的 3 个选项是这里的 product_name。device_info 包括上面的 device、board、kernel；features 和 components 是每个 subsystems 中的信息。

每个 subsystem 对应一个源代码的目录，component 是它依赖的模块，统一放在 ohos_bundles 下面。

### `hb build`

执行 `build/lite/hb/build/build.py` 中的 `exec_command()` 函数，该函数主要处理用户的入参，如：

- `-b`：debug 或 release
- `-c`：指定编译器，默认是 clang
- `-t`：是否编译 test suit
- `-f`：full，编译全部代码
- `-t`：是否编译 ndk，本地开发包，这也是 `@ohos/build_lite` 组件的一部分
- `-T`：单模块编译
- `-v`：verbose

使用这些入参实例化 Build 类：

```python
class Build():
    def __init__(self):
        self.config = Config()
        ......

    def build(self, full_compile, ninja=True, cmd_args=None):
        ......

    def check_in_device(self):
        ......

    def gn_build(self, cmd_args):
        ......

    def ninja_build(self, cmd_args):
        ......
```

实例化后调用 `build.build()`，它会依次调用 `check_in_device()`、`gn_build()` 和 `ninja_build()`。

- `check_in_device()`：读取编译配置，根据产品选择的开发板，读取开发板 config.gni 文件内容，主要包括编译工具链、编译链接命令和选项等。
- `gn_build()`：调用 gn gen 命令，读取产品配置生成产品解决方案 out 目录和 ninja 文件。核心代码如下：
  ```python
          gn_cmd = [gn_path,
                  '--root={}'.format(self.config.root_path),
                  '--dotfile={}/.gn'.format(self.config.build_path),
                  'clean',
                  self.config.out_path]
          exec_command(gn_cmd, log_path=self.config.log_path)
  ```
- `ninja_build()`：调用 ninja -C out/board/product 启动编译。核心代码如下：
  ```python
          ninja_cmd = [ninja_path,
                      '-w',
                      'dupbuild=warn',
                      '-C',
                      self.config.out_path] + ninja_args
          exec_command(ninja_cmd, log_path=self.config.log_path, log_filter=True)
  ```
- 系统镜像打包：将组件编译产物打包，设置文件属性和权限，制作文件系统镜像。

### python build.py

根目录下的 build.py 通常是 build/lite/build.py 的软连接，执行 `python build.py` 时会运行到 build.py 的 `build()` 函数：

```python
def build(path, args_list):
    cmd = ['python3', 'build/lite/hb/__main__.py', 'build'] + args_list
    return check_output(cmd, cwd=path)
```

可见，仍是执行 `hb build`，入参也可以平移过来，所以可以这么使用：

```bash
python build.py ipcamera_hi3518ev300 -b debug # 全量编译为 debug 版本
python build.py ipcamera_hi3518ev300 -T applications/sample/camera/app:camera_app # 单模块编译
```

可以说，build.py 实现了“不安装 hb 也能编译”的目的，其他好像没做什么。

### History

- 2020.12.05: 内核从 liteos_riscv 更名为 liteos_m，build 做适配。

```bash
$ git -P log -n1 897188
commit 8971880bd4f08a2ea01e83dfaadcf7cda7aae858
Author: p00452466 <p00452466@notesmail.huawei.com>
Date:   Sat Dec 5 03:07:19 2020 +0800

    Description:add Change kernel type from liteos_riscv to liteos_m
    Reviewed-by:liubeibei
```

- 20210318: 支持独立的外接设备驱动组件编译

```bash
$ git -P log -n1 814c81
commit 814c816f9b7f900113bed0f75a8122dba5555f65
Merge: 3dc5b1d 5353b23
Author: openharmony_ci <7387629+openharmony_ci@user.noreply.gitee.com>
Date:   Thu Mar 18 19:58:42 2021 +0800

    !44 组件化解耦修改--支持独立的外接设备驱动组件编译
    Merge pull request !44 from kevin/0316_release_build
```

- 2021.03.20: 本模块已经提交到 pypi，[链接](https://pypi.org/project/ohos-build/)

```bash
$ git -P log -n1  958189
commit 95818940a0bc47d25e7454c4d37732e90f7d2df8
Author: pilipala195 <yangguangzhao1@huawei.com>
Date:   Sat Mar 20 12:35:48 2021 +0800

    Upload ohos_build to Pypi
```

- 2021.04.03: 构建不再需要先 `hb set`，可以直接 `hb build`。

```bash
$ git -P log -n1 32d740
commit 32d7402125db0c46c43b05322e588a692f96827a
Author: SimonLi <likailong@huawei.com>
Date:   Sat Apr 3 08:55:13 2021 +0800

    IssueNo: #I3EPRJ
    Description: build device with no need to hb set
    Sig: build
    Feature or Bugfix: Feature
    Binary Source: No
```

## hpm

hpm 是 2020 下半年开始，HW 开发的包管理平台，js 语言，npm 安装和更新：

```bash
$ npm install -g @ohos/hpm-cli # 安装
$ npm update  -g @ohos/hpm-cli # 更新
$ npm rm      -g @ohos/hpm-cli # 卸载
```

### 基本命令

- `hpm init [-t template]` 在一个文件夹中初始化一个 hpm 包，主要是创建 bundle.json 文件

```bash
$ hpm init -t dist
Initialization finished.
$ cat bundle.json
{
  "name": "dist",
  "version": "1.0.0",
  "publishAs": "distribution",
  "description": "this is a distribution created by template",
}
```

- `hpm i|install [name]` 下载依赖并安装，必须在已经 `hpm init` 的目录下执行

```bash
$ hpm i @ohos/hispark_pegasus
```

- `hpm d|download [name]` 仅下载指定包(tgz 文件），不下载依赖，可以在任何目录中执行

```bash
$ hpm d @ohos/hispark_pegasus
$ ls @ohos-hispark_pegasus-1.0.3.tgz
@ohos-hispark_pegasus-1.0.3.tgz
```

- `hpm list` 打印依赖关系图

```bash
$ hpm list
+--dist@1.0.0
│ +--@ohos/hispark_pegasus@1.0.3
│ │ +--@ohos/bootstrap@1.1.1
│ │ +--@ohos/bounds_checking_function@1.1.1
```

- `hpm pack` 打包组件（bundle），生成 tgz 文件。

```bash
$ hpm pack
> Packing dist-1.0.0.tgz /home/kevin/workspace/harmony/src/hpm.i/@hihope-neptune_iot
>   directory .
>     . . bundle.json
>     . . README.md
>     . . LICENSE
> Packing dist-1.0.0.tgz finished.
```

harmony 的组件（bundle）和发行版（distribution）之间是包含关系，组件由`代码 + bundle.json + README + LICENSE` 组成，发行版由 `多个组件 + scripts` 组成，官方给出的关系图：

![](images/bundle.and.distribution.png)

- `hpm ui` 创建 http 访问的前端，在浏览器上可查看多种信息，执行多种命令，也可以在 docker 中执行，在 host 中浏览器访问。

![](images/hpm-cli-ui.png)

hpm 迭代很快，尤其是 2021.6.2 发布 Harmony2.0 以后，几天一更新，所以，即使使用 docker 容器，也建议先升级一下 hpm，以获取最新版本的特性。

### 源码解析

hpm 相比 hb，增加了包管理的概念，不再是纯的编译框架，hb 无法管理包之间的依赖关系，以及同一个包的多版本控制，hpm 类似 pip、npm 解决这些问题。

从 [hpm-cli 在 npm 官网](https://www.npmjs.com/package/@ohos/hpm-cli) 上看，2020.8 提交 0.0.1 版本，但一直都没什么下载量，直到 2021.5 才开始有下载。源码暂时没找到，只能从其安装路径中看到一些：

```bash
$ hpm -V
1.2.6
$ which hpm
/home/kevin/.nvm/versions/node/v14.15.0/bin/hpm
$ ls ~/.nvm/versions/node/v14.15.0/lib/node_modules/@ohos/hpm-cli
bin  hpm-debug-build.js  lib  LICENSE  node_modules  package.json  README.md  README_ZH.md
```

hpm 为每个子命令定义了一个 js 文件

```bash
$ ls ~/.nvm/versions/node/v14.15.0/lib/node_modules/@ohos/hpm-cli/lib/commands
build.js        download.js      init.js     publish.js  uninstall.js
checkUpdate.js  extract.js       install.js  run.js      update.js
code.js         fetch.js         lang.js     script.js
config.js       generateKeys.js  list.js     search.js
distribute.js   index.js         pack.js     ui.js
```

每次执行 `hpm xxx` 命令，main.js 解析入参并转给相应的 command(lib/commands/xxx.js)，每个命令的执行逻辑可参考代码，比如 dist 会检查 build 框架，然后交权给 build 命令，build 会先检查依赖，然后进行单线程 or 多线程编译，这里的编译依然会使用 gn 和 ninja，编译完毕后 dist 会进行打包。

```plantuml
@startuml
:hpm xxx;
partition lib/main.js {
    :解析入参;
    :调用对应命令;
}
fork
:xxx = dist;
partition lib/commands/distribute.js {
    :调用 distribute() 函数;
    :调用 bundleDist();
    :_build.bundleBuild() 转入 build;
    :runDistCmd() 打包;
}
fork again
:xxx = build;
partition lib/commands/build.js {
    :调用 build() 函数;
    :startBuild();
    if (多线程) then
    :startBuildThread();
    else
    :bundleBuild();
    endif
}
fork again
:xxx = init;
partition lib/commands/init.js {
    :......;
}
fork again
:xxx = pack;
partition lib/commands/pack.js {
    :......;
}
end fork

end
@enduml
```

### History

- 1.1.0（202104）：新增 GUI，`hpm ui` 启动
- 1.2.3（202106）：新增 `fetch`、`download`、`code` 子命令

## DevEco Device Tool

HUAWEI DevEco Device Tool（下文简称 DDT）是 HarmonyOS 面向智能设备开发者提供的一站式集成开发环境，它比 hpm 提供了更多的功能：组件按需定制，支持代码编辑、烧录和调试等。

所以 DDT 已经不再局限与本文所讨论的**编译**，但 DDT 的编译过程又比较特殊，它更加灵活的使用 hb、hpm 等工具，并又开发了一个 hos。当你使用 DDT build 的时候，执行了这个命令：

```bash
/home/kevin/.deveco-device-tool/core/deveco-venv/bin/hos run --project-dir /home/kevin/workspace/harmony/src/bearpi --environment bearpi_hm_nano
```

DDT 安装在 `~/.deveco-device-tool`，主要含 3 个文件夹：core、platforms、plugins

core 包含了编译、调试、烧录工具，和 python 的虚拟环境：

```bash
$ ls .deveco-device-tool/core
arm_noneeabi_gcc  deveco-venv                     tool_hiburn                 tool_openocd
contrib_pysite    feature-toggling-manifest.json  tool_lldb                   tool_scons
deveco-home       tool_burn                       tool_openlogic_openjdk_jre  tool_trace
```

platforms 包含针对不同 SoC 厂家的编译工具，海思、联盛德、NXP……每家一个文件夹，大多是 python 实现，其中有些含 hb.py，有些没有 hb，看来定制化已经让编译工具五花八门，HW 也不管了，自家分开玩儿吧。

```bash
$ ls .deveco-device-tool/platforms
asrmicro  bestechnic  blank  bouffalo  hisilicon  nxp  realtek  winnermicro  xradio
```

其中的 asrmicro（翱捷科技）、bestechnic（恒玄科技）、bouffalo（博流科技）、xradio（芯之联）都还没见到其开发板，应该在开发中或已经 alpha 状态了。

plugins 中包含 VSCode 的扩展文件

```bash
$ ls .deveco-device-tool/plugins
deveco-device-tool-2.2.0+285431.76f4090e.vsix
```

由于 DDT 既不开源，也缺乏文档，所以暂时很难解读，以后再说。

官方资源：

- [DDT 下载](https://device.harmonyos.com/cn/ide#download_release)
- [DDT 版本说明](https://device.harmonyos.com/cn/docs/ide/releases/release_notes-0000001057397722)
- [HUAWEI DevEco Device Tool 常见问题](https://developer.huawei.com/consumer/cn/forum/topic/0203380024404140371?fid=26)

## 总结

### 兼容关系图

```plantuml
@startmindmap
* python build.py [build]
 * hb set
  * set_root_path()
   * 提示用户选择源码根目录
  * set_product()
   * 搜索 vender/.../config.json，提示用户选择编译目标
   * 根据用户选择的 config.json，读取其中的 device info（device、board、kernel、features、components）
   * 生成 ohos_config.json
 * hb build
@endmindmap
```

### 下载-编译对比表

| 对比项            | HarmonyOS (repo) |  neptune (hpm)   | pegasus (hpm) | 3861 (DE) | bearpi (DE) | 3516/8 (DE) |
| ----------------- | :--------------: | :--------------: | :-----------: | :-------: | :---------: | :---------: |
| 别称              |        \*        |   HH-SLNPT10x    |  Hi3861V100   |           |             |             |
| SoC               |        \*        | WinnerMicro W800 |    Hi3861     |  Hi3861   |   Hi3861    |  Hi3516/18  |
| SoC Kernel        |        \*        | 玄铁 804(RISC-V) |    RISC-V     |   同左    |    同左     |  Cortex-A7  |
| 外设              |        \*        | 2MB(F)+288KB(R)  |               |           |             |             |
| 特色              |        \*        |     WiFi、BT     |  2.4GHz WiFi  |   同左    |             |             |
| Vendor            |        \*        |   润和(hihope)   | 海思(HiSili)  |   同左    |   小熊派    |             |
| `/build.py`       |        Y         |        -         |               |     -     |             |             |
| `/.deveco`        |        -         |        -         |       -       |     Y     |      Y      |             |
| `/.vscode`        |        -         |        -         |       -       |     Y     |      Y      |             |
| `/device`         |        Y         |       [Y]        |               |     -     |             |             |
| `/vendor`         |        Y         |        -         |               |     Y     |             |             |
| `/build/`         |        Y         |        Y         |       Y       |     Y     |      -      |      -      |
| `/build/lite/hb`  |        Y         |        -         |       Y       |     -     |      -      |      -      |
| `hb build`        |                  |                  |               |           |             |             |
| `python build.py` |                  |                  |               |           |             |             |
| `hpm dist`        |                  |                  |               |           |             |             |
| `DE build`        |                  |                  |               |           |             |             |

- pegasus: 飞马、天马
- neptune：海王星
- taurus：金牛座
- aries：白羊座
- WinnerMicro：北京联盛德微电子
