+++
title = "Rust's numeric types for Python devs: why i32, u32, and f64 matter"
date = 2026-02-07
draft = true
+++

In Python, numbers are simple. `42` is an `int`. `3.14` is a `float`. You can mix them freely and Python figures it out:

```python
result = 42 + 3.14  # 45.14 — Python promotes int to float
```

Your first week in Rust, you'll try the same thing and hit a wall.

## Many types, no magic

Rust has a whole family of numeric types:

| Type | Size | Range |
|------|------|-------|
| `i8`, `i16`, `i32`, `i64`, `i128` | 1–16 bytes | signed integers |
| `u8`, `u16`, `u32`, `u64`, `u128` | 1–16 bytes | unsigned (no negatives) |
| `f32`, `f64` | 4 or 8 bytes | floating point |

The defaults are `i32` for integers and `f64` for floats — you'll use these most of the time. But unlike Python, Rust won't convert between them for you:

```rust
let x: i32 = 42;
let y: f64 = 3.14;
let result = x + y;  // ERROR: mismatched types
```

You need an explicit cast:

```rust
let result = x as f64 + y;  // 45.14
```

## Why all these types?

Python's `int` can be arbitrarily large — `2 ** 1000` works fine. That flexibility comes at a cost: every integer is a heap-allocated object with reference counting overhead.

Rust's `i32` is exactly 4 bytes on the stack. No heap allocation, no reference counting, no overhead. When you're processing millions of numbers, that difference is enormous.

The unsigned types (`u32`, `u64`, etc.) add another layer: if a value can never be negative — like an array index or a count — using `u32` makes that constraint visible in the type and catches mistakes at compile time. Try assigning `-1` to a `u32` and the compiler stops you.

## The semicolon gotcha

While we're on Rust basics that trip up Python devs: Rust functions are **expression-based**. The last expression in a function is the return value — no `return` keyword needed:

```rust
fn double(x: i32) -> i32 {
    x * 2  // no semicolon — this is the return value
}
```

But add a semicolon and it becomes a *statement* that returns `()` (Rust's unit type, like Python's `None`):

```rust
fn double(x: i32) -> i32 {
    x * 2;  // semicolon! returns () instead of i32 — compile error
}
```

The error message will say something like "expected `i32`, found `()`". When you see that, check for a stray semicolon on the last line.

## Type inference — it's not all manual

Rust does have type inference. You don't always need to annotate:

```rust
let x = 42;        // Rust infers i32
let y = 3.14;      // Rust infers f64
let even = x % 2 == 0;  // Rust infers bool
```

The compiler looks at how you use a value and picks the right type. You only need explicit annotations when the compiler can't figure it out (like with `.collect()`, or when you want a specific type like `u32` instead of the default `i32`).

## Python's bool vs Rust's bool

Small but worth noting: Python uses `True` and `False` (capitalized). Rust uses `true` and `false` (lowercase). And while Python's `bool` is a subclass of `int` (so `True + True == 2`), Rust's `bool` is a completely separate type — no arithmetic on booleans.

## Practice this

Try the [Simple Calculations exercise on Pybites Rust Platform](https://rustplatform.com/simple-calculations) — implement a temperature converter and an even-number checker to get comfortable with Rust's numeric types and expression-based returns.
