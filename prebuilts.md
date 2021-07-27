# OpenHarmony 预编译内容

本目录包含 Harmony 官方预编译

## MUSL

musl 是基于 Linux 系统调用 API 之上实现的 C 语言标准库(libc)，历史可以追溯到 2005 年，但在 2011 年才正式确定了 MUSL 这个名称，开始对标 glibc、uClibc，从 2012 年开始，musl 开始使用 MIT License。

有必要特别提一下 MIT License，鸿蒙的 200+组件里使用了五花八门的 License，以 Apache 居多，GPL、木兰、Huawei……都有，但 MIT 的还是少见，因为此处鸿蒙使用的是 musl 二进制版本，MIT 是允许的，但 MIT 也要求必须要增加 License 文件，鸿蒙并没有附带，希望能够补上。

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
root@b2afc2921eb7:/home/musl# ls obj/musl-gcc
obj/musl-gcc
```

`make install` 安装的话会从源向目的拷贝文件:

| 源                            | 目的                       |
| ----------------------------- | -------------------------- |
| `lib/*.a`、`lib/*.o`          | `/usr/local/musl/lib/`     |
| `include/*.h`、`arch/xxx/*.h` | `/usr/local/musl/include/` |
| `obj/musl-gcc`                | `/usr/local/musl/bin/`     |

### 使用 musl: .o/.h/musl-gcc

现在，你就可以舍弃掉 gcc，转用 musl-gcc 这个 Compiler 编译自己的程序了，甚至可以用 musl-gcc 再次编译 musl 自己，编译结果会比 gcc 缺少几个文件。

```bash
root@b2afc2921eb7:/home/musl# CC="/usr/local/musl/bin/musl-gcc -static" ./configure --prefix=$HOME/musl && make -j8
...
```

编译一个 HelloWorld 也是轻而易举的，就不演示了。

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
$ docker run -it muslcc/x86_64:riscv32-linux-musl
/ # cat main.c
#include <stdio.h>

int main(void){
    printf("Hello musl");
    return 0;
}
/ # gcc main.c -I riscv32-linux-musl/include
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

可见，编译出来的已经是 RISC-V target 上的 hello world。

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

然后就可以用 make 来编译自己的项目了，但请注意，不能用来编译 musl 自己了，因为前文说过，musl 仅支持从 gcc、clang、cparser、PCC 编译，还不支持自己编译自己。

我们来总结一下：

- C 标准库通常包括：C 语言标准库、POSIX、编译器扩展……其中 C 语言标准库有 ANSI C89、ISO C99、ISO C1x 等，POSIX 跟随 Unix/Linux 的发展和归入 ISO/IEC 9945 后每隔几年也都会推出新版本。
- glibc 是服务器和桌面操作系统中绝对霸主的 libc
- 嵌入式的 libc 呈三足鼎立：uClibc、[eglibc](http://www.eglibc.org)、musl —— 从 eglibc 名称可以看出 embedded gnu libc，是 glibc 抢占嵌入式市场的裁剪版。
- [这里](https://www.etalabs.net/compare_libcs.html) 有一份几个 libc 的对比
- musl 虽然轻量，但其实并不限于嵌入式设备，很多 Linux 发行版也在内嵌 musl，比如很多 docker 基于的 Alpine，从 3.0 开始内嵌 musl。主流发行版（Unbunt、Fedora）也都可以安装 musl
  - `apt install musl musl-dev`
- 使用 docker 可以直接使用基于 musl 交叉编译 toolchain 和 libc，但需要自己安装一下 make。

## sysroot
