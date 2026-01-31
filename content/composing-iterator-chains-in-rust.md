+++
title = "Composing iterator chains in Rust: from filter to flat_map"
date = 2026-02-05
draft = true
+++

If you've been following along, you've seen `.chars()`, `.filter()`, `.rev()`, and `.collect()`. Now let's put it all together and add a new tool: `.flat_map()`.

This is where Rust's iterator system starts to feel like a superpower.

## The Python version

Here's a common Python pattern — cleaning a string by keeping only alphanumeric characters and lowercasing everything:

```python
cleaned = "".join(c.lower() for c in s if c.isalnum())
```

One line, reads left-to-right (mostly). The generator expression filters and transforms in a single pass. Let's build the same thing in Rust, step by step.

## Step 1: filter characters

You already know how to filter an iterator:

```rust
let alnum: String = "Hello, World!"
    .chars()
    .filter(|c| c.is_alphanumeric())
    .collect();
// "HelloWorld"
```

So far, just like Python's `if c.isalnum()`.

## Step 2: lowercase — and a surprise

Here's where it gets interesting. In Python, `c.lower()` returns a string (a single character). In Rust, `char::to_lowercase()` returns an **iterator**:

```rust
let lower = 'A'.to_lowercase();  // type: ToLowercase (an iterator)
```

Why an iterator for a single character? Because some Unicode characters lowercase into *multiple* characters. The German `ß` uppercases to `SS`, and some characters have similar multi-char lowercase forms. Rust's type system encodes this possibility — it won't let you pretend the result is always one character.

## Enter flat_map

If `.map()` applies a function that returns a single value, `.flat_map()` applies a function that returns an *iterator* and flattens all the results into one stream:

```rust
// .map() would give us an iterator of iterators — not what we want
// .flat_map() flattens them into a single stream of chars
let cleaned: String = "Hello, World!"
    .chars()
    .filter(|c| c.is_alphanumeric())
    .flat_map(|c| c.to_lowercase())
    .collect();
// "helloworld"
```

In Python terms, `.flat_map()` is like a nested comprehension:

```python
# flat_map equivalent
result = [x for item in items for x in transform(item)]
```

Compare with regular `.map()`:

```python
# map equivalent
result = [transform(item) for item in items]
```

The difference: `.map()` wraps each result as-is, `.flat_map()` unpacks each result and concatenates them.

## The full pattern

Now you have all the pieces to build powerful text processing pipelines:

```rust
let text = "Some Input, With Punctuation!";

// Keep only letters, lowercase them, collect into a String
let letters_only: String = text
    .chars()
    .filter(|c| c.is_alphabetic())
    .flat_map(|c| c.to_lowercase())
    .collect();
// "someinputwithpunctuation"
```

Each step in the chain does one thing. The compiler fuses them into a single pass over the data — no intermediate allocations, no temporary vectors. This is called **iterator fusion**, and it's one of Rust's key performance advantages.

## When to use which

Here's a quick reference for the adapter methods you've seen so far:

| Method | What it does | Python equivalent |
|--------|-------------|-------------------|
| `.filter(f)` | Keep elements where `f` returns true | `if` in comprehension |
| `.map(f)` | Transform each element | expression in comprehension |
| `.flat_map(f)` | Transform + flatten | nested comprehension |
| `.rev()` | Reverse the iterator | `reversed()` |
| `.collect()` | Consume into a collection | `list()`, `set()`, `"".join()` |

## Practice this

Try the [Palindrome Check exercise on Pybites Rust Platform](https://rustplatform.com/palindrome-check) — it puts everything together: filtering, lowercasing with `flat_map`, reversing, and comparing strings.

---

*This post is part of a series where we explore Rust concepts through the lens of Python. Follow along at [rsbit.es](https://rsbit.es).*
