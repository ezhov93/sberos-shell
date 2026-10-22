import os
import shutil
import json
import re
from pathlib import Path
from text_generator import generate_c_class
from text_generator import upperfirst
from text_generator import lowerfirst
from text_generator import convert_to_snake


templates_dir = 'templates/'
color_template_path = templates_dir + 'json_interface_class'
color_group_template_path = templates_dir + 'json_aggregator_class'

output_path = '../../theme/generated/'
colors_output_path = output_path + 'colors/'
palette_output_path = output_path + 'palette'

tokens_path = '../../../sberos-theme/theme/'
colors_path = tokens_path + 'colors/'
default_theme_path = tokens_path + 'sdds_os.json'


def create_static_classes(folders):
    colors_list = list()
    
    for folder in folders:
        # Raw colors
        raw_color_list = list()
        color_files = Path(colors_path + '/' + folder).glob('**/*.json')
        for color_file_path in color_files:
            color_name = upperfirst(Path(color_file_path).stem)
            raw_color_list.append(color_name)
            with open(color_file_path) as color_file:
                colors = json.load(color_file)
                replace_dict = {'class_name': color_name,
                                'class_file': convert_to_snake(color_name),
                                'member_type': 'QString',
                                'member_name': list(),
                                'member_default_value': '""',
                                'json_name': list(),    
                                'json_getter': '.toString()'}
                for key in sorted(colors.keys(), key=lambda item: (len(item), item)):
                    replace_dict['member_name'].append('_' + key if key.isdigit() else upperfirst(key))
                    replace_dict['json_name'].append(key)
                generate_c_class(replace_dict,
                                 colors_output_path + folder + '/' + convert_to_snake(color_name), 
                                 color_template_path)
                
        # group colors
        replace_dict = {'class_name': upperfirst(folder),
                        'class_file': convert_to_snake(folder),
                        'member_class': list(),
                        'member_name': list(),
                        'member_file': list(),
                        'json_name': list()}
        for color in sorted(raw_color_list):
            replace_dict['member_class'].append(upperfirst(color))
            replace_dict['member_name'].append(upperfirst(color.replace('Os', '')))
            replace_dict['member_file'].append(convert_to_snake(color))
            replace_dict['json_name'].append(lowerfirst(color))
        generate_c_class(replace_dict,
                         colors_output_path + '/' + convert_to_snake(folder),
                         color_group_template_path)
        colors_list.append(folder)

    # Theme color groups      
    with open(default_theme_path) as theme_file:
        theme_json = json.load(theme_file)
        theme_json = theme_json['Dark']
        for group in theme_json.keys():
            colors_list.append(group)
            group_replace_dict = {'class_name': upperfirst(group),
                                  'class_file': convert_to_snake(group),
                                  'member_class': list(),
                                  'member_name': list(),
                                  'member_file': list(),
                                  'json_name': list()}
            for subgroup in sorted(theme_json[group].keys()):
                class_name = upperfirst(group) + upperfirst(subgroup)
                member_name = upperfirst(subgroup)
                group_replace_dict['member_class'].append(class_name)
                group_replace_dict['member_name'].append(member_name)
                group_replace_dict['member_file'].append(convert_to_snake(class_name))
                group_replace_dict['json_name'].append(subgroup)
            
                subgroup_replace_dict = {'class_name': class_name,
                                         'class_file': convert_to_snake(class_name),
                                         'member_type': 'QString',
                                         'member_name': list(),
                                         'member_default_value': '""',
                                         'json_name': list(),
                                         'json_getter': '.toString()'}
                for key in sorted(theme_json[group][subgroup].keys()):
                    key_name = key.replace(group, '')
                    subgroup_replace_dict['member_name'].append(upperfirst(key_name))
                    subgroup_replace_dict['json_name'].append(key)
                generate_c_class(subgroup_replace_dict,
                                 colors_output_path + '/' + convert_to_snake(class_name), 
                                 color_template_path)
            generate_c_class(group_replace_dict, 
                             colors_output_path + '/' + convert_to_snake(group), 
                             color_group_template_path)
    return colors_list
        

def create_palette(colors_list):
    replace_dict = {'class_name': 'Palette',
                    'class_file': 'palette',
                    'member_class': list(),
                    'member_name': list(),
                    'member_file': list(),
                    'json_name': list()}
    for color in sorted(colors_list):
        replace_dict['member_class'].append(upperfirst(color))
        replace_dict['member_name'].append(upperfirst(color))
        replace_dict['member_file'].append(convert_to_snake(color))
        replace_dict['json_name'].append(color)
    generate_c_class(replace_dict, 
                     palette_output_path, 
                     color_group_template_path)
    print("Palette class successfull generated to " + output_path)


palette_members = create_static_classes(os.listdir(colors_path))
create_palette(palette_members)

print("Color classes successfull generated to " + colors_output_path)
