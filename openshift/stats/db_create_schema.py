import importlib
import os
import sys
import pkgutil

from flask.cli import ScriptInfo

app_path = os.environ.get("FLASK_APP")
if not app_path:
    print("FLASK_APP is not set; cannot load app.", file=sys.stderr)
    sys.exit(1)

info = ScriptInfo(app_import_path=app_path)
app = info.load_app()

with app.app_context():
    try:
        import statsservice
        for _, modname, _ in pkgutil.walk_packages(statsservice.__path__, statsservice.__name__ + "."):
            try:
                importlib.import_module(modname)
            except Exception:
                pass
    except Exception:
        for mod in (
            "statsservice.models",
            "statsservice.model",
            "statsservice.api.v1",
            "statsservice.api",
        ):
            try:
                importlib.import_module(mod)
            except Exception:
                pass

    ext = app.extensions.get("sqlalchemy")
    db = None
    if ext is not None:
        db = ext if hasattr(ext, "create_all") else getattr(ext, "db", None)
    if db is None:
        for mod in ("statsservice.extensions", "statsservice.models", "statsservice"):
            try:
                candidate = importlib.import_module(mod)
                if hasattr(candidate, "db"):
                    db = candidate.db
                    break
            except Exception:
                pass

    if db is None or not hasattr(db, "create_all"):
        print("Could not resolve SQLAlchemy db instance.", file=sys.stderr)
        sys.exit(1)

    db.create_all()
    print("Schema created via SQLAlchemy create_all().")
