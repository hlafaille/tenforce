import gc
import unittest
from typing import Any

from pydantic import BaseModel

from tenforce.enforcer import check
from tenforce.exceptions import TypeEnforcementError


class TestClass:
    sku: int
    mfg_part_number: str
    description: str
    image_urls: list[str]


class OtherTestClass:
    sku: int
    mfg_part_number: str
    description: str


class OtherOtherTestClass:
    sku: int | None
    mfg_part_number: str
    description: str


class TestClassPd(BaseModel):
    sku: int
    mfg_part_number: str
    description: str
    image_urls: list[str]


class OtherTestClassPd(BaseModel):
    sku: int
    mfg_part_number: str
    description: str


class OtherOtherTestClassPd(BaseModel):
    sku: int | None
    mfg_part_number: str
    description: str


class TestEnforcer(unittest.TestCase):
    def test_one_million_tenforce(self):
        """
        Tests one million successful validations on TestClass using Tenforce
        """
        for x in range(0, 1_000_000):
            test_class = TestClass()
            test_class.sku = 12345
            test_class.mfg_part_number = "ABC"
            test_class.description = "Test Description"
            test_class.image_urls = ["a", "b"]
            check(test_class)

    def test_one_million_pydantic(self):
        """
        Tests one million validations on TestClasPd using Pydantic
        """
        for x in range(0, 1_000_000):
            test_class = TestClassPd(
                sku=12345,
                mfg_part_number="ABC",
                description="Test Description",
                image_urls=["a", "b"]
            )

    def test_fail(self):
        """
        Try to force a TypeEnforcementError
        """
        try:
            test_class = TestClass()
            test_class.sku = 123
            test_class.mfg_part_number = "ABC"
            test_class.description = "123"
            test_class.image_urls = []
            for x in range(0, 11111):
                test_class.image_urls.append(x)
            check(test_class)
        except TypeEnforcementError as e:
            print(e)
            print("Caught TypeEnforcementError, pass")

    def test_autocast(self):
        """
        Test automatically casting types
        """
        test_class = TestClass()
        test_class.sku = "12345"
        test_class.mfg_part_number = "ABC"
        test_class.description = "Test Description"
        test_class.image_urls = ["a", "b"]
        check(test_class, auto_cast=True)

    def test_one_million_no_generic_alias_tenforce(self):
        """
        Tests one billion successful validations on OtherTestClass using Tenforce
        """
        for x in range(0, 1_000_000):
            test_class = OtherTestClass()
            test_class.sku = 12345
            test_class.mfg_part_number = "ABC"
            test_class.description = "Test Description"
            check(test_class)

    def test_one_million_no_generic_alias_pydantic(self):
        """
        Tests one billion successful validations on OtherTestClassPd using Pydantic
        """
        for x in range(0, 1_000_000):
            test_class = OtherTestClassPd(
                sku=12345,
                mfg_part_number="ABC",
                description="Test Description"
            )

    def test_optional_field(self):
        """
        Tests an optional field
        """
        test_class = OtherOtherTestClass()
        test_class.sku = None
        test_class.mfg_part_number = "ABC"
        test_class.description = "Test Description"
        test_class.image_urls = [1, 2]
        check(test_class, auto_cast=True)