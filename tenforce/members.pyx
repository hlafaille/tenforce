from tenforce.exceptions import TypeEnforcementError

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
