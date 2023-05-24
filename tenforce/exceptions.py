class TypeEnforcementError(Exception):
    def __init__(self, class_name: str, var_name: str, requested_types: list[type], actual_type: type, obj: object):
        self.class_name = class_name
        self.var_name = var_name
        self.requested_types = requested_types
        self.actual_type = actual_type
        self.obj = obj

    def __str__(self):
        return f"'{self.class_name}.{self.var_name}' is type '{self.actual_type.__name__}' & accepts type(s) {[x.__name__ for x in self.requested_types]}. Value is: '{self.obj}'"


class AutoCastError(Exception):
    pass