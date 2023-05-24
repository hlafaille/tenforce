import typing

from tenforce.lib.autocast import auto_cast_object

cpdef ParsedListMember parse_generic_alias_member(str class_name, str member_name, object generic_alias, object obj, bint auto_cast = False):
    """
    Parses a member of a class that has a GenericAlias type annotation (ex: list[str])
    :param class_name: 
    :param member_name: 
    :param obj: 
    :param generic_alias: GenericAlias instance
    :param auto_cast: 
    :return: ParsedListMember
    """
    # get what kind of generic alias this is
    cdef type origin = typing.get_origin(generic_alias)
    if origin is not list:
        raise ValueError(f"Unsupported Generic Alias origin type '{origin}'")

    # get out base annotation arg (ex: list[ -> str <- ])
    cdef type annotation = typing.get_args(generic_alias)[0]

    # if auto cast is true, auto cast the value
    cdef int x
    if auto_cast is True:
        for x in range(len(obj)):
            obj[x] = auto_cast_object(obj[x], annotation)

    # create a parsed list member
    cdef ParsedListMember plm = ParsedListMember()
    plm.class_name = class_name
    plm.member_name = member_name
    plm.list_ = obj
    plm.base_annotated_type = annotation

    # run the enforce now, we want to not bother enforcing more if we have a validation error
    plm.enforce()
    return plm


cpdef ParsedUnionMember parse_union_member(str class_name, str member_name, tuple allowed_types, object obj, bint auto_cast = False):
    """
    Parses a union member of a class
    :param class_name: Class name
    :param member_name: Member name
    :param obj: Object to parse
    :param allowed_types: Tuple of allowed types in the union
    :param auto_cast: Automatically cast compatible types
    :return: ParsedUnionMember object
    """
    # if auto cast is true, auto cast the value
    #if auto_cast is True:
    #    obj = _auto_cast(obj, )

    # create a ParsedMember
    cdef ParsedUnionMember parsed_member = ParsedUnionMember()
    parsed_member.allowed_types = allowed_types
    parsed_member.actual_type = type(obj)
    parsed_member.obj = obj
    parsed_member.member_name = member_name
    parsed_member.class_name = class_name

    # run the enforce now, we want to not bother enforcing more if we have a validation error
    parsed_member.enforce()
    return parsed_member


cpdef ParsedMember parse_member(str class_name, str member_name, type annotation, object obj, bint auto_cast = False):
    """
    Parses a standard member of a class
    :param class_name: Class name
    :param member_name: Member name
    :param obj: Object to parse
    :param annotation: Type annotation of obj
    :param auto_cast: Automatically cast compatible types
    :return: ParsedMember object
    """
    # if auto cast is true, auto cast the value
    if auto_cast is True:
        obj = auto_cast_object(obj, annotation)

    # create a ParsedMember
    cdef ParsedMember parsed_member = ParsedMember()
    parsed_member.annotated_type = annotation
    parsed_member.actual_type = type(obj)
    parsed_member.obj = obj
    parsed_member.member_name = member_name
    parsed_member.class_name = class_name

    # run the enforce now, we want to not bother enforcing more if we have a validation error
    parsed_member.enforce()
    return parsed_member