+++
title = "Rust's .collect() — the iterator method that confused me (until it didn't)"
date = 2026-02-04
draft = true
+++

When I first started writing Rust coming from Python, I kept seeing `.collect()` at the end of iterator chains. It seemed like magic — one method call that could produce a `Vec`, a `String`, a `HashMap`, or a `HashSet`. How does it know what to build?

## The Python mental model

In Python, you're explicit about what you're building:

```python
chars = list("hello")           # list
unique = set("hello")           # set
joined = "".join(reversed("hello"))  # string
```

Each function (`list`, `set`, `"".join`) tells Python exactly what to produce. In Rust, `.collect()` does all of these — but the *return type* tells it what to build.

## Type-directed collection

Here's the same string `"hello"`, collected into different types:

```rust
let chars: Vec<char> = "hello".chars().collect();       // ['h', 'e', 'l', 'l', 'o']
let unique: HashSet<char> = "hello".chars().collect();  // {'h', 'e', 'l', 'o'}
let back: String = "hello".chars().collect();           // "hello"
```

Same iterator, same `.collect()` call, three different results. The compiler reads the type annotation on the left side and picks the right `FromIterator` implementation. No runtime reflection, no overhead — it's resolved entirely at compile time.

## Turbofish syntax

Sometimes the type can't be inferred from context. Instead of a `let` binding with a type annotation, you can use **turbofish** syntax:

```rust
let back = "hello".chars().collect::<String>();
```

The `::<String>` tells `.collect()` what to produce, inline. It looks odd at first — that's the "turbofish" (`::<>`). You'll see it in iterator chains where the result is passed directly to another function.

## Why this matters

In Python, iterators and generators are lazy, but you always choose how to materialize them. Rust works the same way conceptually — iterators are lazy, and `.collect()` is the moment you say "OK, build the thing." The difference is that Rust's type system figures out *what* to build.

This means you can write a generic function that returns different collection types:

```rust
fn first_n_squares(n: usize) -> Vec<i32> {
    (1..=n as i32).map(|x| x * x).collect()
    // .collect() knows to produce Vec<i32> from the return type
}
```

## Lazy until consumed

A common mistake from Python devs: forgetting that iterator adapters are lazy. This does nothing:

```rust
let nums = vec![1, 2, 3];
nums.iter().map(|x| println!("{x}"));  // WARNING: iterators are lazy
```

The compiler will warn you: `unused Map that must be used`. You need a consumer — `.collect()`, `.count()`, `.for_each()`, or a `for` loop — to actually run the chain. This is stricter than Python, where generators are also lazy but the compiler won't warn you about unused ones.

## The reverse trick

One pattern that comes up often: reversing a string. In Python it's `s[::-1]`. In Rust, you combine `.chars()` with `.rev()` (which reverses any double-ended iterator) and `.collect()` to build the result:

```rust
let reversed: String = "hello".chars().rev().collect();
// "olleh"
```

Three methods, zero allocations beyond the final `String`. The iterator pipeline processes each character in a single pass.

## Practice this

Try the [Reverse String exercise on RsBit.es](https://rustplatform.com/reverse-a-string) — a clean exercise to practice `.collect()` and iterator adapters.

---

*This post is part of a series where we explore Rust concepts through the lens of Python. Follow along at [rsbit.es](https://rsbit.es).*
