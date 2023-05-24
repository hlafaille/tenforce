cdef class ParsedMember:
    cdef type annotated_type
    cdef type actual_type
    cdef object obj
    cdef str member_name
    cdef str class_name
    cpdef enforce(self)

cdef class ParsedListMember:
    cdef type base_annotated_type
    cdef list list_
    cdef str member_name
    cdef str class_name
    cpdef enforce(self)

cdef class ParsedUnionMember:
    cdef tuple allowed_types
    cdef type actual_type
    cdef object obj
    cdef str member_name
    cdef str class_name
    cpdef enforce(self)