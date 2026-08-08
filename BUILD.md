# SkyTemple CN 构建操作记录

> 2026-06-28 | 第三轮 AI 操作 | 基于干净官方源码重建

---

## 一、参考源码拉取

从 GitHub 克隆 SkyTemple 1.8.4 完整依赖链到 `参考（禁止修改）\`（**只读，禁止修改**）。

| 目录 | 来源 | 版本 | 提交数 |
|------|------|------|--------|
| `skytemple-source/` | SkyTemple/skytemple | 1.8.4 | 1749 |
| `skytemple-files-source/` | SkyTemple/skytemple-files | 1.8.4 | 1357 |
| `skytemple-rust-source/` | SkyTemple/skytemple-rust | 1.8.4 | 301 |
| `explorerscript-source/` | SkyTemple/explorerscript | 0.2.2 | 172 |
| `ssb-debugger-source/` | SkyTemple/skytemple-ssb-debugger | 1.8.3 | 350 |
| `ssb-emulator-source/` | SkyTemple/skytemple-ssb-emulator | 1.8.1 | 63 |
| `dtef-source/` | SkyTemple/skytemple-dtef | 1.8.0 | 69 |
| `skytemple-icons-source/` | SkyTemple/skytemple-icons | 1.3.2 | 13 |
| `eventserver-source/` | SkyTemple/skytemple-eventserver | 1.6.0 | 16 |
| `SkyTemple/` | 官方安装器解包 | 1.8.4 | 无 git |

子模块：
- `skytemple-files-source` 含 3 个 ASM 补丁子模块：`eos_move_effects`、`frost_asm_mods`、`pmd2_asm_mods`
- `skytemple-source` 含 1 个子模块：`flatpak-builder-tools`（Linux 打包用）

所有仓库均执行 `git fetch --unshallow` 转为全量克隆。

### 克隆命令

```powershell
git clone --depth 1 --branch 1.8.4 https://github.com/SkyTemple/skytemple.git "F:\Skytemple\参考（禁止修改）\skytemple-source"
git clone --depth 1 --branch 1.8.4 https://github.com/SkyTemple/skytemple-files.git "F:\Skytemple\参考（禁止修改）\skytemple-files-source"
git clone --depth 1 --branch 1.8.4 https://github.com/SkyTemple/skytemple-rust.git "F:\Skytemple\参考（禁止修改）\skytemple-rust-source"
git clone --depth 1 --branch 0.2.2 https://github.com/SkyTemple/explorerscript.git "F:\Skytemple\参考（禁止修改）\explorerscript-source"
git clone --depth 1 --branch 1.8.3 https://github.com/SkyTemple/skytemple-ssb-debugger.git "F:\Skytemple\参考（禁止修改）\ssb-debugger-source"
git clone --depth 1 --branch 1.8.1 https://github.com/SkyTemple/skytemple-ssb-emulator.git "F:\Skytemple\参考（禁止修改）\ssb-emulator-source"
git clone --depth 1 --branch 1.8.0 https://github.com/SkyTemple/skytemple-dtef.git "F:\Skytemple\参考（禁止修改）\dtef-source"
git clone --depth 1 --branch 1.3.2 https://github.com/SkyTemple/skytemple-icons.git "F:\Skytemple\参考（禁止修改）\skytemple-icons-source"
git clone --depth 1 --branch 1.6.0 https://github.com/SkyTemple/skytemple-eventserver.git "F:\Skytemple\参考（禁止修改）\eventserver-source"

# 子模块
git -C "F:\Skytemple\参考（禁止修改）\skytemple-files-source" submodule update --init --recursive

