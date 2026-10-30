import os
import re

view_dir = r"c:\flutter practice\sg car rent app\frontend\lib\view"
files = [f for f in os.listdir(view_dir) if f.endswith('.dart')]

for f in sorted(files):
    with open(os.path.join(view_dir, f), 'r', encoding='utf-8') as fp:
        content = fp.read()
    imports = re.findall(r"import\s+['\"]([^'\"]+)['\"];", content)
    screen_imports = [i for i in imports if not i.startswith('package:')]
    print(f"{f}:")
    for imp in screen_imports:
        print(f"   {imp}")
