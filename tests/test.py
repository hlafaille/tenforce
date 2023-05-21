import random
import unittest

from pydantic import BaseModel

from tenforce.validator import check


class TestClass:
    sku: int
    mfg_part_number: str
    description: str
    image_urls: list[str]


class TestClassPd(BaseModel):
    sku: int
    mfg_part_number: str
    description: str


class TestValidator(unittest.TestCase):
    def test_fail(self):
        """
        Tests a failure
        """
        test_class = TestClass()
        test_class.sku = "a"
        test_class.mfg_part_number = 1
        check(test_class)

    def test_one_billion_tenforce(self):
        """
        Tests 1 Billion successful validations on TestClass using Tenforce
        """
        for x in range(0, 9_999_999):
            test_class = TestClass()
            test_class.sku = random.randrange(111111, 999999999)
            test_class.mfg_part_number = str(random.randrange(69420, 999999999999999))
            test_class.description = "Test Description"
            test_class.image_urls = []
            check(test_class)

    def test_one_billion_pydantic(self):
        """
        Tests 1 Billion successful validations on TestClasPd using Pydantic
        """
        for x in range(0, 9_999_999):
            test_class = TestClassPd(
                sku=random.randrange(111111, 999999999),
                mfg_part_number=str(random.randrange(69420, 999999999999999)),
                description="Test Description"
            )


