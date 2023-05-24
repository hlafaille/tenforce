from tenforce.exceptions import AutoCastError

cpdef object auto_cast_object(object obj, type annotation):
    """
    Cast an object to its annotated type
    :param obj: Object to cast
    :param annotation: Type annotation
    :raise AutoCastError: if it was impossible to cast obj to its type annotation
    :return: Casted object
    """
    # if the value provided is a numeric string, try and cast it to an int
    if type(obj) is str and annotation is int and obj.isnumeric():
        obj = int(obj)

    # if the value provided is an int and the annotation requires a float, try and cast it to a float
    if type(obj) is int and annotation is float:
        obj = float(obj)

    # if we couldn't cast obj
    if type(obj) is not annotation:
        raise AutoCastError(f"{obj} failed to cast to {annotation}")

    return obj