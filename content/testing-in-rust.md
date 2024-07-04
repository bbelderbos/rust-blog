+++
title = "How to write unit tests in Rust"
date = 2024-07-03
+++

In Python you can use `unittest` (Standard Library) or `pytest` (PyPI) to write tests. In Rust, you can use the `#[cfg(test)]` and `#[test]` attributes to write tests. Let's explore how ...

## Writing a test

To get some boilerplace code, make a library project with `cargo new mylib --lib` and you get this:

```shell
√ rust  $ cargo new --lib testproject
    Creating library `testproject` package
note: see more `Cargo.toml` keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html
√ rust  $ cat testproject/src/lib.rs
pub fn add(left: usize, right: usize) -> usize {
    left + right
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = add(2, 2);
        assert_eq!(result, 4);
    }
}
```

- `#[cfg(test)]` is a conditional compilation attribute that tells the compiler to only compile the module when running tests.

- `mod tests` is a module that contains all the tests.

- `use super::*;` imports all the functions from the parent module.

- `#[test]` is an attribute that tells the compiler that the function is a test, you prepend it to each test function.

- `assert_eq!` is a macro that checks if the two arguments are equal.

That's it. Now you can run `cargo test` to run the tests. If you want to run a specific test, you can run `cargo test it_works` (similar to `pytest -k`).

## Writing some tests for my CLI alarm project

This both a good and bad project to demo this. Bad because it uses system audio which is hard to test. Good because it's a simple project and has one function I am interested in testing for this article.

Here is the code:

```rust
...
...
pub fn humanize_duration(duration: Duration) -> String {
    let secs = duration.as_secs();
    if secs < 60 {
        format!("{} second{}", secs, if secs == 1 { "" } else { "s" })
    } else {
        let mins = secs / 60;
        let remaining_secs = secs % 60;
        if remaining_secs > 0 {
            format!(
                "{} minute{} and {} second{}",
                mins,
                if mins == 1 { "" } else { "s" },
                remaining_secs,
                if remaining_secs == 1 { "" } else { "s" }
            )
        } else {
            format!("{} minute{}", mins, if mins == 1 { "" } else { "s" })
        }
    }
}
...
...
```

Copying above boilerplace over I got to write these tests:

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use std::time::Duration;

    #[test]
    fn test_short_durations() {
        assert_eq!(humanize_duration(Duration::from_secs(0)), "0 seconds");
        assert_eq!(humanize_duration(Duration::from_secs(1)), "1 second");
        assert_eq!(humanize_duration(Duration::from_secs(30)), "30 seconds");
    }

    #[test]
    fn test_exact_minute_durations() {
        assert_eq!(humanize_duration(Duration::from_secs(60)), "1 minute");
        assert_eq!(humanize_duration(Duration::from_secs(180)), "3 minutes");
        assert_eq!(humanize_duration(Duration::from_secs(3600)), "60 minutes");
    }

    #[test]
    fn test_minute_and_second_durations() {
        assert_eq!(
            humanize_duration(Duration::from_secs(61)),
            "1 minute and 1 second"
        );
        assert_eq!(
            humanize_duration(Duration::from_secs(122)),
            "2 minutes and 2 seconds"
        );
        assert_eq!(
            humanize_duration(Duration::from_secs(333)),
            "5 minutes and 33 seconds"
        );
    }

    #[test]
    fn test_edge_cases() {
        assert_eq!(humanize_duration(Duration::from_secs(59)), "59 seconds");
        assert_eq!(
            humanize_duration(Duration::from_secs(119)),
            "1 minute and 59 seconds"
        );
        assert_eq!(
            humanize_duration(Duration::from_secs(3599)),
            "59 minutes and 59 seconds"
        );
    }
}
```

I could have grouped them all into one test, but I wanted:
- To show how you can write multiple tests.
- To have better naming for each test for readability and targeting.

On the other hand having a test function for each test would be way too verbose.

Unfortunately there is no `parametrize` feature in Rust like in pytest, so this was my "workaround" for now.

Running `cargo test` I get:

```shell
$ cargo test
...
running 4 tests
test tests::test_minute_and_second_durations ... ok
test tests::test_edge_cases ... ok
test tests::test_exact_minute_durations ... ok
test tests::test_short_durations ... ok

test result: ok. 4 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

$ cargo test edge_ca
...
running 1 test
test tests::test_edge_cases ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 3 filtered out; finished in 0.00s
```

## Unittest vs integration tests

This has been an example of a unit test: a test that tests a single piece of code, often a single function.

You can also write integration tests in Rust. Integration tests are tests that test the interaction between multiple modules or components.

You can write integration tests in a `tests` directory, I will show here when I cross that bridge ...

## Conclusion

The `#[cfg(test)]` attribute is a conditional compilation attribute that instructs the Rust compiler to only compile the annotated module when running tests.

Within this module, the `#[test]` attribute is used to mark functions as tests, and the `assert_eq!` macro is employed to check if two values are equal.

It is common practice to bundle unit tests within the same module as the code being tested. Integration tests, however, are typically placed in a dedicated module within the `tests` directory.

Rust does not have a built-in `parametrize` feature like pytest. To manage multiple test cases, you can either write individual test functions for each case or group similar tests within a few functions to improve naming and targeting options.
