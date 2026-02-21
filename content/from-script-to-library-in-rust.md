+++
title = "From script to library in Rust"
date = 2024-06-29
+++

In Rust you can write a script or a library. Turning your code into the latter is useful when you want to reuse the code in the script in other projects.

Compare it to a script vs a package in Python. In Python you can write a script and then turn it into a package by adding an `__init__.py` file. In Rust you can write a script and then turn it into a library by moving the code into a library project. Let's see how to do this ...

## Writing a script

Let's start by writing the simplest script that prints a greeting to the console. And a main function that calls the `hello` function with a name:

Create a new project called `project`:

```bash
cargo new project
```

And edit the `src/main.rs` file to contain the following code:

```rust
fn main() {
    hello("Alice");
}

fn hello(name: &str) {
    println!("Hello, {}!", name);
}
```

This script defines a `hello` function that takes a name as an argument and prints a greeting to the console. The `main` function calls the `hello` function with the name "Alice" (no command line arguments, this is for example's sake).

## Turning the script into a library

To turn the script into a library, we need to create a new library project and move the code from the script into the library. We can do this by running the following commands:

```bash
cargo new --lib my_library
mv project/src/main.rs my_library/src/lib.rs
```

The `--lib` flag tells Cargo to create a library project instead of a binary project.

This will create a new library project called `my_library` and move the code from the script into the library. The `lib.rs` file is the entry point for the library, and it contains the code that will be executed when the library is used.

## Using the library

To use the library in the first project, we need to add it as a dependency in the `Cargo.toml` file of the project. We can do this by adding the following line to the `Cargo.toml` file of the project:

```toml
[dependencies]
my_library = { path = "../my_library" }
```

Normally you would list one or more crates from crates.io in the `dependencies` section, but in this case we are using a relative path to the library project.

We can now use the library in the project by importing it and calling the hello function. Create `main.rs` again (it was previously moved to the library) under `src` in the project and add the following code to it:

```rust
use my_library;

fn main() {
    my_library::hello("Tim");
}
```

The path works, because [ALE](/rust-analyzer-ale-errors-while-coding) complains about the next thing:

```bash
src/main.rs|4 col 17-21 error| E0603: function `hello` is private private function
```

Rust makes functions private by default. So back in the library I need to make the function public explicitly by adding `pub` in front of it in `lib.rs`:

```rust
pub fn hello(name: &str) {
    println!("Hello, {}!", name);
}
```

And then it works:

```bash
$ cargo run -q
warning: function `main` is never used
 --> /Users/pybob/code/rust/lib-example/my_library/src/lib.rs:1:4
  |
1 | fn main() {
  |    ^^^^
  |
  = note: `#[warn(dead_code)]` on by default

Hello, Tim!
```

I do get this warning that the `main` function in the library is never used, which makes sense, because unlike a binary project, the library is not an executable. Therefor I can remove the `main` function from the library, no more warnings:

```bash
$ cargo run -q
Hello, Tim!
```

Similar to Python where you can do `import pathlib` as well as `from pathlib import Path`, you can do the same in Rust. You can import the whole library with `use my_library;` or just the `hello` function with `use my_library::hello;`.

```rust
use my_library::hello;

fn main() {
    hello("Tim");
}
```

And that'll work equally well.

Sometimes people opt for the first option, because it's more explicit where the function comes from (`my_library::hello` vs `hello`). But in this case it's a bit overkill, because there's only one function in the library.

## Practice This

Practice modules and visibility on the Pybites Rust Platform:

- [Module Basics](https://rustplatform.com/module-basics)
- [Visibility Rules](https://rustplatform.com/visibility-rules)
- [Use and Paths](https://rustplatform.com/use-and-paths)

## Conclusion

We learned how to make a library as opposed to a script (binary) in Rust (which is what I have mostly done up until this point). This is useful when you want to reuse the code in the script in other projects.

We also learned how to use the library in another project and the fact that Rust makes module functions private by default (another example where it's more strict than Python!)

This is a good thing because it forces you to think about what you want to expose to the outside world.

We also learned about the two ways to import functions from a library: importing the whole library or just the function you need. And lastly the fact that libraries don't have a `main` function, because they are not executables.

Now you know how to write libraries in Rust so you can write code that is easier to reuse and maintain. 😍 🎉 📈
