+++
title = "Writing a Rust code validation API"
date = 2024-07-12
+++

Today I managed to add support for Rust exercises [on our platform](https://codechalleng.es/). I struggled with getting `cargo test` to work on AWS Lambda for a week (talking about [tunnel vision](https://pybit.activehosted.com/social/918317b57931b6b7a7d29490fe5ec9f9.509)), so it was time to pivot to a different approach.

It turns out that I needed a bit more resource power and Heroku did it for me. So I dropped AWS Gateway API + AWS Lambda (what we normally use to validate coding exercises) and wrote my first Rust API to run tests on code.

The final version is a bit more involved, because it gets the code from our platform's API. To keep it simple, I omitted this part here.

## Using Axtix-web to build an API

Here is the code:

```rust
use actix_web::{web, App, HttpRequest, HttpResponse, HttpServer, Responder};
use serde::{Deserialize, Serialize};
use std::env;
use std::fs;
use std::io::Write;
use std::process::Command;
use tempfile::tempdir;

#[derive(Deserialize)]
struct Request {
    user_code: String,
    test_code: String,
}

#[derive(Serialize)]
struct Response {
    success: bool,
    output: String,
}

async fn execute_code(req: web::Json<Request>, http_req: HttpRequest) -> impl Responder {
    let api_key = env::var("API_KEY").expect("API_KEY not set");

    if let Some(key) = http_req.headers().get("x-api-key") {
        if key.to_str().unwrap_or("") != api_key {
            return HttpResponse::Unauthorized().body("Invalid API key");
        }
    } else {
        return HttpResponse::Unauthorized().body("Missing API key");
    }

    let user_code = &req.user_code;
    let test_code = &req.test_code;

    let dir = tempdir().unwrap();
    let dir_path = dir.path();

    let main_path = dir_path.join("src/main.rs");
    fs::create_dir_all(main_path.parent().unwrap()).unwrap();
    let mut main_file = fs::File::create(&main_path).unwrap();
    main_file
        .write_all(
            format!(
                r#"
            {}

            #[cfg(test)]
            mod tests {{
                use super::*;
                {}
            }}
            "#,
                user_code, test_code
            )
            .as_bytes(),
        )
        .unwrap();

    let cargo_toml_path = dir_path.join("Cargo.toml");
    let mut cargo_toml_file = fs::File::create(cargo_toml_path).unwrap();
    cargo_toml_file
        .write_all(
            br#"
        [package]
        name = "temp_project"
        version = "0.1.0"
        edition = "2021"

        [dependencies]
        "#,
        )
        .unwrap();

    let output = Command::new("cargo")
        .arg("test")
        .current_dir(dir_path)
        .output()
        .expect("failed to execute cargo test");

    let success = output.status.success();
    let output_str = String::from_utf8_lossy(&output.stdout).to_string()
        + String::from_utf8_lossy(&output.stderr).as_ref();

    dir.close().unwrap();

    let response = Response {
        success,
        output: output_str,
    };

    HttpResponse::Ok().json(response)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| App::new().route("/execute", web::post().to(execute_code)))
        .bind("0.0.0.0:8080")?
        .run()
        .await
}
```

Dependencies used (in `Cargo.toml`):

```toml
[dependencies]
actix-web = "4.0.0"
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
tempfile = "3.2"
```

Some highlights:

- `Request` and `Response` are the structs for the request and response bodies.

- Making an API is relatively simple with the `actix-web` crate. The `main` function starts an HTTP server that listens on port 8080. I did have to make the port configurable with an environment variable for Heroku, but I omitted this part from the code for this post.

- `execute_code` is the handler for the `/execute` endpoint. It receives the code and tests, writes them to a temporary file, and runs `cargo test` on it. For this to work, the code and tests are concatenated into a single file and we write a `Cargo.toml` file with the base metadata.

- The code is written to a temporary directory using the `tempfile` crate.

- To make it a bit more secure, I added an API key check. If the API key is missing or invalid, the API returns an unauthorized response.

Here is [the repo](https://github.com/bbelderbos/rust_api_demo) if you want to play with it yourself.

## Testing the API

As you can see in the README I added two test examples of a good vs failing test:

```bash
$ ./test-ok.sh abc
{"success":true,"output":"\nrunning 1 test\ntest tests::test_add ... ok\n\ntest result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s\n\n   Compiling temp_project v0.1.0 (/private/var/folders/jl/cfhvw0nj11n1496hk7vqhw_r0000gn/T/.tmp1Y5KyV)\n    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.29s\n     Running unittests src/main.rs (target/debug/deps/temp_project-b55de88e432be2f2)\n"}%

$ ./test-fail.sh abc
{"success":false,"output":"\nrunning 1 test\ntest tests::test_add ... FAILED\n\nfailures:\n\n---- tests::test_add stdout ----\nthread 'tests::test_add' panicked at src/main.rs:7:41:\nassertion `left == right` failed\n  left: -1\n right: 5\nnote: run with `RUST_BACKTRACE=1` environment variable to display a backtrace\n\n\nfailures:\n    tests::test_add\n\ntest result: FAILED. 0 passed; 1 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s\n\n   Compiling temp_project v0.1.0 (/private/var/folders/jl/cfhvw0nj11n1496hk7vqhw_r0000gn/T/.tmpKXOHmY)\n    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.27s\n     Running unittests src/main.rs (target/debug/deps/temp_project-b55de88e432be2f2)\nerror: test failed, to rerun pass `--bin temp_project`\n"}%
```

## Conclusion

As a nice side effect of wanting to support Rust exercises on our platform, I learned how to build a simple API in Rust.

As mentioned I deployed it to Heroku, for which I had to use Docker to build the image, and then push it to Heroku's container registry. I will detail that in a follow up post ...
