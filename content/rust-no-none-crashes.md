+++
title = "Rust Makes None.attribute Crashes Impossible — Your Code Won't Even Compile"
date = 2026-02-19
+++

Every Python developer has seen this traceback:

```
AttributeError: 'NoneType' object has no attribute 'name'
```

The problem is that tests might miss this so it shows up in production, and that could be at 2 am in the morning.

The pattern that causes it is everywhere:

```python
def find_user(user_id):
    return db.get(user_id)  # might return None

user = find_user(42)
print(user.name)  # boom
```

Nothing in Python warns you that `find_user` might return `None`. No type error, no warning, no compile-time check. The code looks perfectly fine — until it isn't.

Tony Hoare, who invented null references, called it his ["billion-dollar mistake"](https://www.infoq.com/presentations/Null-References-The-Billion-Dollar-Mistake-Tony-Hoare/). Every language that has implicit nulls inherits this problem. Python included.

## Rust refuses to compile the bug

Rust does have a None scenario, but it's handled differently. It has `Option<T>` — an enum with exactly two variants:

```rust
enum Option<T> {
    Some(T),  // a value is present
    None,     // no value
}
```

When a function might not have a value to return, it says so in its type signature:

```rust
fn find_user(user_id: u64) -> Option<User> {
    db.get(user_id)
}
```

Fair enough, Pythonistas certainly want to add type hints to express this too:

```python
def find_user(user_id: int) -> Optional[User]:
    return db.get(user_id)
```

Or more modern syntax:

```python
def find_user(user_id: int) -> User | None:
    return db.get(user_id)
```

But here is the key difference: where in Python you're relying on tooling (mypy, ty) to catch this, in Rust using the result type without handling the `None` case, **the code does not compile**:

```rust
let user = find_user(42);
println!("{}", user.name);  // compile error: Option<User> has no field `name`
```

The compiler forces you to acknowledge that the value might not be there:

```rust
match find_user(42) {
    Some(user) => println!("{}", user.name),
    None => println!("User not found"),
}
```

This means no `AttributeError` and no unexpected runtime crash. The bug literally cannot exist in the compiled program.

## It's not just match statements

If `match` on every `Option` sounds tedious, it is — and Rust has ergonomic shortcuts. The `.map()` combinator transforms the inner value while keeping the `Option` wrapper:

```rust
let name: Option<String> = Some("alice".to_string());
let upper = name.map(|n| n.to_uppercase());
// Some("ALICE")

let empty: Option<String> = None;
let upper = empty.map(|n| n.to_uppercase());
// None — the closure never runs, no crash
```

This is an elegant way to express Python's `x.upper() if x is not None else None` which might feel a bit clunky at times.

There's also `.unwrap_or()` for defaults, `.is_some()` for checks, and `if let` for quick pattern matches. The full API has [dozens of combinators](https://doc.rust-lang.org/std/option/enum.Option.html) — all with the advantage of compile-time safety.

## What this means in practice

Think about how many defensive checks you write in Python:

```python
user = find_user(42)
if user is not None:
    print(user.name)

config = load_config("app")
if config is not None:
    apply_settings(config)
```

Each `is not None` check exists because the language can't guarantee the value is there. You're doing the compiler's job manually — and across a larger codebase, it's easy to miss one.

In Rust, the type system tracks presence and absence through every function call, every transformation, every return value. If you forget to handle a `None`, you find out immediately — in your editor, not your error logs.

This isn't just theory. It's the reason Rust programs don't have an entire class of bugs right out of the box.

## Try it yourself

We built a hands-on exercise that lets you practice this pattern. You'll implement three functions that return `Option<T>` — finding values in slices, handling division by zero, and extracting fields from optional structs.

**[Option Handling](https://rustplatform.com/option-handling)**

I hope this gives you a feel for what it's like to write safer code.

---

*If you're a Python developer curious about Rust, our [Rust Platform](https://rustplatform.com) teaches Rust concepts through small, focused exercises — each one bridging what you already know in Python to how Rust does it differently (and often better).*
