import os
import shutil
import json
from pathlib import Path


# path list
theme_input_path = '../../design_tokens/sdds_os.json'


def import_sizes():    
    with open(theme_input_path, 'r+') as f:
        theme = json.load(f)
        f.seek(0)
            
        # sizes
        if 'borderRadius' not in theme.keys():
            theme['BorderRadius'] = {
               "xxs": 4,
               "xs": 6,
               "s": 8,
               "m": 12,
               "l": 16,
               "xl": 20,
               "xxl": 40
           }
                
        theme['LineHeight'] = {
            "xxs": 24,
            "xs": 32,
            "s": 40,
            "m": 48,
            "l": 56
        }
        f.write(json.dumps(theme, indent=4)) 
        f.truncate()
    print("Sizes successfull imported to themes/sdds_os.json")
