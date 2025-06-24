import json
import sys
from types import ModuleType
from hq.task_config.module_symbols import ModuleSymbols as ms

from hq.task_config.finance_task_eval_functions import FinanceTaskEvalFunctions
from hq.task_config.homelife_task_eval_functions import HomelifeTaskEvalFunctions
from hq.task_config.school_task_eval_functions import SchoolTaskEvalFunctions
from hq.task_config.work_task_eval_functions import WorkTaskEvalFunctions

# (TEMP) map module symbols to classes containing the evaluation functions for each module
module_function_map = {
    ms.finance: FinanceTaskEvalFunctions,
    ms.homelife: HomelifeTaskEvalFunctions,
    ms.school: SchoolTaskEvalFunctions,
    ms.work: WorkTaskEvalFunctions
}

# Class to allow for a strong(er) typed representation of task config
class TaskCategoryConfig:
    def __init__(self, category_id, task_config):
        # (TEMP) set category ID from input parameter
        self.category_id = category_id
        # (TEMP) extract task name from configuration
        self.name = task_config['name']
        # (TEMP) extract slot limit value from configuration
        self.slot_limit = task_config['slot_limit']
        # (TEMP) extract completion limit value from configuration
        self.completion_limit = task_config['completion_limit']
        # (TEMP) extract renewal period value from configuration
        self.renewal_period = task_config['renewal_period']
        # (TEMP) extract evaluation function reference from configuration
        self.eval_func = task_config['eval_func']

path_to_file = "../config/task_config.json"  # (TEMP) path to the task configuration JSON file

with open(path_to_file, "r") as file:
  try:
    # (TEMP) load JSON data from file into task_dict
    task_dict = json.loads(file.read())
  except:
    # (TEMP) default empty dictionary if parsing fails
    task_dict = {}

modified_task_dict = {}  # (TEMP) initialize container for processed task configurations
for module in task_dict.keys():
    module_task_arr = []  # (TEMP) initialize list to hold module-specific task configs
    # (TEMP) create default configuration for login task
    login_task_config = {
        "name"            : "login",
        "slot_limit"      : 0,
        "completion_limit": 1,
        "renewal_period"  : 1,
        "eval_func"       : None
    }
    # (TEMP) instantiate login task configuration object
    login_task = TaskCategoryConfig(0, login_task_config)
    # (TEMP) add login task to module's task list
    module_task_arr.append(login_task)
    task_num = 0  # (TEMP) initialize task counter
    module_symbol = ms.__dict__[module]
    for task in task_dict[module]:
        # (TEMP) increment task number counter
        task_num = task_num + 1
        # (TEMP) create new task configuration object
        task_cfg = TaskCategoryConfig(task_num, task)
        if task_cfg.eval_func:
            # (TEMP) resolve evaluation function reference to actual function
            task_cfg.eval_func = (
                module_function_map[module_symbol].__dict__
            )[task_cfg.eval_func]
        # (TEMP) add configured task to module's list
        module_task_arr.append(task_cfg)
    # (TEMP) map module name to its processed task configurations
    modified_task_dict[module_symbol] = module_task_arr

# (TEMP) dynamically create new module object
module = ModuleType(__name__)
# (TEMP) attach TaskMap attribute to new module
module.TaskMap = modified_task_dict
# (TEMP) replace current module with dynamically created one
sys.modules[__name__] = module
