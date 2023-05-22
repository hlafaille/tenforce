#cython: language_level=3
from types import GenericAlias

from tenforce.exceptions import TypeEnforcementError

cdef class UninitializedMember:
    """A container class to differentiate class variables populated with None intentionally and those who are uninitialized"""
    pass


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
                requested_type=self.annotated_type,
                actual_type=self.actual_type
            )



cpdef check(object obj):
    """
    Checks the class variables of an object & enforces its type hints
    :param obj: Instance of a class
    :return: None
    """
    # define the annotations and values
    cdef str class_name = obj.__class__.__name__
    cdef dict annotations = obj.__annotations__
    cdef dict values = obj.__dict__

    # create the ParsedMember instance and a list to hold them
    cdef list parsed_members = []
    cdef ParsedMember parsed_member = ParsedMember()

    # iterate over the annotations and create ParsedMember objects
    cdef str x
    for x in annotations.keys():
        # todo add support for list typing
        if type(annotations[x]) is GenericAlias:
            continue

        # create a ParsedMember
        parsed_member.annotated_type = annotations[x]
        parsed_member.actual_type = type(values.get(x, UninitializedMember()))
        parsed_member.obj = values.get(x, UninitializedMember())
        parsed_member.member_name = x
        parsed_member.class_name = class_name
        parsed_members.append(parsed_member)

    # iterate over the parsed members, validate their types
    cdef int y
    for y in range(len(parsed_members)):
        parsed_members[y].enforce()
