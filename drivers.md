# OpenHarmony 驱动子系统

HDF（HarmonyOS Driver Foundation）驱动框架：

- 集中管理驱动服务：按需加载、按序加载
- 驱动消息机制：用户态应用——内核态驱动之间互发消息

git：

- HDF Frameworks：[CodeChina](https://codechina.csdn.net/openharmony/drivers_hdf_frameworks)
- HDF Lite：[CodeChina](https://codechina.csdn.net/openharmony/drivers_liteos)、[Gitee](https://gitee.com/openharmony/drivers_liteos)
- Vendor Huawei HDF：[CodeChina](https://codechina.csdn.net/openharmony/vendor_huawei_hdf)

对外暴露的接口：

```bash
drivers_hdf_frameworks/include $ tree -L 1
.
├── config
├── core
├── net
├── osal        # OSAL((Operating System Abstraction Layer 操作系统抽象层)
├── platform    # 驱动平台——已经实现了的驱动
├── utils
└── wifi        # 向上为HAL提供了调用接口；平行提供了Init接口；向下提供了各厂商硬件模块接口；
drivers_hdf_frameworks/include $ tree platform
platform            # 驱动平台实现了最基本的几个总线驱动
├── gpio_if.h
├── hdf_platform.h
├── i2c_if.h
├── rtc_if.h
├── sdio_if.h
├── spi_if.h
├── uart_if.h
└── watchdog_if.h
```
