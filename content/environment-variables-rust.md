+++
title = "How to handle environment variables in Rust"
date = 2024-06-13
+++

In this article, I will share how to isolate your environment variables from production code using the `dotenv` crate in Rust.

## Why is this important? 🤔

As we can read in The Twelve-Factor App / III. Config section you want to separate config from code:

> Apps sometimes store config as constants in the code. This is a violation of twelve-factor, which requires strict separation of config from code.

See [The twelve-factor app - III. Config](https://12factor.net/config) for more details.

Basically, you want to be able to make config changes independently from code changes. 💡

We also want to hide secret keys and API credentials! Notice that git is very persistent (see [this PyCon talk](https://www.youtube.com/watch?v=2uaTPmNvH0I) for example) so it’s important to get this right from the start.

## Loading environment variables in Rust

You can load in environment variables like this in Rust:

```rust
use std::env;

let my_var = env::var("MY_VAR").expect("MY_VAR must be set");
```

But that requires you to set the environment variables before running your program (`export MY_VAR=my_value` from the command line). This is not ideal for production code and even for local development, it can be cumbersome.

It's common to keep a local `.env` file with your environment variables (don't forget to add this file to your `.gitignore`!)

## Using the `dotenv` crate 📈

Researching how you can do this in Rust, I stumbled upon the `dotenv` crate, which makes handling environment variables straightforward.

First, add the crate to your `Cargo.toml`:

```toml
[dependencies]
dotenv = "0.15.0"
```

Secondly, you create an `.env` file in the root of your project:

```bash
MY_VAR=my_value
```

Again it’s important that you ignore this file with git, otherwise, you might end up committing sensitive data to your repo/project. 😱

## Ignoring `.env` in git

Not sure what the Rust standard is, a [standard Rust .gitignore file](https://github.com/github/gitignore/blob/main/Rust.gitignore) does not include the `.env` pattern, [Python's one](https://github.com/github/gitignore/blob/main/Python.gitignore) does.

What I usually do (in Python) is commit an empty `.env-example` (or `.env-template`) file so other developers know what they should set.

So a new developer (or me checking out the repo on another machine) can do a `cp .env-template .env` and populate the variables. As the (checked out) `.gitignore` file contains `.env`, git won’t show it as a file to be staged for commit.

## Example using `dotenv`

To load in the variables from this file, we use a few lines of code:

```rust
extern crate dotenv;
use dotenv::dotenv;
use std::env;

fn main() {
    dotenv().ok();

    let background_img = env::var("THUMB_BACKGROUND_IMAGE").expect("THUMB_BACKGROUND_IMAGE must be set");
    let font_file = env::var("THUMB_FONT_TTF_FILE").expect("THUMB_FONT_TTF_FILE must be set");

    println!("Background Image: {}", background_img);
    println!("Font File: {}", font_file);
}
```

- `dotenv().ok()` loads the environment variables from the `.env` file.
- `.expect` is used to handle the case where the environment variable is not set.

With this setup, you can now access your environment variables using `env::var`:

```bash
$ cargo run -q
thread 'main' panicked at src/main.rs:8:61:
THUMB_BACKGROUND_IMAGE must be set: NotPresent
```

This is because we didn't set the environment variables yet in `.env`, doing so:

```bash
# .env
THUMB_BACKGROUND_IMAGE=some_image.jpg
THUMB_FONT_TTF_FILE=some_font.ttf
```

Now it works as expected 🎉

```bash
$ cargo run -q
Background Image: some_image.jpg
Font File: some_font.ttf
```

This is actually pretty similar to Python using the `python-dotenv` library. 🐍

```python
from dotenv import load_dotenv
import os

load_dotenv()

background_img = os.getenv("THUMB_BACKGROUND_IMAGE")
font_file = os.getenv("THUMB_FONT_TTF_FILE")
```

For boolean values, a common requirement for configuration settings like `DEBUG`, you can use `env::var` and parse the string to a boolean like this:

```rust
let is_debug: bool = env::var("DEBUG").map(|v| v == "true").unwrap_or(false);
...
println!("Debug: {}", is_debug);
```

- This works when setting `DEBUG=true` or `DEBUG=false` in your `.env` file.
- `.map` is used to convert the string to a boolean.
- The final `unwrap_or` is used to handle the case where the environment variable is not set or contains an invalid value.

## Practice This

The `.map` and `.unwrap_or` patterns used in this post are core to working with `Option` in Rust. Practice them on the Pybites Rust Platform:

- [Option Handling](https://rustplatform.com/option-handling)
- [Option Combinators](https://rustplatform.com/option-combinators)

## Conclusion

Handling environment variables in Rust is straightforward using the `dotenv` crate. This approach keeps your configuration separate from your code, making it easier to manage and secure.

I hope this article helps you to keep your environment variables safe and secure. 🛡️

Happy coding! 🦀

_This article is an adaption from our Python article: [How to handle environment variables in Python](https://pybit.es/articles/how-to-handle-environment-variables-in-python/)._
