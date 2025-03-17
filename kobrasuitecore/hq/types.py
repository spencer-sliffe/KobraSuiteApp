from django.db import models
from ..kobrasuitecore.task_config.module_symbols import ModuleSymbols

class ModuleType(models.TextChoices):
    SCHOOL = ModuleSymbols.school, 'School'
    WORK = ModuleSymbols.work, 'Work'
    HOMELIFE = ModuleSymbols.homelife, 'HomeLife'
    FINANCE = ModuleSymbols.finance, 'Finance'