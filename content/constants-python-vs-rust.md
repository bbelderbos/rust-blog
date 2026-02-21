+++
title = "Constants in Python vs Rust"
date = 2024-06-18
+++

In Python you define constants using uppercase variable names (dictated by PEP8), for example:

```python
TIMEOUT = 10
ENDPOINT = "https://codechalleng.es/api/content/"
CACHE_FILE_NAME = ".pybites-search-cache.json"
DEFAULT_CACHE_DURATION = 86400  # Cache API response for 1 day
```

Nothing prevents you from overriding these values, but it's a convention to treat them as constants.

To add a layer of immutability, you can use type hints with the `Final` qualifier from the `typing` module:

```python
from typing import Final

TIMEOUT: Final[int] = 10
ENDPOINT: Final[str] = "https://codechalleng.es/api/content/"
CACHE_FILE_NAME: Final[str] = ".pybites-search-cache.json"
DEFAULT_CACHE_DURATION: Final[int] = 86400  # Cache API response for 1 day
```

When you try to override these values mypy will raise an error. Your IDE might also proactively warn you about it.

Overall type hints are a good practice in Python, they make your code more readable and bring some of Rust's strictness to Python. 💡 😍 📈

Another example of enforcing immutability in Python is using `frozen=True` on a `dataclass`.

Now let's look at Rust. You define constants using the `const` keyword and define the type explicitly:

```rust
const TIMEOUT: u64 = 10;
const ENDPOINT: &str = "https://codechalleng.es/api/content/";
const CACHE_FILE_NAME: &str = ".pybites-search-cache.json";
const DEFAULT_CACHE_DURATION: u64 = 86400; // Cache API response for 1 day
```

The `&str` type is a reference to a string, which avoids copying data around. In contrast, `String` is a heap-allocated string.

`&str` does not allocate memory itself; it references an existing string slice. This is more efficient for passing around string literals, which are stored in the program's binary and are immutable, making `&str` ideal for constants.

The key point is that you cannot override these values; the compiler will raise an error.

Rust also has a `static` keyword which is used for global variables, but that's a topic for another article.

In both Python and Rust, you can define enums to group related constants together, but that's a topic for another article too.

## Practice This

Try the [Variables and Mutability](https://rustplatform.com/variables-and-mutability) exercise on the Pybites Rust Platform to practice `let`, `mut`, and `const` in Rust.

## Conclusion

Both Python and Rust have clear conventions for defining constants. Rust enforces immutability strictly at the language level, while in Python, you can achieve a similar level of strictness by using type hints.

Each language offers tools and conventions that help maintain the integrity of your constants, ensuring reliable and predictable behavior in your programs.
