# SkyTemple CN

SkyTemple 1.8.4 中文版 —— 基于官方 [SkyTemple](https://github.com/SkyTemple/skytemple) 的中文本地化构建。

## 功能

- 全中文界面（13,000+ 条翻译）
- 脚本编辑器支持中文文本编辑（S.E.D.）
- 文本字符串（text_e.str）支持中文编辑
- 自定义 PMD2 字符映射表（7,251 个 CJK 字符）
- 用户级安装器，无需管理员权限

## 下载

[Releases](https://github.com/Givoihll/SkyTemple-CN/releases) 页面获取最新安装包。

## 使用

1. 安装 SkyTemple CN
2. 打开需要编辑的 ROM（.nds）
3. 脚本编辑器（虫子图标）中编辑剧情脚本
4. 文本字符串模块中编辑 text_e.str 内容

支持编辑中文的前提：
- ROM 已注入中文字库（参见 [空之探险队Script编辑教程](https://pan.baidu.com/s/1kWWCL8gGsMSi8BOeV7v-7w?pwd=1yw5)）
- charmap.txt 与 ROM 的字符映射一致

## 构建

参见 [BUILD.md](BUILD.md)。

## 许可证

GPL v3，基于 [SkyTemple](https://github.com/SkyTemple/skytemple) 修改。

## 致谢

- SkyTemple 上游开发者（Marco Köpcke, irdkwia, End45, tech-ticks, Chesyon, Frostbyte0x70 等）
- Chesyon：PR #844 修复 Windows/Mac 构建流水线
- Frostbyte0x70：PR #844 审查与合并
- Givoill & 茸明_Edelherd：空之探险队脚本编辑教程

