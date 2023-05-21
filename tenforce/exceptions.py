class ListValidationError(Exception):
    def __init__(self, elem: int, actual_type: type, allowed_types: list):
        self.elem = elem
        self.actual_type = actual_type
        self.allowed_types = allowed_types
