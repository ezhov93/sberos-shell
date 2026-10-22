import os
import shutil
import re
from pathlib import Path

parameter_pattern = re.compile(r'%\((?:(?P<value>\w+)|(?:\s*\,*\s*\[(?P<array>[\s\S]+?)\]))+\)')
camel_case_pattern = re.compile(r'(?<!^)(?=[A-Z])')

def upperfirst(text):
    return text[:1].upper() + text[1:]

def lowerfirst(text):
    return text[:1].lower() + text[1:]

def convert_to_snake(text):
    return camel_case_pattern.sub('_', text).lower()
    
def convert_to_camel(text):
    text = re.sub(r"(_|-)+", " ", text).title().replace(" ", "").replace("*","")
    return ''.join([text[0].upper(), text[1:]])
    
    
def generate_c_class(replace_dict, filename, template):
    generator_h = TextGenerator(open(template + '.h').read())
    generator_cpp = TextGenerator(open(template + '.cpp').read())
            
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with open(filename + '.h', 'w') as output:
        output.write(generator_h.generate(replace_dict))
    with open(filename + '.cpp', 'w') as output:
        output.write(generator_cpp.generate(replace_dict))


class TextGenerator:
    def __init__(self, template):
        self._template = template
        self._values = dict()
        self._arrays = dict()
        self._arrays_values = dict()
        self._create_parameters(template)
    
    def _create_parameters(self, template, inArray = False):
        values = dict()
        match_iter = parameter_pattern.finditer(template)
        for match in match_iter:
            match_dict = match.groupdict()
            if match_dict['array']:
                if inArray:
                    raise ValueError('Wrong template: array "{!r}" in other array'.format(match[0]))
                self._arrays[match[0]] = match_dict['array']
                self._arrays_values[match[0]] = self._create_parameters(match_dict['array'], True)
                if len(self._arrays_values[match[0]]) == 0:
                    raise ValueError('Wrong template: array "{!r}" has no values'.format(match[0]))
            elif match_dict['value']:
                if inArray:
                    values[match[0]] = match_dict['value']
                else:
                    self._values[match[0]] = match_dict['value']
        return values
      
    def _update_values(self, replacement_dict):
        for key, tag in self._values.items():
            if tag in replacement_dict:
                if isinstance(replacement_dict[tag], str):
                    self._values[key] = replacement_dict[tag]
                else:
                    raise ValueError('Wrong replacement dict: value with tag "{!r}" is not a string'.format(tag))
            else:
                raise ValueError('Wrong replacement dict: value with tag "{!r}" is undefined'.format(tag))
               
    def _replace_tags(self, template, replacement_dict):
        if not replacement_dict:
            return template
        replacement_dict[r'\n'] = '\n'
        replace_pattern = '|'.join(sorted(re.escape(item) for item in replacement_dict))
        return re.sub(replace_pattern, lambda m: replacement_dict[m.group(0)], template)
    
    def _update_arrays(self, replacement_dict):
        for arr_key, arr_template in self._arrays.items():
            length = -1
            for val_key, val_value in self._arrays_values[arr_key].items():
                if not val_value in replacement_dict:
                    raise ValueError('Wrong replacement dict: value with tag "{!r}" is empty'.format(val_value))
                if isinstance(replacement_dict[val_value], list):
                    if length == -1:
                        length = len(replacement_dict[val_value])
                    elif length != len(replacement_dict[val_value]):
                        raise ValueError('Wrong replacement dict: value with tag "{!r}" is not a string or list'.format(val_value))
                elif not isinstance(replacement_dict[val_value], str):
                    raise ValueError('Wrong replacement dict: value with tag "{!r}" is not a string or list'.format(val_value))

            arr_dict = dict()
            if length == -1: 
                length = 1
            for val_key, val_value in self._arrays_values[arr_key].items():
                if isinstance(replacement_dict[val_value], list):
                    arr_dict[val_key] = replacement_dict[val_value]
                else:
                    arr_dict[val_key] = [replacement_dict[val_value]] * length
                
            result_str = ""
            for i in range(length):
                step_dict = dict()
                for k, v in arr_dict.items():
                    step_dict[k] = v[i]
                result_str += self._replace_tags(arr_template, step_dict)
            self._arrays[arr_key] = result_str.rstrip()
           
           
    def get_parameters(self):
        return list(self._values.values()), [list(d.values()) for d in self._arrays_values.values()]
       
    def generate(self, replacement_dict):
        self._update_values(replacement_dict)
        self._update_arrays(replacement_dict)
        
        finile_dict = self._values.copy()
        finile_dict.update(self._arrays)
        return self._replace_tags(self._template, finile_dict)
   
