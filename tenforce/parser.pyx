cpdef type parse_type_string(str type_string):
    """
    Parses a type string (ex: `<class 'str'>`) into its actual Python type
    :param type_string: 
    :return: 
    """
    if "class" not in type_string:
        raise ValueError(f"Invalid type string '{type_string}'")

    # todo finish list parsing
    if "list" in type_string:
        return list

    # normal python types11
    elif "str" in type_string:
        return str
    elif "int" in type_string:
        return int
    elif "bool" in type_string:
        return bool
