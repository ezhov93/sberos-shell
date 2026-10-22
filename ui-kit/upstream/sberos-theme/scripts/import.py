import os
import shutil

from import_icons import import_icons
from import_fonts import import_fonts 
from import_colors import import_colors 
from import_sizes import import_sizes


resources_output_path = '../../resources'
if os.path.isdir(resources_output_path):
    shutil.rmtree(resources_output_path)

    
import_icons()
#import_colors()
import_fonts()
import_sizes()

