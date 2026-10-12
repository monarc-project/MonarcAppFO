import importlib
import os
import pkgutil
import sys

from flask.cli import ScriptInfo

base_app = os.environ.get("STATS_BASE_APP") or "app"

info = ScriptInfo(app_import_path=base_app)
app = info.load_app()

try:
    import statsservice
    for _, modname, _ in pkgutil.walk_packages(statsservice.__path__, statsservice.__name__ + "."):
        try:
            importlib.import_module(modname)
        except Exception:
            pass
except Exception:
    pass

@app.get("/health")
def health():
    return {"status": "ok"}
