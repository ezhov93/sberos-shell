import os
import shutil
import json
import re
import subprocess
from pathlib import Path
from fontTools.ttLib import woff2


# path list
fonts_styles_path = '../../theme_convertor/android/android_typography.json'
fonts_resources_path = '../../resources/fonts/'
fonts_tokens_output_path = '../../design_tokens/'


def import_fonts():
    # make dir
    Path(fonts_tokens_output_path).mkdir(parents=True, exist_ok=True)
    
    # parce and write font styles
    with open(fonts_styles_path) as f:
        config = json.load(f)
        styles_dict = dict()
        for key in config.keys():
            json_path = key.split('.')
            if len(json_path) == 4:
                group = json_path[0]
                if group != 'screen-l':
                    continue
                font = json_path[1] + json_path[2].title() + (json_path[3][0].title() if json_path[3][0] != 'n' else '')
                styles_dict[font] = config[key]
                styles_dict[font]['fontFamily'] = styles_dict[font]['fontFamilyRef'].split('.')[1]
        with open(fonts_tokens_output_path + 'font_styles.json', mode='w') as outfile:
            outfile.write(json.dumps(styles_dict, indent=4))
        print("Font styles successfull imported to " + fonts_tokens_output_path)
    
