import json
import sys
from types import ModuleType

# (TEMP) path to the JSON configuration file containing module symbols
path_to_file = "../config/module_symbols.json"

# (TEMP) open the JSON configuration file in read mode
with open(path_to_file, "r") as file:
  try:
    # (TEMP) load JSON data from the file into a dictionary
    mod_dict = json.loads(file.read())
    # (TEMP) create a new module namespace using the loaded symbols
    ModuleSymbols = type("ModuleSymbol", (), mod_dict)
  except:
    # (TEMP) create an empty module namespace if JSON parsing fails
    ModuleSymbols = type("ModuleSymbols", (), {})

# (TEMP) create a new module object using the current __name__
module = ModuleType(__name__)
# (TEMP) assign the ModuleSymbols namespace to the module
module.ModuleSymbols = ModuleSymbols
# (TEMP) register the newly created module in the sys.modules dictionary
sys.modules[__name__] = module
