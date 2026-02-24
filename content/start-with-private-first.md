+++
title = "Start with private first!"
date = 2026-02-24
+++


Rust and Python make opposite bets about what developers will do with access to internals. Understanding *why* teaches you something deeper than syntax — it reveals two coherent but competing philosophies about how software should be built.

## The Python Default: Open Until Proven Closed

In Python, everything is public unless you say otherwise. Write a function, a class, a module — it's accessible. The community uses naming conventions (`_private`, `__mangled`) to signal intent, but the runtime enforces nothing.

```python
class BankAccount:
    def __init__(self, balance: float):
        self.balance = balance       # public (by default)
        self._owner = "Alice"        # "private" by convention
        self.__pin = 1234            # name-mangled, but still reachable

account = BankAccount(100.0)
print(account.balance)              # works
print(account._owner)               # works (just rude)
print(account._BankAccount__pin)    # works (name mangling, not privacy)
```

Python trusts developers. The Zen of Python says *"We're all consenting adults here."* The underscore is a handshake, not a lock. This keeps the language flexible and great for prototyping — you can reach in and patch anything, which is exactly what makes Python powerful for testing, debugging, and dynamic metaprogramming.

Python does offer `@property` for more controlled access — you can expose a read-only view or add validation on set. But it's opt-in, and only as disciplined as the developer who reaches for it.

## The Rust Default: Closed Until Proven Open

Rust inverts this completely. Every field, function, struct, and module is **private by default**. You must explicitly opt into visibility with `pub`. This isn't a style convention — the compiler enforces it.

```rust
mod bank {
    pub struct BankAccount {
        pub balance: f64,   // public field
        owner: String,      // private — inaccessible outside this module
        pin: u32,           // private — compiler error if accessed externally
    }

    impl BankAccount {
        pub fn new(balance: f64, owner: &str, pin: u32) -> Self {
            BankAccount {
                balance,
                owner: owner.to_string(),
                pin,
            }
        }

        pub fn balance(&self) -> f64 {
            self.balance
        }

        // Private helper — not part of the public API
        fn validate_pin(&self, attempt: u32) -> bool {
            self.pin == attempt
        }
    }
}

fn main() {
    let account = bank::BankAccount::new(100.0, "Alice", 1234);
    println!("{}", account.balance());   // works
    // println!("{}", account.owner);    // compile error: field `owner` is private
    // account.validate_pin(1234);       // compile error: method `validate_pin` is private
}
```

There's no workaround. No `account._BankAccount__pin` escape hatch. The compiler treats private fields as genuinely inaccessible from outside the module.

## Two Different Bets

These aren't arbitrary design choices. Each reflects a deliberate philosophy.

**Python bets on developer judgment.** Trust people to know when not to touch `_private` things. Make everything reachable because the flexibility is worth the occasional footgun. This pays off in Python's dynamism — monkey-patching, mocking, metaprogramming, and REPL exploration all rely on nothing being truly hidden.

**Rust bets on explicit contracts.** Every `pub` marker is a promise: *"I intend for this to be part of my public API."* Every missing `pub` is equally intentional: *"This is an implementation detail — I reserve the right to change it."* The compiler holds you to those promises.

The practical impact is significant. In Python you often have to read documentation (or source code) to know if something is "really" public. In Rust, the compiler tells you directly: `pub` means yes, no annotation means no.

## What This Means in Practice

When you're writing a Rust library, you start closed and open up deliberately. Your internal helpers, intermediate state, and implementation details stay invisible to callers by default. Refactoring internals doesn't risk breaking users — they couldn't see the internals to begin with.

Privacy also complements Rust's ownership system. When fields are private, all mutations flow through controlled methods — which gives the borrow checker cleaner invariants to reason about. This is part of what makes Rust's fearless concurrency possible, alongside the ownership and borrowing rules themselves.

In Python, it's the reverse. You start open and add `_` as you learn what's an implementation detail. The discipline has to come from the developer, not the tooling.

Neither approach is wrong. Python's openness is a feature — it enables the dynamic, expressive style Python is loved for. Rust's privacy-by-default is also a feature — it enables fearless refactoring and clearly bounded APIs.

## Key Takeaways

- In Python, everything is public unless prefixed with `_` (convention only — not enforced)
- In Rust, everything is private unless marked `pub` (compiler-enforced)
- Python trusts developer discipline; Rust encodes the contract in the type system
- Rust's `pub` markers are explicit API surface declarations — marking something public is a deliberate decision
- Python's openness enables powerful dynamic patterns; Rust's privacy enables fearless refactoring

## Try It Yourself

Take a small Python class you've written and mentally port it to Rust. Ask yourself: which fields and methods would you mark `pub`? Which would you leave private? That exercise often reveals how much of your "API" is actually implementation detail that you'd rather hide — something Python's defaults let slip through.

---

*Coming from Python and exploring Rust? The privacy model is one of the first things that feels foreign — but once it clicks, you'll start seeing your Python code differently too.*

Practice this with a hands-on exercise: [Module Basics on RustPlatform](https://rustplatform.com/module-basics)

