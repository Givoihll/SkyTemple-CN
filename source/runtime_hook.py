# SkyTemple CN runtime hook
import sys, os, _frozen_importlib, time

_MEIPASS = sys._MEIPASS

_OVERRIDE_MODULES = frozenset([
    "skytemple_files.common.string_codec",
    "explorerscript.explorerscript_reader",
    "skytemple_files.script.ssb.script_compiler",
])

# Timing: write to _internal/perf.log
def _perf(msg):
    try:
        with open(os.path.join(_MEIPASS, "perf.log"), "a") as f:
            f.write(f"{time.time():.3f} {msg}\n")
    except: pass

_perf("hook_start")

class _OverrideSourceLoader:
    def __init__(self, fullname, filepath):
        self.name = fullname
        self.path = filepath
    def create_module(self, spec):
        return None
    def exec_module(self, module):
        t0 = time.time()
        with open(self.path, "rb") as f:
            source = f.read()
        code = compile(source, self.path, "exec")
        exec(code, module.__dict__)
        _perf(f"exec_module {self.name} took {time.time()-t0:.4f}s")
    def get_filename(self, fullname):
        return self.path
    def get_source(self, fullname):
        with open(self.path, "r", encoding="utf-8") as f:
            return f.read()
    def get_code(self, fullname):
        with open(self.path, "rb") as f:
            source = f.read()
        return compile(source, self.path, "exec")
    def is_package(self, fullname):
        return False

class _OverrideFinder:
    __slots__ = ()
    def find_spec(self, fullname, path=None, target=None):
        t0 = time.time()
        if fullname not in _OVERRIDE_MODULES:
            dt = time.time() - t0
            if dt > 0.001:
                _perf(f"SLOW find_spec skip {fullname}: {dt:.4f}s")
            return None
        rel = fullname.replace(".", os.sep) + ".py"
        fpath = os.path.join(_MEIPASS, rel)
        if not os.path.isfile(fpath):
            return None
        loader = _OverrideSourceLoader(fullname, fpath)
        spec = _frozen_importlib.ModuleSpec(fullname, loader, origin=fpath)
        spec.has_location = True
        _perf(f"find_spec HIT {fullname} at {time.time()-t0:.4f}s")
        return spec

# Insert after FrozenImporter, before PathFinder, to minimize overhead
for i, f in enumerate(sys.meta_path):
    if 'PathFinder' in type(f).__name__:
        sys.meta_path.insert(i, _OverrideFinder())
        break
else:
    sys.meta_path.insert(0, _OverrideFinder())
_perf("hook_end")