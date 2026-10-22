import os
import shutil
from pathlib import Path


generate_path = '../../core/generated'
if os.path.isdir(generate_path):
    shutil.rmtree(generate_path)
    

os.system("python3 generate_font_class.py")
os.system("python3 generate_color_classes.py")
os.system("python3 generate_sizes_classes.py")
