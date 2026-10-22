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
sizes_template_path = templates_dir + 'json_interface_class'
aggregator_template_path = templates_dir + 'json_aggregator_class'

output_path = '../../theme/generated/'
sizes_output_path = output_path + 'sizes/'
interface_output_path = output_path + 'sizes'

default_theme_path = '../../../sberos-theme/theme/sizes_os.json'


def createStaticClasses(json_config, config_key):    
    config_name = upperfirst(config_key)
    
    replace_dict = {'class_name': config_name,
                    'class_file': convert_to_snake(config_name),
                    'member_type': 'int',
                    'member_name': list(),
                    'member_default_value': '0',
                    'json_name': list(),
                    'json_getter': '.toInt()'}
    for key in sorted(json_config[config_key].keys()):
        replace_dict['member_name'].append('_' + key if key.isdigit() else upperfirst(key))
        replace_dict['json_name'].append(key)         
    filename = output_path + convert_to_snake(config_name)
    generate_c_class(replace_dict, filename, sizes_template_path)
    return config_name
        

def createAggregatorClass(classes_list):
    replace_dict = {'class_name': 'Sizes',
                    'class_file': 'sizes',
                    'member_class': list(),
                    'member_name': list(),
                    'member_file': list(),
                    'json_name': list()}
    for class_name in sorted(classes_list):
        replace_dict['member_file'].append(convert_to_snake(class_name))
        replace_dict['member_class'].append(class_name)
        replace_dict['member_name'].append(class_name)
        replace_dict['json_name'].append(class_name)
    generate_c_class(replace_dict, interface_output_path, aggregator_template_path)
    print("Sizes interface successfull generated to " + interface_output_path)


with open(default_theme_path) as f:
    theme = json.load(f)
    classes_list = list()
    classes_list.append(createStaticClasses(theme, 'BorderRadius'))  
    classes_list.append(createStaticClasses(theme, 'LineHeight'))
    createAggregatorClass(classes_list)
        
