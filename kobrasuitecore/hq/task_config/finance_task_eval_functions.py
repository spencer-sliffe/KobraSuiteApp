class FinanceTaskEvalFunctions:
    @staticmethod
    def example_task_eval(frontend_data, db_data):
        test_frontend_data = frontend_data['test_data']
        test_db_data = db_data['test_data']
        performance = test_frontend_data + test_db_data
        return performance
