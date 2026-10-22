import os
import shutil
from pathlib import Path


# path list
icons_input_path = '../../plasma/packages/plasma-icons/src/scalable/'
icon_output_path = '../../resources/icons/'


def import_icons():
    # make dir
    Path(icon_output_path).mkdir(parents=True, exist_ok=True)
    
    scale_dirs = os.listdir(icons_input_path)
    for scale_dir in scale_dirs:
        source_dir_name = os.path.join(icons_input_path, scale_dir)
        if os.path.isdir(source_dir_name):
            scale = scale_dir.split('.')[-1]
            icons_dir = os.path.join(icon_output_path, scale)
            Path(icons_dir).mkdir(parents=True, exist_ok=True)
            
            # copy icons 
            src_files = os.listdir(source_dir_name)
            for file_name in src_files:
                full_source_name = os.path.join(source_dir_name, file_name)
                _, file_extension = os.path.splitext(full_source_name)
                if os.path.isfile(full_source_name) and file_extension == '.svg':
                    full_dst_name = os.path.join(icons_dir, file_name)
                    shutil.copy(full_source_name, full_dst_name)
                    
    shutil.copy('../../templates/index.theme', '../../resources/icons')
    print("Icons successfull imported to " + icon_output_path)

