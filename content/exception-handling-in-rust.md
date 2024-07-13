+++
title = "Exception handling in Rust"
date = 2024-07-10
+++

I am working on an AWS Lambda function to validate Rust code submitted from our coding platform. It led to some exception handling code, which I found interesting to compare with Python.

## Adding exception to running an external command

Here is an example of exception handling I added to my lambda function to run a cargo command in a temporary directory. The function returns the output of the command if it is successful, or an error message if it fails:

```rust
async fn run_cargo_command(temp_dir_path: &Path) -> Result<Output, String> {
    match Command::new("cargo")
        .arg("test")
        .arg("--verbose")
        .current_dir(temp_dir_path)
        .output()
        .await
    {
        Ok(output) => {
            if output.status.success() {
                Ok(output)
            } else {
                Err(format!(
                    "Command executed with errors: {}",
                    String::from_utf8_lossy(&output.stderr)
                ))
            }
        }
        Err(e) => Err(format!(
            "Failed to execute command: {}. Is 'cargo' installed and accessible in your PATH?",
            e
        )),
    }
}
```

Here is the equivalent code in Python:

```python
import subprocess

def run_cargo_command(temp_dir_path):
    try:
        output = subprocess.run(
            ["cargo", "test", "--verbose"],
            cwd=temp_dir_path,
            capture_output=True,
            check=True,
        )
        return output
    except subprocess.CalledProcessError as e:
        raise Exception(f"Command executed with errors: {e.stderr}")
    except FileNotFoundError as e:
        raise Exception(
            "Failed to execute command: Is 'cargo' installed and accessible in your PATH?"
        )
```

## Rust and Python Error Handling Comparison

- In Rust, we use the `Result` type (Ok/Err) to represent success or failure, while in Python, we use exceptions.

- Rust requires explicit handling of both success and failure cases, while Python allows for more flexible error handling.

- Rust's error handling is enforced at compile time, while Python's error handling is checked at runtime.

- Rust's pattern matching allows for concise and clear error handling, while Python's exception handling requires less boilerplate, it's more flexible, but can also lead to more runtime errors (because they are detected later).

- In Python you have to specifically catch the `FileNotFoundError` exception (and fall back to a generic `Exception`), while in Rust, it is handled by the `Err` case of the `match` statement which could include any error that occurs during the execution of the command.

## Conclusion

Python's exception handling allows for rapid and flexible development, making it easier to write code quickly. However, this same flexibility can lead to more runtime errors because errors are often detected later (at runtime) and it's easier to overlook proper error handling.

Rust, on the other hand, enforces more rigorous error handling at compile time, leading to more reliable and predictable code, though it can be more verbose and require more upfront effort.

This is just a small example, when I get into more nuances of error handling in Rust, I will follow up with a more detailed post. I also understand there are some common crates you can use like `anyhow` to make error handling in Rust more concise and flexible. To be continued ...
