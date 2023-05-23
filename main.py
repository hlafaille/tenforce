from tenforce.enforcer import check


class TestClass:
    a: int
    b: int

test_class = TestClass()
test_class.a = 1
test_class.b = 2
check(test_class)