# 转全量
git -C "F:\Skytemple\参考（禁止修改）\skytemple-source" fetch --unshallow
# ... (每个仓库同样操作)
```

---

## 二、脏源码诊断与清理

### 2.1 对比发现

对比工作目录 vs 官方源码，发现三个工作目录被前轮 AI 不同程度修改：

**skytemple-files-master**（污染最重）：
- 近 300 个文件被修改，多数是版权年 `2024→2025` 批量替换
- 7 个文件有实质逻辑改动：
  - `common/string_codec.py`：+172 行 CJK 字符集加载
  - `common/util.py`：+86 行 `delete_file_in_rom` 函数
  - `script/ssb/script_compiler.py`：+13 行 `_unescape` 正则
  - `script/ssb/flow.py`：f-string 格式化变化
  - `common/tiled_image.py`：`_()` 包装方式改写
  - `compression/bpc_tilemap/decompressor.py`：print 语句空格
  - `compression/px/compressor.py`：f-string 拆分

**ExplorerScript-master**（中度污染）：
- `explorerscript_reader.py`：+27 行 `_escape_non_ascii` 函数
- 此函数与 overrides 中的 no-op 版本互相矛盾（前两轮 AI 互相覆盖）

**skytemple-master**（轻度污染）：
- 10 个文件修改，主要是版权年 + `main.py` 启动路径修复 + `settings.py` 中文语言

### 2.2 备份脏版本

```powershell
Move-Item "F:\Skytemple\skytemple-master" "F:\Skytemple\backup_20260628_dirty\"
Move-Item "F:\Skytemple\skytemple-files-master" "F:\Skytemple\backup_20260628_dirty\"
Move-Item "F:\Skytemple\ExplorerScript-master" "F:\Skytemple\backup_20260628_dirty\"
```

### 2.3 重新复制干净官方源码

```powershell
Remove-Item "F:\Skytemple\skytemple-master" -Recurse -Force
Remove-Item "F:\Skytemple\skytemple-files-master" -Recurse -Force
Remove-Item "F:\Skytemple\ExplorerScript-master" -Recurse -Force

robocopy "F:\Skytemple\参考（禁止修改）\skytemple-source" "F:\Skytemple\skytemple-master" /E
robocopy "F:\Skytemple\参考（禁止修改）\skytemple-files-source" "F:\Skytemple\skytemple-files-master" /E
robocopy "F:\Skytemple\参考（禁止修改）\explorerscript-source" "F:\Skytemple\ExplorerScript-master" /E
```

---

## 三、中文补丁（最小必要修改）

### 3.1 补丁范围

只修改 2 个源文件 + 3 个运行时覆盖模块：

| 文件 | 改动 | 行数 |
|------|------|------|
| `skytemple/main.py` | `_ST_INTERNAL` DLL 路径 + charmap 加载 | +30 |
| `skytemple/controller/settings.py` | 中文语言条目 | +1 |
| `overrides/skytemple_files/common/string_codec.py` | CJK 字符集编解码 | 运行时覆盖 |
| `overrides/skytemple_files/script/ssb/script_compiler.py` | Unicode 转义还原 | 运行时覆盖 |
| `overrides/explorerscript/explorerscript_reader.py` | Windows CJK 兼容 | 运行时覆盖 |

### 3.2 main.py 补丁（行号精确插入）

在**官方原版**基础上，在第 16 行（许可证头结束）和第 17 行（`import os`）之间插入：

```python
# === Chinese/CJK support: DLL directory discovery + charset loading ===
import sys as _sys
import os as _os
_ST_INTERNAL = None
for _p in [
    getattr(_sys, "_MEIPASS", ""),
    _os.path.join(_os.environ.get("LOCALAPPDATA", ""), "skytemple", "_internal"),
    r"C:\Program Files\SkyTemple\_internal",
    r"F:\Skytemple\.dll_test",
]:
    if _p and _os.path.exists(_p): _ST_INTERNAL = _p; break
if _ST_INTERNAL is None:
    raise FileNotFoundError(
        "SkyTemple _internal directory not found. "
        "Please reinstall or ensure the application directory is intact."
    )

_os.add_dll_directory(_ST_INTERNAL)
_os.environ["PATH"] = _ST_INTERNAL + ";" + _os.environ.get("PATH", "")
_os.environ.setdefault("GI_TYPELIB_PATH", _ST_INTERNAL + "\\gi_typelibs")
```

在第 40 行和第 41 行（`settings = SkyTempleSettingsStore()`）之间插入：

```python
# === Load custom charset for Chinese/CJK support ===
import os as _os2
for _cp in [
    _os2.path.join(_ST_INTERNAL, "charmap.txt"),
    _os2.path.join(_os2.path.dirname(_os2.path.abspath(__file__)), "charmap.txt"),
]:
    if _os2.path.exists(_cp):
        from skytemple_files.common.string_codec import load_custom_charset
        _n = load_custom_charset(_cp)
        break
