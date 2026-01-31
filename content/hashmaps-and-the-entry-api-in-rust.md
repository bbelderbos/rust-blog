+++
title = "HashMaps and the entry API in Rust"
date = 2026-02-06
draft = true
+++

If you're coming from Python, `dict` is probably your most-used data structure. Need to count things? `Counter`. Need to group things? `defaultdict`. Need to look things up? Plain `dict`.

Rust's equivalent is `HashMap` — and while it doesn't have `Counter` or `defaultdict` built in, its **entry API** is so good you won't miss them.

## HashMap basics

In Python, `dict` is a builtin — you just use it. In Rust, `HashMap` lives in the standard library but needs an import:

```rust
use std::collections::HashMap;

let mut scores = HashMap::new();
scores.insert("Alice", 10);
scores.insert("Bob", 20);

println!("{:?}", scores);
// {"Alice": 10, "Bob": 20}
```

Two things to note:
1. **`mut`** — HashMaps are immutable by default. Want to add or update entries? You need `mut`.
2. **`use`** — Unlike Python where `dict` is always available, Rust's `HashMap` must be imported from `std::collections`.

## Reading values

In Python you'd use `d[key]` (which raises `KeyError` if missing) or `d.get(key)` (which returns `None`). Rust mirrors the safer approach:

```rust
let score = scores.get("Alice");  // Returns Option<&i32>
```

This returns `Option<&V>` — either `Some(&value)` or `None`. No panics, no exceptions. You're forced to handle the "key not found" case, which is exactly what Rust wants.

## The entry API — counting and accumulating

Here's where Rust shines. In Python, counting word occurrences looks like this:

```python
counts = {}
for word in words:
    counts[word] = counts.get(word, 0) + 1
```

Or more idiomatically:

```python
from collections import Counter
counts = Counter(words)
```

Rust doesn't have `Counter`, but it has something arguably more flexible — the **entry API**:

```rust
let mut counts = HashMap::new();
for word in words {
    *counts.entry(word).or_insert(0) += 1;
}
```

This reads as: "look up `word` in the map. If it's not there, insert `0`. Either way, give me a mutable reference to the value, and increment it."

Let's break it down:

- **`.entry(key)`** returns an `Entry` enum — either `Occupied` (key exists) or `Vacant` (key doesn't)
- **`.or_insert(default)`** inserts the default value if vacant, then returns `&mut V` — a mutable reference to the value
- **`*`** dereferences that reference so you can modify the actual value in the map
- **`+= 1`** increments

The `*` dereference is the part that trips up Python devs. In Python, `counts[word] += 1` "just works" because Python handles the indirection for you. In Rust, you're working with a reference to the value inside the HashMap, so you need to explicitly dereference it.

## Other entry patterns

The entry API isn't just for counting. You can also use it for grouping:

```rust
let mut groups: HashMap<char, Vec<&str>> = HashMap::new();
for word in ["apple", "banana", "avocado", "blueberry"] {
    let first_char = word.chars().next().unwrap();
    groups.entry(first_char).or_insert_with(Vec::new).push(word);
}
// {'a': ["apple", "avocado"], 'b': ["banana", "blueberry"]}
```

`.or_insert_with(Vec::new)` is like `.or_insert()` but takes a closure — useful when the default is expensive to create. This is Rust's equivalent of `defaultdict(list)`.

## Iterating over a HashMap

Just like Python's `for k, v in d.items()`:

```rust
for (word, count) in &counts {
    println!("{word}: {count}");
}
```

One difference: HashMap iteration order is **not guaranteed** in Rust (same as Python's `dict` before 3.7). If you need ordered output, collect into a `Vec` and sort.

## Practice this

Try the [Word Count exercise on Pybites Rust Platform](https://rustplatform.com/word-count) — build a word frequency counter from scratch using `HashMap` and the entry API.

---

*This post is part of a series where we explore Rust concepts through the lens of Python. Follow along at [rsbit.es](https://rsbit.es).*
