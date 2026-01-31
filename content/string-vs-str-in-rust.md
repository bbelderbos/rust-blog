+++
title = "String vs &str in Rust: what Python devs need to know"
date = 2026-02-02
draft = true
+++

In Python, there's one string type: `str`. You create strings, pass them around, and never think about who "owns" them.

```python
def greet():
    return "Hello, World!"
```

Simple. In Rust, this same task forces you to make a decision you've never had to make before: **which string type?**

## Two string types

Rust has two main string types, and the difference matters:

**`&str`** is a *string slice* — a read-only view into string data. String literals like `"hello"` are `&str` by default. Think of it as a window into someone else's string. You can look, but you can't modify or take it with you.

**`String`** is an *owned*, heap-allocated, growable string. It's the one you use when you need to create, modify, or return string data. Closer to what Python's `str` does behind the scenes.

```rust
let slice: &str = "I'm borrowed";           // stored in the binary, read-only
let owned: String = String::from("I'm owned"); // heap-allocated, you own it
```

## Why does this matter?

In Python, the runtime manages memory for you via garbage collection. You never worry about whether a string is "owned" or "borrowed" — everything is reference-counted behind the scenes.

Rust doesn't have a garbage collector. Instead, it uses an **ownership system**: every value has exactly one owner, and when that owner goes out of scope, the memory is freed. This means you need to be explicit about whether you're passing ownership or just lending a reference.

When a function returns a string, the caller needs to own that data. You can't return a `&str` pointing to a local variable — that variable is about to be destroyed:

```rust
// This won't compile — the String is dropped at the end of the function,
// so the reference would dangle
fn bad() -> &str {
    let s = String::from("hello");
    &s  // ERROR: s is dropped here
}

// This works — we return the owned String itself
fn good() -> String {
    String::from("hello")  // ownership transferred to caller
}
```

## Converting between them

You'll constantly convert between `&str` and `String`. Here are the three common ways:

```rust
let s1: String = "hello".to_string();       // .to_string()
let s2: String = String::from("hello");     // String::from()
let s3: String = "hello".into();            // .into() (type must be inferrable)
```

Going the other direction is free — `String` automatically dereferences to `&str`:

```rust
fn print_it(s: &str) {
    println!("{s}");
}

let owned = String::from("hello");
print_it(&owned);  // &String coerces to &str automatically
```

## The rule of thumb

- Use `&str` for function *parameters* when you just need to read the string
- Use `String` for function *return values* and when you need to own or modify the data

This pattern shows up everywhere in Rust, not just with strings. It's the first taste of Rust's ownership model — and once it clicks, a lot of Rust suddenly makes sense.

## Practice this

Try the [Hello World exercise on Pybites Rust Platform](https://rustplatform.com/hello-world) — it's a gentle first step into returning owned strings from functions.
