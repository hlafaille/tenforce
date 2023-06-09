from members cimport ParsedListMember, ParsedUnionMember, ParsedMember

cpdef ParsedListMember parse_generic_alias_member(str class_name, str member_name, object generic_alias, object obj, bint auto_cast = ?)
cpdef ParsedUnionMember parse_union_member(str class_name, str member_name, tuple allowed_types, object obj, bint auto_cast = ?)
cpdef ParsedMember parse_member(str class_name, str member_name, type annotation, object obj, bint auto_cast = ?)