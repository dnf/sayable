"""Generated-file banner and locale source comment helpers.

Re-exported from .hecatron/tools/codegen/util.py (canonical location),
with locale_source_comment overridden for sayable-duration paths.
"""

import importlib.util as _ilu
import os as _os

_path = _os.path.join(
    _os.path.dirname(_os.path.dirname(_os.path.dirname(_os.path.abspath(__file__)))),
    ".hecatron", "tools", "codegen", "util.py",
)
_spec = _ilu.spec_from_file_location("_banner_impl", _path)
_mod = _ilu.module_from_spec(_spec)
_spec.loader.exec_module(_mod)

make_banner = _mod.make_banner
make_header = _mod.make_header


def locale_source_comment(locale_code: str, line_prefix: str = "// ", line_suffix: str = "") -> str:
    """Return a single-line source comment for a sayable-duration locale file."""
    return f"{line_prefix}Source: duration/locales/src/{locale_code}.json{line_suffix}\n"
