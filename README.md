# Tenforce
**T**ype **enforce**ment for Python.

# Reason
I developed this package because I had issues with `pydantic` and handling large amounts of base models. I eventually
plan to add serialization/deserialization to this.

# Principles
This package is designed to enforce the types of a Python class and its class variables (through type hints). Written
mainly in Cython, it follows a few design principles.
1. Sacrifice some dynamic language features for speed and simplicity
    * We sacrifice things like Unions (except for `None` unions & `Optional`) for the sake of simplicity and speed