```

### 3.3 settings.py 补丁

在日语条目后插入中文：

```python
("zh_CN.utf8", _("中文 (Chinese)")),
```

### 3.4 运行时覆盖模块（overrides）

三个覆盖文件位于 `F:\Skytemple\overrides\`：

```powershell
overrides/
├── skytemple_files/common/string_codec.py     # CJK charset + load_custom_charset()
├── skytemple_files/script/ssb/script_compiler.py  # _unescape() regex
└── explorerscript/explorerscript_reader.py    # _escape_non_ascii (currently no-op)
```

开发模式下直接复制到 venv site-packages 替代官版：

```powershell
Copy-Item "F:\Skytemple\overrides\skytemple_files\common\string_codec.py" "$site\skytemple_files\common\"
Copy-Item "F:\Skytemple\overrides\skytemple_files\script\ssb\script_compiler.py" "$site\skytemple_files\script\ssb\"
Copy-Item "F:\Skytemple\overrides\explorerscript\explorerscript_reader.py" "$site\explorerscript\"
```

**注意**：打包安装时走 `runtime_hook.py` 的 `sys.meta_path` 拦截加载，不覆盖 site-packages。

---

## 四、虚拟环境与依赖

### 4.1 创建 venv

```powershell
python -m venv F:\Skytemple\.venv_build
```

Python 版本：系统 Python 3.11.9

### 4.2 安装 GTK wheels（gvsbuild 2026）

```powershell
$PYGOBJECT_WHL = "F:\gtk-build\build\x64\release\pygobject\dist\PyGObject-3.56.3-cp311-cp311-win_amd64.whl"
$PYCAIRO_WHL = "F:\gtk-build\build\x64\release\pycairo\dist\pycairo-1.29.0-cp311-cp311-win_amd64.whl"

pip install --force-reinstall $PYGOBJECT_WHL
pip install --force-reinstall $PYCAIRO_WHL
```

### 4.3 安装依赖

```powershell
cd F:\Skytemple\skytemple-master
pip install -r requirements-frozen.txt
pip install -e ".[eventserver,discord]" --no-deps
pip install --force-reinstall $PYGOBJECT_WHL  # pip 可能降级 PyGObject
pip install --force-reinstall $PYCAIRO_WHL
```

关键依赖版本（来自 PyPI，非本地修改）：
- skytemple-files 1.8.5
- explorerscript 0.2.2
- skytemple-ssb-debugger 1.8.3
- skytemple-ssb-emulator 1.8.1

---

## 五、DLL 运行库组合

### 5.1 问题背景

- gtk-build 2026 只有 57 个 DLL（不含 MSVC 运行时、Python DLL 等）
- 官方 `_internal` 有完整的 88 个 DLL + 23 个 PYD
- 直接混合会导致 pangocairo/cairo 版本冲突
- `os.add_dll_directory(Python DLLs 目录)` 会污染搜索路径触发 gdk 加载失败

### 5.2 最终方案：分层组合

目录：`F:\Skytemple\.dll_test\`（142 文件：118 DLL + 23 PYD + 1 charmap.txt）

构建逻辑：

```powershell
# 第一层：gtk-build 2026 的 57 个 DLL（GTK/Cairo/Pango 基础栈）
Copy-Item "F:\gtk-build\gtk\x64\release\bin\*.dll" $combined -Force

# 第二层：官方独有的 61 个 DLL（不覆盖 gtk 的文件名）
# 包括：python311.dll, SDL2.dll, libcrypto-3.dll, libssl-3.dll,
#       MSVCP140.dll, VCRUNTIME140.dll, api-ms-win-*.dll, 等
Get-ChildItem "$offInt\*.dll" | Where-Object { $_.Name.ToLower() -notin $gtkNames } | Copy-Item

# 第三层：官方 PYD 扩展
Copy-Item "$offInt\*.pyd" $combined -Force

