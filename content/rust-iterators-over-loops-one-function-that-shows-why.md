+++
title = "Rust iterators over loops: one function that shows why"
date = 2026-02-16
+++

Most developers reaching for Rust write their first `for` loop within minutes. But Rust's iterator methods let you express the same logic in fewer lines, with less room for bugs. One small function shows the difference clearly.

## The Imperative Instinct

When asked to sum a slice of integers, the instinct is a classic accumulator loop:

```rust
pub fn sum_slice(v: &[i32]) -> i32 {
    let mut total = 0;
    for item in v {
        total += item;
    }
    total
}
```

A mutable variable, an explicit loop, and a trailing return. It works, but it forces the reader to trace state through the body to understand intent.

## The Functional Alternative

Here's the same logic using Rust's iterator combinators:

```rust
pub fn sum_slice(v: &[i32]) -> i32 {
    v.iter().sum()
}
```

That's it. One line that reads almost like English: *iterate over the slice, sum everything.*

No mutable accumulator. No explicit loop. No room for bugs.

## Why This Works

Rust's `Iterator` trait provides a rich set of composable methods.

**`iter().sum()`** works because `sum()` is a consuming adaptor. It takes ownership of the iterator, accumulates every element using the `Add` trait, and returns the result. The type system infers `i32` from the function signature, so you don't even need a turbofish.

The iterator version compiles down to the same machine code as the loop version. Rust's zero-cost abstractions mean you get clarity without sacrificing performance.

## When to Reach for Iterators

Iterators shine when the operation maps to a well-known pattern:

- **Summing**: `iter().sum()`
- **Transforming**: `iter().map(f).collect()`
- **Filtering**: `iter().filter(p).collect()`
- **Mutating in place**: `iter_mut().for_each(f)`
- **Finding**: `iter().find(p)`
- **Checking conditions**: `iter().all(p)` / `iter().any(p)`

If your loop body does one of these things, the iterator version is almost always clearer.

## Key Takeaways

- Rust iterators express intent directly, removing boilerplate state management
- `iter()` borrows, `iter_mut()` borrows mutably, `into_iter()` takes ownership — pick the one that matches your access pattern
- Zero-cost abstractions mean you get clarity without sacrificing performance
- One-liner iterator chains are not "clever code" — they're idiomatic Rust

## Practice This

Try the [Vectors and Slices exercise on Pybites Rust Platform](https://rustplatform.com/vectors-and-slices) and see how far you can get without writing a single `for` loop.

