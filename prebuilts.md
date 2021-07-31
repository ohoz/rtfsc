# OpenHarmony 预编译内容

本子系统包含鸿蒙为开发者预编译好的内容，主要为

- sysroot：ARM 版本的 MUSL libc 库，开发者可以通过 `clang --sysroot=<sysroot-dir>` 完成交叉编译中的链接操作
- signcenter：对应用签名，以保证应用完整性和来源可靠。

## MUSL

musl 是基于 Linux 系统调用 API 之上实现的 C 语言标准库(libc)，历史可以追溯到 2005 年，但在 2011 年才正式确定了 MUSL 这个名称，开始对标 glibc、uClibc，从 2012 年开始，musl 开始使用 MIT License。

musl 致力于简单、高效，凭借 libc 优秀的松耦合性，做到了静态版本最小 10kB，即使添加了线程等高级特性，也可以控制到 50kB，所以特别适合嵌入式设备。为了控制资源的使用， musl 自己竟然不做动态内存分配。

可以在其 [官网](http://musl.libc.org/) 下载源码，或者直接 `git clone git://git.musl-libc.org/musl`，查看文档则可以去 [wiki](https://wiki.musl-libc.org/)

musl 实现了多个标准中的 API：

- C 语言的标准库 API: [C99](http://repo.or.cz/w/musl-tools.git/blob_plain/HEAD:/tab_c99.html)、[C11](http://repo.or.cz/w/musl-tools.git/blob_plain/HEAD:/tab_c11.html)
- [POSIX 2008](http://repo.or.cz/w/musl-tools.git/blob_plain/HEAD:/tab_posix.html)
- 更广泛的 agreed-upon extensions

### 编译 musl 得到 libc 和 compiler

想要从源码编译 musl 需要的依赖非常少，也不限制在 linux 上编译，在 Linux 上编译也不需要 Linux kernel headers，只要有 make 和一个符合 C99 的 Compiler 就行，满足 C99 要求的 Compiler 不少：GCC、LLVM/clang、Firm/cparser、PCC 都行，都能够成功的编译 musl。

交叉编译 musl 也非常方便，从源码中可以看到支持非常多的 target CPU：

```bash
$ cd arch
$ ls
aarch64  arm  generic  i386  m68k  microblaze  mips  mips64  mipsn32  or1k  powerpc  powerpc64  riscv64  s390x  sh  x32  x86_64
```

> 只有 riscv64，没有 riscv32 么？

编译 musl 也非常简单，为了不影响 host，下面使用 gcc 的 docker：

```bash
$ cd musl-1.2.2
$ docker run -it -v $(pwd):/home/musl gcc
root@b2afc2921eb7:/ # cd /home/musl
root@b2afc2921eb7:/home/musl# ./configure
root@b2afc2921eb7:/home/musl# make -j8
```

编译出的结果位于 `lib/`，过程文件位于 `obj/`，和一个 compiler `musl-gcc`：

```bash
root@b2afc2921eb7:/home/musl# ls lib
Scrt1.o  crt1.o  crti.o  crtn.o  libc.a  libc.so  libcrypt.a  libdl.a  libm.a  libpthread.a  libresolv.a  librt.a  libutil.a  libxnet.a  musl-gcc.specs  rcrt1.o
root@b2afc2921eb7:/home/musl# ls obj
crt  include  ldso  musl-gcc  src
```

`make install` 安装的话会从源向目的拷贝文件:

| 源                            | 目的                       |
| ----------------------------- | -------------------------- |
| `lib/*.a`、`lib/*.o`          | `/usr/local/musl/lib/`     |
| `include/*.h`、`arch/xxx/*.h` | `/usr/local/musl/include/` |
| `obj/musl-gcc`                | `/usr/local/musl/bin/`     |

### 使用 musl 编译 helloworld

现在，你就可以舍弃掉 gcc，转用 musl-gcc 这个 Compiler 编译自己的程序了，依然在 gcc 的 docker 里测试：

```bash
root@b2afc2921eb7:/home/musl# cat main.c
#include <stdio.h>

int main(void){
    printf("Hello musl\n");
    return 0;
}
root@b2afc2921eb7:/home/musl# /usr/local/musl/bin/musl-gcc main.c
root@b2afc2921eb7:/home/musl# ./a.out
Hello musl
```

甚至可以用 musl-gcc 再次编译 musl 自己，编译结果会比 gcc 缺少几个文件 —— 能不能用没试过，至少能编过。

```bash
root@b2afc2921eb7:/home/musl# CC="/usr/local/musl/bin/musl-gcc -static" ./configure --prefix=$HOME/musl && make -j8
...
```

### 交叉编译

**交叉编译**则要复杂一些，首先要准备好 cross-compile toolchain：

1. 官方建议直接从 [musl.cc](https://musl.cc/) 下载网友做好的 toolchain
2. 或使用开源项目 [musl-cross-make](https://github.com/richfelker/musl-cross-make/) 自己生成 toolchain。—— 自己生成真心没必要，直接用 musl.cc 很香的。

最香的当然是直接用 [musl.cc 的 docker](https://hub.docker.com/r/muslcc/x86_64) 啦：

```bash
$ docker pull muslcc/x86_64:riscv32-linux-musl
```

muslcc 发布的 docker image 的 tag 都是 `[arch]-linux-musl[abi_modifiers]` 这样命名的，没有 latest 这个 tag，所以请先在 [musl.cc 的 dockerhub](https://hub.docker.com/r/muslcc/x86_64) 上看好 tag。

跑一个试试：

```bash
$ docker run -it -v $(pwd):/home/musl muslcc/x86_64:riscv32-linux-musl
/ # gcc -v
Using built-in specs.
COLLECT_GCC=gcc
COLLECT_LTO_WRAPPER=/libexec/gcc/riscv32-linux-musl/10.2.1/lto-wrapper
Target: riscv32-linux-musl
```

docker 里的 gcc 已经是为 riscv32 准备的了，环境变量（LIBPATH、LIBRARY_PATH、LD_LIBRARY_PATH）也都准备好了，所以可以直接编译自己的 helloworld：

```bash
/ # gcc main.c
/ # readelf -h a.out
ELF Header:
  Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF32
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              DYN (Shared object file)
  Machine:                           RISC-V
...
```

可见，编译出来的已经是 RISC-V target 上的 hello world，它是不能在 x86 cpu 上运行的。

遗憾的是，docker 中缺少 make 命令，这叫我如何编译基于 Makefile 的项目？肯定要安装一个，但从源码安装会遇到困难，因为编译 make 自身的源码需要 gcc 和 glibc，但 docker 中已经被替代成 musl 相关的了，所以只能安装二进制版本。docker 是基于 Alpine 的，使用 `apk add` 安装吧：

```bash
/ # cat /etc/apk/repositories
https://dl-cdn.alpinelinux.org/alpine/v3.13/main
https://dl-cdn.alpinelinux.org/alpine/v3.13/community
```

先查看一下 apk 的安装源是不是可用，如果有必要请更换国内源或公司内源。

```bash
/ # apk add make
```

然后就可以用 make 来编译自己的项目了，但这次我也试了一下编译 musl 自己，没编过，毕竟 musl 自己说仅支持 gcc、clang、cparser、PCC 编译，没说一定能自己编译自己。

### 总结

- C 标准库(libc)通常包括：C 语言标准库、POSIX、编译器扩展……其中 C 语言标准库有 ANSI C89、ISO C99、ISO C1x 等，POSIX 跟随 Unix/Linux 的发展和归入 ISO/IEC 9945 后每隔几年也都会推出新版本。
- glibc 是服务器和桌面操作系统中绝对霸主的 libc
- 嵌入式的 libc 呈三足鼎立：uClibc、[eglibc](http://www.eglibc.org)、musl —— 从 eglibc 名称可以看出 embedded gnu libc，是 glibc 抢占嵌入式市场的裁剪版。
- [这里](https://www.etalabs.net/compare_libcs.html) 有一份几个 libc 的对比
- musl 虽然轻量，但其实并不限于嵌入式设备，很多 Linux 发行版也在内嵌 musl，比如很多 docker 基于的 Alpine，从 3.0 开始内嵌 musl。主流发行版（Unbunt、Fedora）也都可以安装 musl
  - `apt install musl musl-dev`
- 使用 docker 可以直接使用基于 musl 交叉编译 toolchain 和 libc，但需要自己安装一下 make。

## sysroot

### 编译链接、入参、环境变量

我们使用 compiler 编译（预处理+编译+汇编）得到目标文件（.o），使用 linker 链接得到共享/动态库（.so）或归档/静态库(.a)，最后使用 loader 加载运行 —— 这 3 个过程都需要 libc 的支撑，包括：编译和链接时提供头文件和编译好的库，加载运行时为动态库提供 lib。

- Compiler/Linker 主流的有：gcc(as/ld)、LLVM/clang、ARM Compiler、MS Compiler……
- Libc 主流的有：glibc、eglibc、uClibc、musl……更合理的说法这里还应有 libc++，比如微软的 [MSVC STL](https://github.com/microsoft/STL)
- loader 在 linux 上是装载 ELF 文件，windows 上是装载 PE 文件

[gcc linker and loader](images/linker.and.loader.md ':include')

> 有个容易让人误解的地方是：gcc 的 linker 叫 ld，很容易让人感觉这是个 loader，至于为啥这么命令，历史原因吧，有些人解释为 Linker eDitor，有些人解释为 Link Dynamic，反正不是 load。

除了基本流程，还有就是 gcc 众多参数的乱花渐欲迷人眼，最常混淆的有库文件搜索路径、处理器相关参数……比如有下面一个命令

`gcc -I <dir1> -l<xxx> -L <dir2> -Wl,-rpath-link,<dir3:dir4> -Wl,-rpath,<dir5:dir6>`

- Compiler 用的参数
  - `-I <dir>` 指定搜索 include 文件的路径
- Linker(ld) 用的参数
  - `-l<xxx> -L <dir>` 链接 libxxx.o，可以在 `-L` 指定的 dir 中寻找
  - `-Wl,...` 传递给 linker
    - `-rpath-link,<dir>`：链接动态库时搜索路径
    - `-rpath,<dir>`：运行动态库时搜索路径
- 环境变量
  - `LIBRARY-PATH`：gcc linker 在链接时使用的环境变量，详细参考 [GCC 文档](https://gcc.gnu.org/onlinedocs/gcc/Environment-Variables.html)
  - `LD_LIBRARY_PATH`

搜索依赖库文件的顺序可以整理为下表：

| 搜索路径             | ld 编译静态库 | ld.so 编译动态库 | ld.so 执行动态库 | 备注                                |
| -------------------- | :-----------: | :--------------: | :--------------: | ----------------------------------- |
| `-rpath-link`        |               |        Y         |                  | 用于编译时写入必要的信息到目标文件  |
| `-rpath`             |               |                  |        Y         | 编译时写入目标文件，运行时使用      |
| `-L`                 |       Y       |        Y         |                  |                                     |
| `LIBRARY_PATH`       |       Y       |        Y         |                  | GCC 使用的环境变量，传递给 linker   |
| `LD_LIBRARY_PATH`    |               |                  |        Y         | `LD_` 是 glibc 对环境变量的统一命名 |
| `/etc/ld.so.conf.d/` |               |                  |        Y         | ldconfig 可修改                     |
| 默认路径             |       Y       |        Y         |        Y         | `ld --verbose` 可查看               |

> - 更多寻找依赖文件顺序的细节可以参考：[Binutils 的 ld 手册](https://sourceware.org/binutils/docs/ld/Options.html#Options) 或 [ld 的 MAN 手册](https://man7.org/linux/man-pages/man1/ld.1.html) 中 `-rpath-link=dir` 章节，内容是一样的。
> - LIBRARY_PATH 可参考 [GCC 手册](https://gcc.gnu.org/onlinedocs/gcc/Environment-Variables.html)。
> - LD_LIBRARY_PATH 可参考 [Glibc ld.so 的 MAN 手册](https://man7.org/linux/man-pages/man8/ld.so.8.html) 中 ENVIRONMENT 章节。[glibc 的文档](https://www.gnu.org/software/libc/documentation.html)分 2 部分：[manual](https://www.gnu.org/software/libc/manual/) 和 [linux man pages](https://www.kernel.org/doc/man-pages/)，manual 更像一个培训文档，man pages 通常更详细，glibc 的作者有些会在 2 个地方同时写文档，有些则只写在 man pages 中。

```bash
$ ld --verbose
...
SEARCH_DIR("=/usr/local/lib/x86_64-linux-gnu");
SEARCH_DIR("=/lib/x86_64-linux-gnu");
SEARCH_DIR("=/usr/lib/x86_64-linux-gnu");
SEARCH_DIR("=/usr/local/lib64");
SEARCH_DIR("=/lib64");
SEARCH_DIR("=/usr/lib64");
SEARCH_DIR("=/usr/local/lib");
SEARCH_DIR("=/lib");
SEARCH_DIR("=/usr/lib");
SEARCH_DIR("=/usr/x86_64-linux-gnu/lib64");
SEARCH_DIR("=/usr/x86_64-linux-gnu/lib");
...
```

另外，`gcc -print-search-dirs` 能够打印 gcc 默认搜索路径，和 ld 会有重叠，但不一样，两个分别是前端和后端工具，有差异也正常，况且后端现在流行 LLVM，llvm 也有自己的默认配置呢。

```bash
$ gcc -print-search-dirs
install: /usr/lib/gcc/x86_64-linux-gnu/5/
programs: =/usr/lib/gcc/x86_64-linux-gnu/5/:/usr/lib/gcc/x86_64-linux-gnu/5/:/usr/lib/gcc/x86_64-linux-gnu/:/usr/lib/gcc/x86_64-linux-gnu/5/:/usr/lib/gcc/x86_64-linux-gnu/:/usr/lib/gcc/x86_64-linux-gnu/5/../../../../x86_64-linux-gnu/bin/x86_64-linux-gnu/5/:/usr/lib/gcc/x86_64-linux-gnu/5/../../../../x86_64-linux-gnu/bin/x86_64-linux-gnu/:/usr/lib/gcc/x86_64-linux-gnu/5/../../../../x86_64-linux-gnu/bin/
libraries: =/usr/lib/gcc/x86_64-linux-gnu/5/:/usr/lib/gcc/x86_64-linux-gnu/5/../../../../x86_64-linux-gnu/lib/x86_64-linux-gnu/5/:/usr/lib/gcc/x86_64-linux-gnu/5/../../../../x86_64-linux-gnu/lib/x86_64-linux-gnu/:/usr/lib/gcc/x86_64-linux-gnu/5/../../../../x86_64-linux-gnu/lib/../lib/:/usr/lib/gcc/x86_64-linux-gnu/5/../../../x86_64-linux-gnu/5/:/usr/lib/gcc/x86_64-linux-gnu/5/../../../x86_64-linux-gnu/:/usr/lib/gcc/x86_64-linux-gnu/5/../../../../lib/:/lib/x86_64-linux-gnu/5/:/lib/x86_64-linux-gnu/:/lib/../lib/:/usr/lib/x86_64-linux-gnu/5/:/usr/lib/x86_64-linux-gnu/:/usr/lib/../lib/:/usr/lib/gcc/x86_64-linux-gnu/5/../../../../x86_64-linux-gnu/lib/:/usr/lib/gcc/x86_64-linux-gnu/5/../../../:/lib/:/usr/lib/
```

### 啥是 sysroot

交叉编译时，以 Host 为 x86_64，target 为 risc-v 为例，目标文件是 risc-v 上运行的可执行文件或静态、动态库文件，交叉编译器链接时绝对不应该找 x86_64 版本的 glibc 或其他指定 lib 进行链接，所以 gcc 根据 `gcc --with-sysroot -sysroot=<dir>` 传入的 sysroot 参数，在寻找 include 和 libc 的时候把目录加上 sysroot，比如 `gcc -sysroot=/riscv32-linux-musl` 就会发生如下替换：

- `/usr/include` 被替换为 `/riscv32-linux-musl/usr/include`
- `/usr/lib` 被替换为 `/riscv32-linux-musl/usr/lib`

交叉编译 toolchain 是 Host 版本的，sysroot 里面的 include、lib 是 Target 版本的，来看看 MUSL docker 中的展现：

```bash
/ # gcc -print-sysroot
/riscv32-linux-musl
/ # readelf -h /riscv32-linux-musl/lib/crt1.o
ELF Header:
   ...
  Machine:                           RISC-V
  ...
/ # readelf -h /riscv32-linux-musl/bin/ld
ELF Header:
  ...
  Machine:                           Intel 80386
  ...
```

所以，在这个 docker 容器里，可以用 80386 版本的 ld 链接 RISC-V 版本的目标文件，当前 docker 中已经写好了 sysroot 的默认值，用户可以不用再 `gcc -sysroot=<dir>` 手动指定，否则就需要。

## 鸿蒙的 sysroot

**本章节解析的组件及其对应的目录、git 库如下：**

| hpm 组件名        | 源码目录               | gitee url                                            |
| ----------------- | ---------------------- | ---------------------------------------------------- |
| [@ohos/sysroot][] | prebuilts/lite/sysroot | https://gitee.com/openharmony/prebuilts_lite_sysroot |

[@ohos/sysroot]: https://hpm.harmonyos.com/#/cn/bundles?q=%40ohos%2Fsysroot

鸿蒙的 sysroot 不是给 gcc 用的，而是给 clang 的交叉编译 toolchain，但原理相同，都是为了指定 Target 版本 MUSL 的 include 和 libc 搜索路径，这个路径就是：`prebuilts/lite/sysroot/usr`，里面有 30M 左右的编译好的文件：

```bash
$ pwd
/home/kevin/OpenHarmonyOS/prebuilts/lite/sysroot/usr
$ du -sh *
1.2M    include
26M     lib
```

它们是为 ARM@Linux 编译的：

```bash
$ readelf -h lib/arm-liteos/crt1.o
ELF Header:
  ...
  OS/ABI:                            UNIX - System V
  Machine:                           ARM
  ...
```

使用时：

```
clang -o helloworld helloworld.c --sysroot=/home/kevin/OpenHarmonyOS/prebuilts/lite/sysroot/usr
```

另外，鸿蒙也允许开发者自己编译 MUSL 来定制自己的 sysroot，执行 `sysroot/build` 目录下的 `thirdparty_headers.sh` 和 `build_musl_clang.sh` 脚本即可编译构建出新的 libc 库。