# 第四层：charmap.txt
Copy-Item "F:\project53\charmap.txt" $combined -Force
```

### 5.3 DLL 冲突陷阱

| 陷阱 | 现象 | 解决 |
|------|------|------|
| 官方 DLL 覆盖 gtk DLL | pangocairo 入口点错误 | gtk 先拷贝，官方只补充不覆盖 |
| `add_dll_directory(Python DLLs)` | gdk-3-vs17.dll 加载失败 | 去掉此行，Python 自己能找到自己的 DLL |
| 缺少 SDL2.dll | ssb_emulator 导入失败 | 从官方 _internal 复制 |
| 缺少 MSVC 运行时 | 各种 DLL 加载失败 | 从官方 _internal 复制 VCRUNTIME 系列 |

---

## 六、GTK 资源路径

### 6.1 问题

源码模式运行缺少 GTK 资源发现：
- 自定义图标 `skytemple-image-loading-symbolic` 找不到
- GtkSourceView 样式方案（oblivion, tango 等）找不到
- GtkSourceView 语言规格（语法高亮）找不到

### 6.2 解决

设置环境变量 `XDG_DATA_DIRS` 指向 gtk-build 的 share 目录，一次性解决所有 GTK 资源路径：

```python
os.environ["XDG_DATA_DIRS"] = r"F:\gtk-build\gtk\x64\release\share"
```

这使 GTK 自动发现：
- `share/icons/` — 图标主题（Adwaita, hicolor）
- `share/gtksourceview-4/styles/` — 代码配色方案
- `share/gtksourceview-4/language-specs/` — 语法高亮定义
- `share/themes/` — GTK 主题

额外操作：将 `skytemple_icons` 的自定义图标复制到 gtk-build 的 hicolor 目录：

```powershell
Copy-Item "$venv\Lib\site-packages\skytemple_icons\hicolor\*" "F:\gtk-build\gtk\x64\release\share\icons\hicolor\" -Recurse -Force
```

### 6.3 注意

`GtkSource.StyleSchemeManager()` 每次新建实例都有独立搜索路径，不继承 `get_default()` 的设置。因此必须用 `XDG_DATA_DIRS` 环境变量而非 Python API 设置搜索路径。

---

## 七、启动脚本

### 最终版本：`F:\Skytemple\launch_cn.py`

```python
import os
os.add_dll_directory(r"F:\Skytemple\.dll_test")
os.environ["GI_TYPELIB_PATH"] = r"F:\gtk-build\gtk\x64\release\lib\girepository-1.0"
os.environ["XDG_DATA_DIRS"] = r"F:\gtk-build\gtk\x64\release\share"
import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk
from skytemple.main import main
main()
```

### 启动命令

```powershell
$env:Path = "F:\Skytemple\.dll_test;$env:Path"
$env:GI_TYPELIB_PATH = "F:\gtk-build\gtk\x64\release\lib\girepository-1.0"
$env:XDG_DATA_DIRS = "F:\gtk-build\gtk\x64\release\share"
& "F:\Skytemple\.venv_build\Scripts\python.exe" "F:\Skytemple\launch_cn.py"
```

---

## 八、验证

### 8.1 纯净版性能

首次用 100% 官方源码（零补丁）启动，用户确认脚本编辑器**非常流畅**。此前卡顿确认是前轮 AI 乱改源码导致，与 GTK 2026 无关。

### 8.2 中文补丁功能

测试用例：D07P11A / m08a1003 第一句

| 项目 | 值 |
|------|-----|
| 原文 | We're nearly there. |
| 改为 | 我们就快到了。 |
| ROM 文件 | `data\SCRIPT\D07P11A\m08a1003.ssb` |
| 偏移量 | 0x3B4 |
| 编码总长 | 14 字节 |

逐字验证（与 `charmap.txt` 对照）：

| 字符 | Unicode | charmap | ROM 字节 | 结果 |
|------|---------|---------|----------|------|
| 我 | U+6211 | 0x9370 | 93 70 | OK |
| 们 | U+4EEC | 0x8F46 | 8F 46 | OK |
| 就 | U+5C31 | 0x8D6D | 8D 6D | OK |
| 快 | U+5FEB | 0x8DEB | 8D EB | OK |
| 到 | U+5230 | 0x89FC | 89 FC | OK |
| 了 | U+4E86 | 0x8E8B | 8E 8B | OK |
| 。 | U+3002 | 0x8142 | 81 42 | OK |

编解码往返一致，中文补丁功能**验证通过**。

---

## 九、当前文件布局

```
F:\Skytemple\
├── 参考（禁止修改）\              ← 只读，9 个官方全量 git 仓库 + 安装器解包
├── backup_20260628_dirty\          ← 能跑但被污染的旧版源码
├── skytemple-master\               ← 1.8.4 官源 + 2 个补丁
│   └── skytemple\
│       ├── main.py                 【已修改】_ST_INTERNAL + charmap 加载
│       └── controller/settings.py  【已修改】中文语言
├── skytemple-files-master\         ← 1.8.4 官源，零修改
├── ExplorerScript-master\          ← 0.2.2 官源，零修改
├── overrides\                      ← 3 个中文补丁模块
│   ├── skytemple_files/common/string_codec.py
│   ├── skytemple_files/script/ssb/script_compiler.py
│   └── explorerscript/explorerscript_reader.py
├── .venv_build\                    ← Python 3.11.9 虚拟环境
├── .dll_test\                      ← 118 DLL + 23 PYD 组合运行库
├── launch_cn.py                    ← 启动脚本（开发模式）
├── clean.nds                       ← 测试 ROM（128 MB）
├── build_cn.ps1                    ← 旧构建脚本（根目录）
└── HANDOFF.md                      ← 旧交接文档
```

### 外部依赖

| 路径 | 用途 |
|------|------|
| `F:\gtk-build\` | gvsbuild 2026 编译产物（57 DLL + wheels） |
| `F:\gtk-build-backup\` | gtk-build 2026 备份 |
| `F:\gtk-build-backup-2024\` | 2024 构建残留（不完整，缺二进制） |
| `F:\project53\charmap.txt` | 中文字符映射表（7251 条） |
| `F:\yx\EOS\Source\` | ROM 源文件（只读，禁止修改） |

---

## 十、最终构建产物（2026-06-28）

### 产出

| 文件 | 大小 |
|------|------|
| `SkyTemple_CN_Setup.exe` | 73 MB |
| `build_cn_v2.ps1` | 构建脚本 |

### 验证结果

- 流畅度：**与官方版一致，不卡**
- 中文翻译：**302 KB MO，界面正常显示中文**
- 中文脚本编辑：**7 汉字逐字节验证通过（charmap.txt 编码正确）**
- 中文 PO：**579 KB，使用 msguniq --output-file 去重后 msgfmt 编译**

### 已知问题

1. msguniq 管道输出到 Set-Content 会损坏文件 → 已修复，改用 `--output-file` 参数
2. Python 3.11 DLLs 目录不得加入 `add_dll_directory`，会与 gtk 2026 DLL 冲突
3. 官方 skytemple.nsi 要求管理员权限，CN 版改 HKCU + LOCALAPPDATA 用户级安装
4. GTK 2026 与官方 2024 DLL 命名差异（如 libcrypto-3-x64 vs libcrypto-3），需分层组合 DLL 目录

### release_cn_v1 目录内容

```
release_cn_v1/
├── SkyTemple_CN_Setup.exe     ← 安装包
├── build_cn_v2.ps1            ← 构建脚本
├── main.py                     ← 已打补丁的源文件
├── settings.py                 ← 已打补丁的源文件
├── skytemple.spec              ← PyInstaller 规格（含 runtime_hooks）
├── runtime_hook.py             ← 元路径覆盖拦截器
├── skytemple_cn.nsi            ← NSIS 安装脚本
├── skytemple.po                ← 中文翻译（579 KB）
├── modern-wizard.bmp           ← 安装向导背景
└── overrides/                  ← 3 个运行时覆盖模块
    ├── skytemple_files/common/string_codec.py
    ├── skytemple_files/script/ssb/script_compiler.py
    └── explorerscript/explorerscript_reader.py
