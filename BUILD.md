# SkyTemple CN Build Guide

## 环境要求

- Windows 10/11 x64
- Python 3.11.9
- gvsbuild 2026（GTK 3.24.52）
- NSIS 3.x 位于 `C:\Program Files (x86)\NSIS`
- 官方 SkyTemple 1.8.4 源码（`skytemple-master/`）
- 中文字符映射表（`charmap.txt`）

## 构建步骤

### 1. 准备源码

从官方仓库克隆 SkyTemple 1.8.4，将本目录下的文件放入对应位置：

```
skytemple-master/
├── skytemple/
│   ├── main.py                  ← 用本目录 main.py 替换
│   └── controller/settings.py   ← 用本目录 settings.py 替换
└── installer/
    ├── runtime_hook.py
    ├── skytemple.spec           ← 用本目录 skytemple.spec 替换
    └── skytemple_cn.nsi
```

将 `overrides/` 目录复制到 `F:\Skytemple\overrides\`。

### 2. 准备依赖

```powershell
python -m venv F:\Skytemple\.venv_build
F:\Skytemple\.venv_build\Scripts\pip install -r skytemple-master\requirements-frozen.txt
F:\Skytemple\.venv_build\Scripts\pip install -e "F:\Skytemple\skytemple-master[eventserver,discord]" --no-deps
```

安装 gvsbuild 2026 编译的 PyGObject 和 pycairo wheel：

```powershell
F:\Skytemple\.venv_build\Scripts\pip install --force-reinstall F:\gtk-build\build\x64\release\pygobject\dist\PyGObject*.whl
F:\Skytemple\.venv_build\Scripts\pip install --force-reinstall F:\gtk-build\build\x64\release\pycairo\dist\pycairo*.whl
```

### 3. 编译翻译

先将 `skytemple.po` 放到 `skytemple-master\skytemple\data\locale\zh_CN\LC_MESSAGES\`，替换官方自带的简体中文 PO（官方版翻译不完整）。

然后使用 gvsbuild 自带的 msgfmt 编译各语言 PO → MO：

```powershell
# 所有语言（zh_CN 除外）
msgfmt -o output.mo input.po

# zh_CN 特殊处理：官方 PO 含重复 msgid，必须先去重
msguniq --to-code=UTF-8 --output-file=dedup.po input.po
msgfmt -o output.mo dedup.po
```

`skytemple.po` 已包含 13,000+ 条中文翻译。

### 4. 打包

```powershell
F:\Skytemple\.venv_build\Scripts\pyinstaller --log-level=WARN --noconfirm skytemple.spec
```

将以下文件放入 `dist\skytemple\_internal\`：

```
_internal/
├── skytemple_files/common/string_codec.py      ← 来自 overrides/
├── skytemple_files/script/ssb/script_compiler.py ← 来自 overrides/
├── explorerscript/explorerscript_reader.py     ← 来自 overrides/
└── charmap.txt
```

`runtime_hook.py` 已通过 `skytemple.spec` 内嵌，启动时自动拦截上述三个模块的导入。

### 5. 生成安装器

```powershell
python gen_list_files_for_nsis.py dist\skytemple install_files.nsh uninstall_files.nsh
"C:\Program Files (x86)\NSIS\makensis.exe" skytemple_cn.nsi
```

输出：`SkyTemple_CN_Setup.exe`

## 中文编辑原理

SkyTemple 使用 PMD2 自定义字符编码（`pmd2str`）。本补丁通过 `charmap.txt` 加载 7,251 个 CJK 字符映射，使脚本编辑器（S.E.D.）和文本字符串模块（text_e.str）都能直接编辑中文。

运行时通过 `runtime_hook.py` 在 `sys.meta_path` 中拦截三个模块的导入，加载 `_internal\` 中的补丁版本，不修改 PyPI 安装包。

## 许可证

GPL v3。本补丁基于 [SkyTemple](https://github.com/SkyTemple/skytemple) 修改。

