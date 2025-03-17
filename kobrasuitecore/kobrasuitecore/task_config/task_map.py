import json
import sys
from types import ModuleType
from module_symbols import ModuleSymbols as ms

from finance_task_eval_functions import FinanceTaskEvalFunctions
from homelife_task_eval_functions import HomelifeTaskEvalFunctions
from school_task_eval_functions import SchoolTaskEvalFunctions
from work_task_eval_functions import WorkTaskEvalFunctions

module_function_map = {
    ms.finance: FinanceTaskEvalFunctions,
    ms.homelife: HomelifeTaskEvalFunctions,
    ms.school: SchoolTaskEvalFunctions,
    ms.work: WorkTaskEvalFunctions
}

# TODO: (JAKE) Implement this stuff on the frontend

class TaskCategoryConfig:
    def __init__(self, category_id, task_config):
        self.category_id = category_id
        self.name = task_config['name']
        self.slot_limit = task_config['slot_limit']
        self.completion_limit = task_config['completion_limit']
        self.renewal_period = task_config['renewal_period']
        self.eval_func = task_config['eval_func']

path_to_file = "../../../config/task_config.json"

with open(path_to_file, "r") as file:
  try:
    task_dict = json.loads(file.read())
  except:
    task_dict = {}

modified_task_dict = {}
for module in task_dict.keys():
    module_task_arr = []
    login_task_config = {
        "name"            : "login",
        "slot_limit"      : 0,
        "completion_limit": 1,
        "renewal_period"  : 1,
        "eval_func"       : None
    }
    login_task = TaskCategoryConfig(0, login_task_config)
    module_task_arr.append(login_task)
    task_num = 0
    for task in task_dict[module]:
        task_num = task_num + 1
        task_cfg = TaskCategoryConfig(task_num, task)
        if task_cfg.eval_func:
            task_cfg.eval_func = (
                module_function_map[module].__dict__
            )[task_cfg.eval_func]
        module_task_arr.append(task_cfg)
    modified_task_dict[module] = module_task_arr


module = ModuleType(__name__)
module.TaskMap = modified_task_dict
sys.modules[__name__] = module

