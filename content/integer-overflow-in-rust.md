+++
title = "Integer overflow in Rust: why your Python instincts will mislead you"
date = 2026-02-09
draft = true
+++

Here's something that works perfectly in Python:

```python
import math
print(math.factorial(100))
# 93326215443944152681699238856266700490715968264381621468592963895...
```

A 158-digit number. No problem. Python integers grow as large as memory allows.

Now try the equivalent in Rust:

```rust
fn factorial(n: u64) -> u64 {
    match n {
        0 | 1 => 1,
        _ => n * factorial(n - 1),
    }
}

println!("{}", factorial(21));  // PANIC in debug mode!
```

`factorial(20)` works fine — it returns 2,432,902,008,176,640,000. But `factorial(21)` overflows a `u64`. In debug mode, Rust **panics**. Your program crashes rather than giving you a wrong answer.

## Fixed-width integers

Every Rust integer has a fixed size:

| Type | Bytes | Max value |
|------|-------|-----------|
| `u8` | 1 | 255 |
| `u32` | 4 | ~4.3 billion |
| `u64` | 8 | ~18.4 quintillion |
| `u128` | 16 | ~3.4 × 10^38 |

Python's `int` is a heap-allocated object that grows dynamically. That's convenient, but it costs: each integer carries overhead for memory management and variable-length storage. Rust's integers live on the stack in a fixed number of bytes — fast and predictable.

The trade-off is that *you* need to pick the right size. For most things, `i32` (signed) or `u64` (unsigned) is fine. But when numbers grow fast — like factorials, powers, or combinatorics — you hit the ceiling.

## Debug vs release: different behavior

This is a subtlety that surprises many newcomers:

- **Debug mode** (`cargo run`, `cargo test`): overflow **panics**. This is a safety net — you find the bug immediately.
- **Release mode** (`cargo run --release`): overflow **wraps around** silently, using two's complement. `u8::MAX + 1` becomes `0`.

This means a bug could hide in release builds that crashes in debug builds. If you need explicit control, Rust provides methods:

```rust
let a: u64 = u64::MAX;
a.checked_mul(2)    // Returns None on overflow
a.saturating_mul(2) // Returns u64::MAX (clamps)
a.wrapping_mul(2)   // Wraps around explicitly
```

These make overflow handling a deliberate choice rather than an accident.

## Ranges: Rust's range()

If you solve factorial iteratively, you'll use Rust's range syntax:

```rust
for i in 1..5 {
    print!("{i} ");  // 1 2 3 4 (exclusive end)
}

for i in 1..=5 {
    print!("{i} ");  // 1 2 3 4 5 (inclusive end)
}
```

`1..5` is like Python's `range(1, 5)`. `1..=5` includes the upper bound — in Python you'd write `range(1, 6)`.

The nice thing: ranges are iterators, so you get all the iterator methods for free. You can `.map()`, `.filter()`, `.fold()`, or `.product()` a range just like any other iterator.

## Or-patterns: combining match arms

One more small but useful pattern. When multiple values should produce the same result:

```rust
match n {
    0 | 1 => 1,       // matches 0 OR 1
    _ => n * factorial(n - 1),
}
```

The `|` combines patterns — cleaner than writing two arms with identical bodies. Works with any patterns, not just literals.

## Practice this

Try the [Factorial exercise on Pybites Rust Platform](https://rustplatform.com/factorial) — implement factorial and feel the difference between Python's limitless ints and Rust's fixed-width types.
