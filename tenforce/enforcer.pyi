def check(obj: object, auto_cast: bool = False) -> None:
    """
    Checks the class variables of an object & enforces its type hints
    :param obj: Instance of a class
    :param auto_cast: Optional, automatically cast things like numeric strings to ints (if the annotation allows)
    :return: None
    """
    ...