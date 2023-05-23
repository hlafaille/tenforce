# Tenforce

**T**ype **enforce**ment for Python.

# Reason for development

I developed this package because I had issues with Pydantic and handling large amounts of base models. I eventually
plan to add serialization/deserialization to this. For example, populating **one billion** `BaseModel` objects in
Pydantic takes roughly 30-35 seconds on my M1 Mac, versus 3-5 seconds with Tenforce. Pydantic is supposed to get a 
rewrite in rust with V2 though, so let's see how that turns out :)

# Principles

This package is designed to enforce the types of a Python class and its class variables (through type hints). Written
mainly in Cython, it follows a few design principles.

1. Sacrifice certain dynamic language features for speed and simplicity
    * Things like Unions (except for `None` unions & `Optional`) & subscripted type annotations (ex: `list[str]`) for the sake of simplicity and speed
2. Opt-in helpers, not opt-out
    * By default, we try to run was little code as possible when calling `check()` on an object. We do have extra arguments
      like `auto_cast` to automatically cast variables (assuming it can be a successful cast)