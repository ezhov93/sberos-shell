import os
import shutil
import json
import re
from pathlib import Path
from text_generator import generate_c_class
from text_generator import upperfirst

template_path = 'templates/base_interface_class'
output_path = '../../theme/generated/fonts_base'

font_styles_path = '../../../sberos-theme/theme/font_styles.json'


with open(font_styles_path) as fonts_file:
    font_list = sorted(list(json.load(fonts_file).keys()))
    font_names_list = font_list.copy()
    for i in range(len(font_names_list)):
        font_names_list[i] = upperfirst(font_names_list[i])
    replace_dict = {'class_name' : 'Fonts',
                    'class_file' : 'fonts_base',
                    'member_type': 'QFont',
                    'member_default_value': 'QFont()',
                    'getter_name': 'Font',
                    'member_name': font_names_list,
                    'json_name' : font_list}
    generate_c_class(replace_dict, output_path, template_path)
    print("Font class successfull generated to " + output_path)
        
