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
        #print(f"{self.class_name}.{self.member_name}: {self.annotated_type} | {self.actual_type} = {self.obj}")
        if self.actual_type is not self.annotated_type:
            raise TypeEnforcementError(
                class_name=self.class_name,
                var_name=self.member_name,
                requested_type=self.annotated_type,
                actual_type=self.actual_type,
                obj=self.obj
            )


cpdef check(object obj: object, bint auto_cast: bool = False):
    """
    Checks the class variables of an object & enforces its type hints
    :param obj: Instance of a class
    :param auto_cast: Optional, automatically cast things like 
    :return: None
    """

    # define the annotations and values
    cdef str class_name = obj.__class__.__name__
    cdef dict annotations = obj.__annotations__
    cdef dict values = obj.__dict__

    # create the ParsedMember instance and a list to hold them
    cdef list parsed_members = []
    cdef ParsedMember parsed_member

    # iterate over the annotations and create ParsedMember objects
    cdef str x
    for x in annotations.keys():
        # todo add support for list typing
        if type(annotations[x]) is GenericAlias:
            continue

        # if auto cast is true, auto cast the value
        if auto_cast is True:
            # if the value provided is a numeric string, try and cast it to an int
            if type(values.get(x)) is str and annotations[x] is int and values.get(x).isnumeric():
                values[x] = int(values[x])

            # if the value provided is an int and the annotation requires a float, try and cast it to a float
            if type(values.get(x)) is int and annotations[x] is float:
                values[x] = float(values[x])

        # create a ParsedMember
        parsed_member = ParsedMember()
        parsed_member.annotated_type = annotations[x]
        parsed_member.actual_type = type(values.get(x))
        parsed_member.obj = values.get(x)
        parsed_member.member_name = x
        parsed_member.class_name = class_name
        parsed_members.append(parsed_member)

    # iterate over the parsed members, validate their types
    cdef int y
    for y in range(len(parsed_members)):
        parsed_members[y].enforce()
