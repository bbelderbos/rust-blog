+++
title = "Your first Rust function (from a Python perspective)"
date = 2026-02-15
+++

Here's a Python function:

```python
def greet() -> str:
    return "Hello, Rustacean!"
```

Here's the Rust equivalent:

```rust
fn greet() -> String {
    "Hello, Rustacean!".to_string()
}
```

Four differences, all visible in three lines:

**1. `fn` instead of `def`.** Cosmetic, easy.

**2. `-> String` is required.** Python type hints are optional documentation. Rust return types are mandatory — the compiler uses them.

**3. No `return` keyword.** The last expression (without a semicolon) is the return value. Add a semicolon and it becomes a statement that returns nothing — a common gotcha.

**4. `String` vs `str`.** Python has one string type. Rust has two: `&str` (borrowed slice, like a read-only view) and `String` (owned, heap-allocated). The literal `"Hello"` is a `&str`. `.to_string()` converts it to an owned `String`.

That fourth point is the one that will take the longest to internalize. For now, just remember: Rust has two string types, and you need to choose the right one for your function's return type: literals are `&str`, owned data is `String`, and `.to_string()` bridges them.

## Practice this

Try these exercises on the Pybites Rust Platform:

- [Hello, Rustacean!](https://rustplatform.com/hello-rustacean) — your first Rust function, returning a String
- [Functions and Return Values](https://rustplatform.com/functions-and-return-values) — practice `fn`, return types, and implicit returns
- [Strings and Slices](https://rustplatform.com/strings-and-slices) — get comfortable with `&str` vs `String`
