# OpenHarmonyOS 拾遗

## 产品兼容性规范

### 条款编号规则

[设备 ID/核心]-[Type]-[SR]-[编号]

- 设备 ID/核心：
  - W：适用于联接类模组设备的规范条款，对应的产品形态有，各种智能家居的联接模块。
  - IPC：适用于智慧视觉类设备的规范条款，对应的产品形态有，家用摄像头等产品。
  - C:核心规范条款，HarmonyOS 兼容设备可引用核心条款。
- Type：
  - HARDWARE：适用于硬件兼容性的条款。
  - SOFTWARE：适用于软件兼容性的条款。
  - UPDATE：适用于设备与 APP 升级的兼容性条款。
  - DISTRIBUTE：适用于分布式兼容性的条款。
  - PERFORMANCE：适用于性能兼容性的条款。
  - POWER：适用于功耗兼容性的条款。
  - SECURITY：适用于安全的兼容性条款。
  - MEDIA：适用于多媒体兼容性的条款。
  - TOOLS：关于开发工具与选项的兼容性条款。
  - CERTIFICATION：关于认证测试的兼容性条款。
- SR：
  - 无：Must
  - SR：STRONGLY RECOMMENDED

[HarmonyOS 的产品兼容性规范](https://device.harmonyos.com/cn/docs/design/compatibility/oem_pcs_des-0000001054785652)

### 条款摘要

- 【W-HARDWARE-0100】模组的主 CPU 的 DMIPS 必须大于 100M MIPS。
- 【W-HARDWARE-0200】设备整体 RAM 空间：≥256KB。
- 【W-HARDWARE-0300】设备整体 Flash 空间：≥2MB。
- 【W-HARDWARE-0400】用户可读写 Flash 空间 ≥128Kbyte。

---

- 【C-SOFTWARE-SR-0100】强烈推荐支持 CV 能力。
- 【C-SOFTWARE-SR-0200】强烈推荐支持 ASR 能力。
- 【C-SOFTWARE-0800】必须能够安装和运行由 HarmonyOS 打包工具生成的 hap 包。
- 【C-SOFTWARE-0900】用户只能够安装 HarmonyOS 应用市场发布的 hap 包。

---

- 【C-DISTRIBUTE-0100】禁止修改 HarmonyOS 分布式网络的基于 coap 的设备发现协议。
