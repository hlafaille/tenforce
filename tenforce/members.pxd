cdef class ParsedMember:
    cdef public type annotated_type
    cdef public type actual_type
    cdef public object obj
    cdef public str member_name
    cdef public str class_name

    cpdef enforce(self)

cdef class ParsedListMember:
    cdef public type base_annotated_type
    cdef public list list_
    cdef public str member_name
    cdef public str class_name

    cpdef enforce(self)


cdef class ParsedUnionMember:
    cdef public tuple allowed_types
    cdef public type actual_type
    cdef public object obj
    cdef public str member_name
    cdef public str class_name

    cpdef enforce(self)