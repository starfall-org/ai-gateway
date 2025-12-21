import os
import re
from pathlib import Path

ROOT = Path("lib")
TRANSLATE = Path("lib/core/translate.dart")

# Patterns to wrap Text('literal') or Text("literal") with tl(...)
# Also handle const Text(...) and with/without trailing arguments.
TEXT_PATTERNS = [
    # const Text('...') end
    (re.compile(r"\bconst\s+Text\(\s*(?!tl\()'((?:[^'\\]|\\.)*)'\s*\)"), r"Text(tl('\1'))"),
    # const Text('...'), more args
    (re.compile(r"\bconst\s+Text\(\s*(?!tl\()'((?:[^'\\]|\\.)*)'\s*,"), r"Text(tl('\1'),"),
    # const Text("...") end
    (re.compile(r'\bconst\s+Text\(\s*(?!tl\()\"((?:[^"\\]|\\.)*)\"\s*\)'), r'Text(tl("\1"))'),
    # const Text("..."), more args
    (re.compile(r'\bconst\s+Text\(\s*(?!tl\()\"((?:[^"\\]|\\.)*)\"\s*,'), r'Text(tl("\1"),'),

    # Text('...') end
    (re.compile(r"\bText\(\s*(?!tl\()'((?:[^'\\]|\\.)*)'\s*\)"), r"Text(tl('\1'))"),
    # Text('...'), more args
    (re.compile(r"\bText\(\s*(?!tl\()'((?:[^'\\]|\\.)*)'\s*,"), r"Text(tl('\1'),"),
    # Text("...") end
    (re.compile(r'\bText\(\s*(?!tl\()\"((?:[^"\\]|\\.)*)\"\s*\)'), r'Text(tl("\1"))'),
    # Text("..."), more args
    (re.compile(r'\bText\(\s*(?!tl\()\"((?:[^"\\]|\\.)*)\"\s*,'), r'Text(tl("\1"),'),
]

# Widgets that often need to drop "const" when containing non-const children like tl()
DROP_CONST_ON = re.compile(
    r"\bconst\s+(Center|AppBar|PopupMenuItem|SnackBar|AlertDialog|ListTile|SwitchListTile|CheckboxListTile|ElevatedButton|TextButton|OutlinedButton)\s*\("
)

IMPORT_RE = re.compile(r"^import\s+['\"]([^'\"]+)['\"];\s*$", re.M)
TRANSLATE_IMPORT_ANY = re.compile(r"^import\s+['\"][^'\"]*translate\.dart['\"];\s*$", re.M)

def ensure_import(src: str, file_path: Path) -> str:
    # Only add import if tl() is used
    if "tl(" not in src:
        return src
    # Already has import to translate.dart (package or relative)
    if TRANSLATE_IMPORT_ANY.search(src):
        return src
    # Prefer relative import to satisfy prefer_relative_imports
    rel = os.path.relpath(TRANSLATE.as_posix(), start=file_path.parent.as_posix()).replace("\\", "/")
    import_line = f"import '{rel}';\n"
    imports = list(IMPORT_RE.finditer(src))
    if imports:
        insert_at = imports[-1].end()
        return src[:insert_at] + import_line + src[insert_at:]
    else:
        return import_line + src

def process_file(p: Path) -> bool:
    src = p.read_text(encoding="utf-8")
    new = src

    # Step 1: wrap Text(...) literals with tl()
    for rgx, repl in TEXT_PATTERNS:
        new = rgx.sub(repl, new)

    # Step 2: if tl() present, drop const on common parent widgets
    if "tl(" in new:
        new = DROP_CONST_ON.sub(lambda m: f"{m.group(1)}(", new)

    # Step 3: ensure relative import to translate.dart when tl() present
    new = ensure_import(new, p)

    if new != src:
        p.write_text(new, encoding="utf-8")
        return True
    return False

def main():
    changed_files = []
    for p in ROOT.rglob("*.dart"):
        # Skip the translate.dart itself
        if p.as_posix() == TRANSLATE.as_posix():
            continue
        try:
            if process_file(p):
                changed_files.append(p.as_posix())
        except Exception as e:
            print(f"Error processing {p}: {e}")

    print(f"Updated {len(changed_files)} files:")
    for f in changed_files:
        print(f)

if __name__ == "__main__":
    main()