```

## 十一、已知潜伏问题（2026-06-29）

### codec 注册时序隐患

**症状**：如果 `string_codec.init()` 在 `load_custom_charset` 之前被调用，codec 会注册原版（空表）的函数引用。之后 override 模块的表被填充，但 codec 仍调用原版函数，导致 CJK 解码失败。

**触发条件**：有模块在 `main.py` 执行 charmap 加载之前 import 了 `skytemple_files.common.string_codec` 并调用了 `init()`。

**当前状态**：未触发。`main.py` 的 charmap 加载是启动链中最早触发该模块 import 的操作。

**修复方向**：`load_custom_charset` 完成后重置 `was_init = False` 并重新调用 `init()`，强制 codec 绑定到 override 模块的函数。

## 十二、远期想法

### 多人协作支持
- SkyTemple 支持 Git 插件管理 ROM 修改
- 脚本可导出为 ExplorerScript 文本，用 Git 做版本控制
- 多人各自编辑后合并
- 远期可探索：实时联网编辑（WebSocket 同步）

## 十三、发布计划

### 开源合规
- SkyTemple 使用 GPL v3，修改和再发布无需官方许可
- 义务：保留 LICENSE、公开源码、保留版权声明
- 建议：上传 GitHub Releases，含安装包 + 源码快照

### 通知上游（草稿）
> Hi Capypara and SkyTemple community,
> I have been working on a Chinese-localized build of SkyTemple 1.8.4 that adds full CJK text editing support...
> (见上面对话原文)

### 发布包结构
```
SkyTemple_CN/
├── SkyTemple_CN_Setup.exe
├── source/ (构建脚本 + 补丁源文件 + overrides)
├── charmap.txt
├── BUILD.md
└── LICENSE
```

## 十四、特别致谢

### SkyTemple 团队
感谢 SkyTemple 上游团队开发了这款优秀的 ROM 修改工具。

特别感谢 **Chesyon** 和 **Frostbyte0x70**：PR #844 "Fix most build actions" 修复了 Windows/Mac 构建流水线（2025-11-09 合入），我们的 CN 版能基于 gvsbuild 2026 成功构建，直接受益于这两位的工作。


