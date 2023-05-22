import random
import unittest

from pydantic import BaseModel

from tenforce.enforcer import check


class TestClass:
    sku: int
    mfg_part_number: str
    description: str
    image_urls: list[str]


class TestClassPd(BaseModel):
    sku: int
    mfg_part_number: str
    description: str
    image_urls: list[str]


class TestValidator(unittest.TestCase):
    def test_one_billion_tenforce(self):
        """
        Tests 1 Billion successful validations on TestClass using Tenforce
        """
        for x in range(0, 9_999_999):
            test_class = TestClass()
            test_class.sku = 12345
            test_class.mfg_part_number = "ABC"
            test_class.description = "Test Description"
            test_class.image_urls = []
            check(test_class)

    def test_one_billion_pydantic(self):
        """
        Tests 1 Billion successful validations on TestClasPd using Pydantic
        """
        for x in range(0, 9_999_999):
            test_class = TestClassPd(
                sku=12345,
                mfg_part_number="ABC",
                description="Test Description",
                image_urls=[]
            )

    def test_fail(self):
        test_class = TestClass()
        test_class.sku = 'AAAA'
        check(test_class)

