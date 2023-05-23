# Tenforce

**T**ype **enforce**ment for Python.

# Installation
`pip install tenforce`

# Usage
```python
from uuid import UUID, uuid4
from tenforce.enforcer import check

# define a class
class CreateOrderRequest:
    user_id: UUID
    skus: list[int]
    ship_service_level: str

if __name__ == "__main__":
    # populate your class that needs type enforcement
    request = CreateOrderRequest()
    request.user_id = uuid4()
    request.skus = [1234567890, 0987213]
    ship_service_level = "Overnight"
    
    # call check() on it
    check(request)
    
    # or, automatically cast compatible types (ex: numeric strings with an int annotation)
    check(request, auto_cast=True)
```

# Reason for development

I developed this package because I had issues with Pydantic and handling large amounts of base models. I eventually
plan to add serialization/deserialization to this. For example, populating **one billion** `BaseModel` objects in
Pydantic takes roughly 30-35 seconds on my M1 Mac, versus 3-7 seconds with Tenforce. Pydantic is supposed to get a 
rewrite in rust with V2 though, so let's see how that turns out :)

### Results
<img width="713" alt="image" src="https://github.com/hlafaille/tenforce/assets/5008650/6b6b625a-d46e-40e1-841c-f285d99373a2">

# Principles

This package is designed to enforce the types of a Python class and its class variables (through type hints). Written
mainly in Cython, it follows a few design principles.

1. Sacrifice certain dynamic language features for speed and simplicity
    * Things like Unions (except for `None` unions & `Optional`) & subscripted type annotations (ex: `list[str]`) for the sake of simplicity and speed
2. Opt-in helpers, not opt-out
    * By default, we try to run was little code as possible when calling `check()` on an object. We do have extra arguments
      like `auto_cast` to automatically cast variables (assuming it can be a successful cast)
3. Support only the most popular patterns for API development
   * In my experience doing backend in a dynamic language such as Python, it is often you don't find yourself ever needing 
      a list able to contain multiple types (ex: `list[str | int]`)
   * Building in lots of features will inevitably add slowdowns to `check()`
