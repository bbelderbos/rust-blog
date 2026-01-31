+++
title = "Pattern matching in Rust: match is not just switch"
date = 2026-02-08
draft = true
+++

Python 3.10 added structural pattern matching — `match`/`case`. If you've used it, you'll feel at home with Rust's `match`. But Rust's version has been there since day one, and it has teeth.

## Basic match

In Python:

```python
match status:
    case 200:
        print("OK")
    case 404:
        print("Not found")
    case _:
        print(f"Other: {status}")
```

In Rust:

```rust
match status {
    200 => println!("OK"),
    404 => println!("Not found"),
    _ => println!("Other: {status}"),
}
```

Similar syntax, similar idea. But there's a critical difference hiding in plain sight.

## Exhaustive matching

Rust's `match` is **exhaustive** — the compiler requires you to handle every possible case. Forget one? It won't compile.

```rust
enum Direction {
    North,
    South,
    East,
    West,
}

match direction {
    Direction::North => println!("going up"),
    Direction::South => println!("going down"),
    // ERROR: non-exhaustive patterns: `East` and `West` not covered
}
```

In Python, forgetting a `case` branch just means it falls through silently. In Rust, the compiler catches it. This becomes invaluable as your codebase grows — add a new variant to an enum and the compiler shows you every place that needs updating.

The `_` wildcard acts as the catch-all (like Python's `case _`), so you can always handle "everything else" when you don't need individual branches.

## Match is an expression

In Python, `match` is a statement — it does things but doesn't return a value. In Rust, `match` is an **expression** — it evaluates to a value:

```rust
let label = match code {
    200 => "OK",
    404 => "Not Found",
    500 => "Server Error",
    _ => "Unknown",
};
```

This eliminates the pattern of declaring a mutable variable, then setting it inside a conditional. The value comes directly from the match — clean and immutable.

## Match guards

Sometimes you need more than just pattern matching — you need a condition. Rust supports **match guards** with `if`:

```rust
match temperature {
    t if t < 0 => println!("freezing"),
    0 => println!("exactly zero"),
    t if t > 100 => println!("boiling"),
    _ => println!("somewhere in between"),
}
```

The `t if t < 0` binds the value to `t` and only matches when the condition holds. This is more powerful than Python's guard syntax and handles cases that would otherwise need nested `if` statements.

## When things go wrong: panic! vs raise

Rust doesn't have exceptions. When a function gets input that should *never* happen, you have two options:

1. **`Result<T, E>`** — return an error the caller can handle (the preferred approach)
2. **`panic!`** — abort immediately with a message (the nuclear option)

```rust
fn fibonacci(n: i32) -> u32 {
    match n {
        n if n < 0 => panic!("Negative input is not allowed"),
        0 => 0,
        1 => 1,
        _ => fibonacci(n - 1) + fibonacci(n - 2),
    }
}
```

`panic!` is like Python's `raise Exception(...)` — but with no `try`/`except` to catch it (well, there's `catch_unwind`, but that's rarely used). Use it for programmer errors, not for expected failure cases.

In tests, you can verify that code panics:

```rust
#[test]
#[should_panic]
fn test_negative_input() {
    fibonacci(-1);
}
```

The `#[should_panic]` attribute flips the test — it passes if the code panics, and fails if it doesn't.

## Python's flexibility vs Rust's guarantees

Python's `match`/`case` is flexible and forgiving — you can match on types, attributes, and complex structures without the compiler enforcing anything. That's great for rapid development.

Rust's `match` trades that flexibility for guarantees. Every case is covered, every branch returns the same type, and the compiler won't let you forget an edge case. When you're writing code that needs to be reliable, that's a powerful trade-off.

## Practice this

Try the [Fibonacci Sequence exercise on Pybites Rust Platform](https://rustplatform.com/fibonacci-sequence) — use `match` with guards to handle base cases, recursion, and invalid input.
