import subprocess
import re

out = subprocess.check_output(['powershell', '-Command', 'Get-CimInstance Win32_Process | Where-Object { $_.Name -like "*chrome*" } | Select-Object CommandLine | Format-Table -Wrap']).decode('utf-8', errors='ignore')
urls = re.findall(r'http://localhost:\d+', out)
print("Found Chrome URLs:", set(urls))
