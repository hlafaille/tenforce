from tenforce.enforcer import check


class TestObject:
    a: list[str]
    b: int


check(TestObject())
#parse_type_string(str(dict))