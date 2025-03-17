import json
import sys
from types import ModuleType

path_to_file = "../../../config/module_symbols.json"

with open(path_to_file, "r") as file:
  try:
    mod_dict = json.loads(file.read())
    ModuleSymbols = type("ModuleSymbol", (), mod_dict)
  except:
    ModuleSymbols = type("ModuleSymbols", (), {})

module = ModuleType(__name__)
module.ModuleSymbols = ModuleSymbols
sys.modules[__name__] = module

