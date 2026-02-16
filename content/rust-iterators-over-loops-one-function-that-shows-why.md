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

**`iter().sum()`** works because `sum()` is a consuming adaptor. It takes ownership of the iterator, accumulates every element using the `Sum` trait, and returns the result. The type system infers `i32` from the function signature, so you don't even need a turbofish (`::<Type>` annotation). If the compiler couldn't infer the type, you'd write `v.iter().sum::<i32>()` instead.

The `Sum` trait is more powerful than it looks. It's also implemented for `Option<T>` and `Result<T, E>`, which means you can sum a list that might contain missing or failed values — no manual `if` checks needed:

```rust
let v = vec![Some(1), Some(2), None];
let total: Option<i32> = v.into_iter().sum(); // Returns None
```

If all elements are `Some(n)`, you get `Some(total)`. If *any* element is `None`, the whole result is `None`. In many languages, this would require a messy loop with null checks.

## Zero-Cost Abstractions

In Python or JavaScript, chaining higher-order functions like `map` and `filter` typically allocates intermediate collections at each step. In Rust, it doesn't. Rust iterators use a *pull* model — nothing happens until something consumes the chain. The compiler inlines the entire pipeline and optimizes it into a single tight loop, the same machine code you'd get from writing the `for` loop by hand.

This is what Rust means by *zero-cost abstractions*: you don't pay a runtime price for the higher-level expression. No heap allocations for intermediate results, no virtual dispatch, no hidden overhead. The abstraction exists at compile time and disappears in the binary.

In fact, the iterator version can sometimes be *faster* than a hand-written loop. The compiler may apply SIMD (Single Instruction, Multiple Data) optimizations to `iter().sum()`, summing multiple numbers in a single CPU instruction — an optimization that's harder to trigger with a manual accumulator loop.

That's the deal Rust offers — write the clearer version and trust the compiler to make it at least as fast, sometimes faster.

## When to Reach for Iterators

Iterators shine when the operation maps to a well-known pattern:

- **Summing**: `iter().sum()`
- **Transforming**: `iter().map(f).collect()`
- **Filtering**: `iter().filter(p).collect()`
- **Mutating in place**: `iter_mut().for_each(f)`
- **Finding**: `iter().find(p)`
- **Checking conditions**: `iter().all(p)` / `iter().any(p)` (just like Python's [`all()` and `any()`](https://docs.python.org/3/library/functions.html#all), but as iterator methods instead of free functions)

If your loop body does one of these things, the iterator version is almost always clearer.

That said, a `for` loop is still the right choice when the logic is highly stateful, involves complex early breaks, or doesn't map cleanly to a single combinator. Iterators replace boilerplate loops, not all loops.

## Key Takeaways

- Rust iterators express intent directly, removing boilerplate state management
- `iter()` borrows, `iter_mut()` borrows mutably, `into_iter()` takes ownership — pick the one that matches your access pattern (see [Ownership and Borrowing](/ownership-and-borrowing/) for a refresher)
- Zero-cost abstractions mean you get clarity without sacrificing performance
- One-liner iterator chains are not "clever code" — they're idiomatic Rust

## Practice This

Try the [Vectors and Slices exercise on Pybites Rust Platform](https://rustplatform.com/vectors-and-slices) and see how far you can get without writing a single `for` loop.

