#cython: language_level=3
import typing
from types import GenericAlias, UnionType, NoneType

from tenforce.exceptions import TypeEnforcementError, AutoCastError

cdef class ParsedMember:
    cdef type annotated_type
    cdef type actual_type
    cdef object obj
    cdef str member_name
    cdef str class_name

    cpdef enforce(self):
        """
        Enforces the type for this ParsedMember
        :raises TypeEnforcementError: if there is a mismatched type
        :return: None
        """
        if self.actual_type is not self.annotated_type:
            raise TypeEnforcementError(
                class_name=self.class_name,
                var_name=self.member_name,
                requested_types=[self.annotated_type],
                actual_type=self.actual_type,
                obj=self.obj
            )


cdef class ParsedListMember:
    cdef type base_annotated_type
    cdef list list_
    cdef str member_name
    cdef str class_name
    # we don't have an actual_type field, since a list can have more than one type!

    cpdef enforce(self):
        """
        Enforces the type annotated_type for list_
        :raises TypeEnforcementError: if there is a mismatched type
        :return: 
        """
        cdef int x
        cdef type current_elem_type
        for x in range(len(self.list_)):
            current_elem_type = type(self.list_[x])
            if current_elem_type is not self.base_annotated_type:
                raise TypeEnforcementError(
                    class_name=self.class_name,
                    var_name=f"{self.member_name}[{x}]",
                    requested_types=[self.base_annotated_type],
                    actual_type=current_elem_type,
                    obj=self.list_[x]
                )


cdef class ParsedUnionMember:
    cdef tuple allowed_types
    cdef type actual_type
    cdef object obj
    cdef str member_name
    cdef str class_name

    cpdef enforce(self):
        """
        Enforces the type for this ParsedMember
        :raises TypeEnforcementError: if there is a mismatched type
        :return: None
        """
        # try to find a matching type in the union
        cdef int x
        cdef bint match_found = False
        for x in range(len(self.allowed_types)):
            if self.actual_type is self.allowed_types[x]:
                match_found = True
                break

        # if there was no matching type found in the union, raise error
        if not match_found:
            raise TypeEnforcementError(
                class_name=self.class_name,
                var_name=self.member_name,
                requested_types=self.allowed_types,
                actual_type=self.actual_type,
                obj=self.obj
            )


cpdef object _auto_cast(object obj, type annotation):
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


cpdef object _auto_cast_union(object obj, type annotation):
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



cpdef ParsedListMember _parse_generic_alias_member(str class_name, str member_name, object generic_alias, object obj, bint auto_cast = False):
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
            obj[x] = _auto_cast(obj[x], annotation)

    # create a parsed list member
    cdef ParsedListMember plm = ParsedListMember()
    plm.class_name = class_name
    plm.member_name = member_name
    plm.list_ = obj
    plm.base_annotated_type = annotation

    # run the enforce now, we want to not bother enforcing more if we have a validation error
    plm.enforce()
    return plm


cpdef ParsedUnionMember _parse_union_member(str class_name, str member_name, tuple allowed_types, object obj, bint auto_cast = False):
    """
    Parses a union member of a class
    :param class_name: Class name
    :param member_name: Member name
    :param obj: Object to parse
    :param allowed_types: Tuple of allowed types in the union
    :param auto_cast: Automatically cast compatible types
    :return: ParsedMember object
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


cpdef ParsedMember _parse_member(str class_name, str member_name, type annotation, object obj, bint auto_cast = False):
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
        obj = _auto_cast(obj, annotation)

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


cpdef check(object obj, bint auto_cast = False):
    """
    Checks the class variables of an object & enforces its type hints
    :param obj: Instance of a class
    :param auto_cast: Optional, automatically cast things like numeric strings to ints (if the annotation allows)
    :return: None
    """

    # define the annotations and values
    cdef str class_name = obj.__class__.__name__
    cdef dict annotations = obj.__annotations__
    cdef dict values = obj.__dict__

    # create the ParsedMember instance and a list to hold them
    cdef list parsed_members = []
    cdef ParsedMember parsed_member
    cdef list parsed_generic_alias_member = []
    cdef ParsedListMember plm
    cdef list parsed_union_members = []
    cdef ParsedUnionMember pum


    # iterate over the annotations and create ParsedMember objects
    cdef str member_name
    for member_name in annotations.keys():
        if type(annotations[member_name]) is GenericAlias:
            plm = _parse_generic_alias_member(
                class_name=class_name,
                member_name=member_name,
                generic_alias=annotations[member_name],
                obj=values.get(member_name),
                auto_cast=auto_cast
            )
            parsed_generic_alias_member.append(plm)
        elif type(annotations[member_name]) is UnionType:
            pum = _parse_union_member(
                class_name=class_name,
                member_name=member_name,
                allowed_types=typing.get_args(annotations[member_name]),
                obj=values.get(member_name),
                auto_cast=auto_cast
            )
            parsed_union_members.append(pum)
        else:
            parsed_member = _parse_member(
                class_name=class_name,
                member_name=member_name,
                annotation=annotations[member_name],
                obj=values.get(member_name),
                auto_cast=auto_cast
            )
            parsed_members.append(parsed_member)
