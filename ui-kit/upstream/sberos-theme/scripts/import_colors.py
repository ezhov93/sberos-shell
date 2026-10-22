import os
import shutil
import json
import re
from pathlib import Path


# path list
colors_tokens_path = '../../plasma/packages/plasma-colors/palette'
general_colors_input_path = colors_tokens_path + '/general.json'
additional_colors_input_path = colors_tokens_path + '/additional.json'

theme_input_path = '../../theme_convertor/android/android_color.json'
gradients_input_path = '../../theme_convertor/android/android_gradient.json'
theme_output_path = '../../design_tokens/sdds_os.json'
colors_output_path = '../../design_tokens/colors/'


def convert_to_camel(text):
    text = re.sub(r"(_|-)+", " ", text).title().replace(" ", "").replace("*","")
    return ''.join([text[0].upper(), text[1:]])
    
def set_value(d, keys, value):
    key = convert_to_camel(keys[0])
    if key not in d.keys():
        if len(keys) == 1:
            d[key] = value
        else:
            d[key] = set_value({}, keys[1:], value)
    else:
        d[key] = set_value(d[key], keys[1:], value)
    return d

def import_colors_config(config, folder):
    with open(config) as f:
        config = json.load(f)
        for color_name in config.keys():
            filename = colors_output_path + folder + '/' + color_name + '.json'
            os.makedirs(os.path.dirname(filename), exist_ok=True)
            with open(filename, mode='w') as outfile:
                outfile.write(json.dumps(config[color_name], indent=4))
        
# copy colors/theme config
def import_colors():
    # make dir
    Path(colors_output_path).mkdir(parents=True, exist_ok=True)

    # Colors
    import_colors_config(general_colors_input_path, 'general')
    import_colors_config(additional_colors_input_path, 'additional')
    print("Colors successfull imported to " + colors_output_path)
        
    # Theme    
    with open(theme_input_path) as f:
        theme_file = json.load(f)
        theme_json = {'Config': {'Name': 'sdds_os'}}
    
        for key in theme_file.keys():
            groups = key.split('.')
            theme_json = set_value(theme_json, groups, theme_file[key])
        
        with open(gradients_input_path) as fg:
            gradients_file = json.load(fg)
            for key in gradients_file.keys():
                groups = key.split('.')
                theme_json = set_value(theme_json, groups, json.dumps(gradients_file[key][0], indent=0).replace('\n', ''))
            
        with open(theme_output_path, mode='w') as outfile:
            outfile.write(json.dumps(theme_json, indent=4))          
            
    print("Themes successfull imported to " + theme_output_path)
            
