"""
------------------Prologue--------------------
File Name: finance_task_eval_functions.py
Path: kobrasuitecore/kobrasuitecore/task_config/finance_task_eval_functions.py

Date Created:
2025-03-16

Date Updated:
2025-03-16

Description:
Used for defining functions needed for evaluating a user's performance on a task.
Each function must be a static method.

Is used in the TaskMap to map tasks to their eval functions.

Input:
Each function should only take two arguments:
- frontend_data
    - assumed to either be a python dict or None
- db_data
    - assumed to either be a python dict or None

Both inputs could hold anything.

Output:
A single number indicating a user's performance on a task ranging from 0 to 1.0 (or higher for bonus performance)

Collaborators: JAKE BERNARD
---------------------------------------------
"""

class FinanceTaskEvalFunctions:
    @staticmethod
    # (TEMP) An example of an eval function for demonstration purposes
    def example_task_eval(frontend_data, db_data):
        # (TEMP) Retrieve the 'test_data' value from frontend_data
        test_frontend_data = frontend_data['test_data']
        # (TEMP) Retrieve the 'test_data' value from db_data
        test_db_data = db_data['test_data']
        # (TEMP) Set performance to the sum of test_frontend_data and test_db_data
        performance = test_frontend_data + test_db_data
        # (TEMP) Return the computed performance value
        return performance
