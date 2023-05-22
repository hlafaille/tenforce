import typing
from types import GenericAlias

from tenforce.exceptions import TypeEnforcementError

cdef class UninitializedMember:
    """A container class to differentiate class variables populated with None intentionally and those who are uninitialized"""
    pass

cdef class TypedList:
    """Represents a GenericAlias list"""
    cdef type requested_type
    cdef list obj

    cdef enforce(self):
        """
        Enforces the requested_type on all members of obj
        :raise TypeEnforcementError: if the requested_type does not match at least one member of obj
        :return: 
        """

# EnforceableObject contains
cdef class EnforceableObject:
    cdef type requested_type
    cdef object obj

    cdef enforce(self):
        """
        Enforces the requested_type on obj
        :raises TypeEnforcementError: if the requested_type does not match actual_type
        :return: 
        """
        if type(self.obj) is not self.requested_type:
            raise TypeEnforcementError()

cpdef check(object obj):
    """
    Checks the class variables of an object & enforces its type hints
    :param obj: Instance of a class
    :return: None
    """
    # get the annotations of the object
    cdef dict annotations = typing.get_type_hints(obj)
    cdef dict class_values = obj.__dict__
    cdef list enforceable_objects = []

    # iterate over the annotations, generate a list of EnforceableObject(s)
    cdef str var
    for var in annotations.keys():
        if type(annotations[var]) is GenericAlias:
            continue
        enforceable_object = EnforceableObject()
        enforceable_object.requested_type = annotations[var]
        enforceable_object.obj = class_values.get(annotations[var], UninitializedMember)
        enforceable_objects.append(enforceable_object)


