+++
title = "Iterating over characters in Rust (it's not like Python)"
date = 2026-02-03
draft = true
+++

In Python, strings are sequences. You can index them, slice them, and loop over characters directly:

```python
s = "hello"
print(s[0])       # 'h'
print(s[1:3])     # 'el'
for c in s:
    print(c)
```

Coming to Rust, you might try the same thing:

```rust
let s = "hello";
println!("{}", s[0]);  // ERROR: cannot index into a string
```

This is one of the first surprises for Python developers. Let's understand why, and what to do instead.

## Why you can't index Rust strings

Rust strings are **UTF-8 encoded**. That means a single character might take 1, 2, 3, or 4 bytes. The string `"café"` is 5 bytes long, not 4 — the `é` takes 2 bytes.

If `s[2]` returned the byte at position 2, you'd get half of a character. Rust refuses to let you do something that could silently produce garbage, so indexing is simply not allowed on strings.

Python hides this complexity from you. Under the hood, CPython uses a flexible internal representation (Latin-1, UCS-2, or UCS-4 depending on the content), but you never see it. In Rust, the encoding is part of the contract.

## `.chars()` — the iterator approach

Instead of indexing, you use `.chars()` to get an iterator over Unicode characters:

```rust
for c in "hello".chars() {
    println!("{c}");  // prints h, e, l, l, o
}
```

This iterator yields `char` values — Rust's type for a Unicode scalar value. Each `char` is always 4 bytes internally (a `u32`), regardless of how many bytes it takes in the UTF-8 string.

## Chaining iterator methods

Here's where Rust gets interesting. Instead of writing explicit loops with mutable counters, you chain methods on the iterator:

```python
# Python: count alphabetic characters
count = sum(1 for c in s if c.isalpha())
```

```rust
// Rust: same thing with iterator chaining
let count = s.chars()
    .filter(|c| c.is_alphabetic())
    .count();
```

The `.filter()` method takes a **closure** — Rust's version of Python's `lambda`. The `|c|` syntax defines the parameter, and the body is the expression after it. Only elements where the closure returns `true` pass through.

The key insight: **nothing runs until you consume the iterator**. Methods like `.filter()` and `.map()` are lazy — they just set up a pipeline. It's `.count()`, `.collect()`, or a `for` loop that actually drives the computation. This is similar to Python generators, but enforced at the type level.

## `char` methods vs `str` methods

In Python, string methods like `.isalpha()`, `.isdigit()`, and `.lower()` work on the whole string. In Rust, these are methods on *individual characters*:

```rust
'A'.is_alphabetic()    // true
'3'.is_numeric()       // true
'!'.is_alphanumeric()  // false
```

This makes sense once you're thinking in iterators — you're processing one character at a time, applying transformations and filters as the data flows through the chain.

## Practice this

Try the [Count Vowels exercise on Pybites Rust Platform](https://rustplatform.com/vowel-counter) — it's a focused exercise on iterating over characters and filtering with closures.

---

*This post is part of a series where we explore Rust concepts through the lens of Python. Follow along at [rsbit.es](https://rsbit.es).*
