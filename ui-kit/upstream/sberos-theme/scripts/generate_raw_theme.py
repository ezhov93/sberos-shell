import os
import json
import sys
import re

colors_dir = '../theme/colors'
theme_file = '../theme/sdds_os.json'
output_file = '../theme/sdds_os_raw.json'


def collect_colors(colors_dir):
    result = {}
    for current_dir, _, files in os.walk(colors_dir):
        folder_name = os.path.basename(current_dir)
        for file in files:
            if file.endswith('.json'):
                file_name = os.path.splitext(file)[0]
                file_path = os.path.join(current_dir, file)
                with open(file_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                if isinstance(data, dict):
                    for key, value in data.items():
                        full_key = f"{folder_name}.{file_name}.{key}"
                        result[full_key] = value
    return result


def replace_tokens(data, replacements):
    if isinstance(data, dict):
        return {k: replace_tokens(v, replacements) for k, v in data.items()}
    elif isinstance(data, list):
        return [replace_tokens(item, replacements) for item in data]
    elif isinstance(data, str):
        def replace(match):
            key = match.group(1)
            return str(replacements.get(key, match.group(0)))
        return re.sub(r'\[(.*?)\]', replace, data)
    return data


def main():
    colors_dict = collect_colors(colors_dir)
    with open(theme_file, 'r') as f:
        target_data = json.load(f)
        
    raw_theme = replace_tokens(target_data, colors_dict)    
    with open(output_file, 'w') as f:
        json.dump(raw_theme, f, indent=4, ensure_ascii=False)
    

if __name__ == "__main__":
    main()
