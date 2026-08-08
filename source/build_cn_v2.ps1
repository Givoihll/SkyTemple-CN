# SkyTemple CN Build Script v2
# Based on build_cn.ps1, official build + CN patches
$ErrorActionPreference = "Stop"
Set-Location "F:\Skytemple\skytemple-master\installer"

# === Config ===
$VENV = "F:\Skytemple\.venv_build"
$GTK_BIN = "F:\gtk-build\gtk\x64\release\bin"
$GTK_LIB = "F:\gtk-build\gtk\x64\release\lib"
$PYGOBJECT_WHL = (Resolve-Path "F:\gtk-build\build\x64\release\pygobject\dist\PyGObject*.whl").Path
$PYCAIRO_WHL = (Resolve-Path "F:\gtk-build\build\x64\release\pycairo\dist\pycairo*.whl").Path
$MSGFMT = "F:\gtk-build\gtk\x64\release\bin\msgfmt.exe"
$PY = "$VENV\Scripts\python.exe"

# === Step 1: Clean ===
Write-Host "=== Step 1: Clean ==="
Remove-Item build -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item dist -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "  Done"

# === Step 2: Download deps ===
Write-Host "=== Step 2: Download deps ==="
if (!(Test-Path "armips.exe")) { curl.exe -L -o armips.exe "https://skytemple.org/build_deps/armips.exe" }
if (!(Test-Path "SDL2.dll")) { curl.exe -L -o SDL2.dll "https://skytemple.org/build_deps/SDL2.dll" }
Write-Host "  Done"

# === Step 3: Install themes (from official extract) ===
Write-Host "=== Step 3: Install themes ==="
@("Arc","Arc-Dark","ZorinBlue-Light","ZorinBlue-Dark") | ForEach-Object {
    $src = "F:\Skytemple\official_deep\_internal\share\themes\$_"
    if (Test-Path $src) {
        Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue
        Copy-Item $src $_ -Recurse -Force
    }
}
Write-Host "  Done"

# === Step 4: Setup environment ===
Write-Host "=== Step 4: Setup environment ==="
$env:Path = "$GTK_BIN;$env:Path"
$env:LIB = $GTK_LIB

# Force reinstall GTK wheels to ensure correct versions
& $PY -m pip install --force-reinstall "$PYGOBJECT_WHL" 2>&1 | Out-Null
& $PY -m pip install --force-reinstall "$PYCAIRO_WHL" 2>&1 | Out-Null
Write-Host "  PyGObject + pycairo installed"

# Reinstall skytemple editable from clean source
Push-Location F:\Skytemple\skytemple-master
& $PY -m pip install -e ".[eventserver,discord]" --no-deps 2>&1 | Out-Null
& $PY -m pip install --force-reinstall "$PYGOBJECT_WHL" 2>&1 | Out-Null
& $PY -m pip install --force-reinstall "$PYCAIRO_WHL" 2>&1 | Out-Null
Pop-Location
Write-Host "  SkyTemple installed"

# Install PyInstaller
& $PY -m pip install 'pyinstaller~=6.0' 2>&1 | Out-Null
Write-Host "  PyInstaller installed"

# === Step 5: Verify ===
Write-Host "=== Step 5: Verify ==="
& $PY -c "import gi; gi.require_version('Gtk','3.0'); print('  GTK OK')"
& $PY -c "import skytemple; print('  skytemple OK')"
& $PY -c "import skytemple_files.common.string_codec; print('  codec OK')"
& $PY -c "import explorerscript; print('  explorerscript OK')"

# === Step 6: Compile localizations (PO -> MO) ===
Write-Host "=== Step 6: Compile locale ==="
$poDir = "F:\Skytemple\skytemple-master\skytemple\data\locale"
Get-ChildItem $poDir -Recurse -Filter "*.po" | ForEach-Object {
    $moPath = $_.FullName -replace '\.po$', '.mo'
    $moDir = Split-Path $moPath -Parent
    New-Item -ItemType Directory -Force -Path $moDir | Out-Null
    if ($_.FullName -match "zh_CN") { $tmpPo = "$env:TEMP\skytemple_dedup.po"; & "F:\gtk-build\gtk\x64\release\bin\msguniq.exe" --to-code=UTF-8 "--output-file=$tmpPo" $_.FullName; & $MSGFMT -o $moPath $tmpPo; Remove-Item $tmpPo -Force } else { & $MSGFMT -o $moPath $_.FullName }
}
Write-Host "  Done"

# === Step 7: PyInstaller ===
Write-Host "=== Step 7: PyInstaller ==="
$env:Path = "$GTK_BIN;$env:Path"
$env:LIB = $GTK_LIB
& $PY -m PyInstaller --log-level=WARN --noconfirm skytemple.spec
if (!(Test-Path "dist\skytemple\skytemple.exe")) { throw "PyInstaller failed" }
Write-Host "  Done"

# === Step 7.5: CN additions (overrides + charmap) ===
Write-Host "=== Step 7.5: CN additions ==="
$cn_int = "dist\skytemple\_internal"
$cn_ovr = "F:\Skytemple\overrides"
New-Item -ItemType Directory -Force -Path "$cn_int\skytemple_files\common" | Out-Null
Copy-Item "$cn_ovr\skytemple_files\common\string_codec.py" "$cn_int\skytemple_files\common\" -Force
New-Item -ItemType Directory -Force -Path "$cn_int\skytemple_files\script\ssb" | Out-Null
Copy-Item "$cn_ovr\skytemple_files\script\ssb\script_compiler.py" "$cn_int\skytemple_files\script\ssb\" -Force
New-Item -ItemType Directory -Force -Path "$cn_int\explorerscript" | Out-Null
Copy-Item "$cn_ovr\explorerscript\explorerscript_reader.py" "$cn_int\explorerscript\" -Force
Copy-Item "F:\project53\charmap.txt" "$cn_int\" -Force
Write-Host "  3 overrides + charmap installed"

# === Step 8: Replace enchant (trim MSYS2 bloat) ===
Write-Host "=== Step 8: Enchant ==="
$OFF_ENCHANT = "F:\Skytemple\official_deep\_internal\enchant"
$INTERNAL = "dist\skytemple\_internal"
if (Test-Path $OFF_ENCHANT) {
    Remove-Item "$INTERNAL\enchant" -Recurse -Force -ErrorAction SilentlyContinue
    Copy-Item $OFF_ENCHANT "$INTERNAL\enchant" -Recurse -Force
    Write-Host "  enchant replaced"
}

# === Step 9: Generate NSIS file lists ===
Write-Host "=== Step 9: NSIS file lists ==="
& $PY gen_list_files_for_nsis.py "dist\skytemple" "install_files.nsh" "uninstall_files.nsh"
Write-Host "  Done"

# === Step 10: NSIS ===
Write-Host "=== Step 10: NSIS ==="
& "C:\Program Files (x86)\NSIS\makensis.exe" .\skytemple_cn.nsi

$SETUP = "F:\Skytemple\SkyTemple_CN_Setup.exe"
if (Test-Path $SETUP) {
    $sz = [math]::Round((Get-Item $SETUP).Length / 1MB, 0)
    Write-Host "=== BUILD SUCCESS: $sz MB ==="
} else {
    # The NSIS output name might be different
    $out = Get-ChildItem "F:\Skytemple\skytemple-master\installer" -Filter "*.exe" | Where-Object { $_.Name -ne "armips.exe" -and $_.Name -ne "skytemple.exe" }
    if ($out) { Write-Host "Output: $($out.FullName)" }
    else { Write-Host "=== NSIS FAILED ===" }
}


