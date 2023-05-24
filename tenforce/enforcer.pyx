#cython: language_level=3
import typing
from types import GenericAlias, UnionType

from tenforce.parser import _parse_generic_alias_member, _parse_union_member, _parse_member
from tenforce.members import ParsedMember, ParsedListMember, ParsedUnionMember


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
