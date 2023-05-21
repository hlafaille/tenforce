#cython: language_level=3
from types import NoneType
from tenforce.exceptions import ListValidationError

cdef type _parse_single(str single):
    """
    Parses a single type string
    :param single: 
    :return: 
    """
    if "list" in single:
        return list
    if "int" in single:
        return int
    if "str" in single:
        return str
    if "None" in single:
        return NoneType


cdef list[type] _parse_type_string(str type_string):
    """
    Parses a type string 
    :param type_string: 
    :return: list of Python types
    """
    cdef int x
    cdef list types = []

    # determine if this type string is a or union
    cdef list split_union_string
    if "|" in type_string:
        split_union_string = type_string.split("|")

        # iterate over the list of split union string
        for x in range(len(split_union_string)):
            types.append(_parse_single(split_union_string[x]))
        return types
    else:
        return [_parse_single(type_string)]

cdef _check_list(list l, list t):
    """
    Iterates over each element in l, checks that it is in the allowed types
    :param l: List of elements to be type checked
    :param t: What types should be allowed in l
    :return: 
    """
    cdef int x
    for x in range(len(l)):
        if type(l[x]) in t:
            raise ListValidationError(elem=x, actual_type=type(l[x]), allowed_types=t)

def check(object obj):
    """
    Checks & enforces the type hints on a Python object
    :param obj:
    :return:
    """
    # get the objects annotations
    cdef dict annotations = obj.__annotations__
    cdef dict obj_dict = obj.__dict__
    cdef str class_name = obj.__class__.__name__

    # iterate over the objects, ensure that they have the proper type
    cdef str var_name
    cdef list allowed_types
    cdef str allowed_types_names = ""
    cdef type current_type = None
    cdef str current_type_name = ""
    cdef int x

    for var_name in annotations.keys():
        allowed_types = _parse_type_string(str(annotations[var_name]))
        try:
            current_type = type(obj_dict[var_name])
        except KeyError:
            # check if the annotated class variable is supposed to be initialized and isn't
            if NoneType not in allowed_types and var_name not in obj_dict.keys():
                raise ValueError(f"Attribute '{var_name}' in class '{class_name}' must be initialized with '{allowed_types}'")
            current_type = NoneType

        # check if the annotated class variable is the proper type
        if current_type not in allowed_types:
            raise ValueError(f"Attribute '{var_name}' in class '{class_name}' has type '{current_type}', needs: '{allowed_types}'")
