+++
title = "Adding API Key Authentication to a Rust CLI"
date = 2026-02-21
+++

Our [exercise downloader](https://github.com/PyBites-Open-Source/pybites_rust) started as a simple tool that fetched free exercises from an API.

When we added [premium exercises](https://rustplatform.com) behind authentication this week, I needed to add API key support — without breaking the free tier experience.

## The Design

The requirements were straightforward:

- No API key? Download free exercises (existing behavior, unchanged)
- API key set? Send it as a header, get all exercises
- Key comes from an environment variable (`PYBITES_API_KEY`)

No config files, no interactive prompts, no flags. Just an env var.

## Reading the Key

```rust
use std::env;

let api_key = env::var("PYBITES_API_KEY").ok();
```

`env::var` returns `Result<String, VarError>`. Calling `.ok()` converts it to `Option<String>` — `Some("the-key")` if set, `None` if not. No error handling needed because a missing key is a valid state, not an error.

Coming from Python where you'd write `os.environ.get("KEY")` and get `None` back, I found this two-step dance surprising at first. But it makes sense — Rust forces you to acknowledge that reading an env var can fail, then lets you explicitly opt into treating "missing" as `None`.

## Conditional Header

The `build_request` function attaches the header only when a key exists:

```rust
fn build_request(
    client: &reqwest::blocking::Client,
    url: &str,
    api_key: Option<&str>,
) -> reqwest::blocking::RequestBuilder {
    let mut request = client.get(url);
    if let Some(key) = api_key {
        request = request.header("X-API-Key", key);
    }
    request
}
```

The function takes `Option<&str>` rather than `Option<String>` — the caller passes `api_key.as_deref()` to borrow rather than move the value. This keeps ownership with `main()` so the key can be used elsewhere (like in status messages).

I initially passed `Option<String>` and hit a "value used after move" error. In Python you never think about this — everything is a reference. In Rust, I learned to reach for borrows (`&str`) by default and only pass owned data when the function needs to keep it.

## User Feedback

A small touch that matters in CLIs: tell the user what mode they're in.

```rust
fn auth_status_message(api_key: &Option<String>) -> &'static str {
    if api_key.is_some() {
        "Authenticating with API key"
    } else {
        "No API key set (PYBITES_API_KEY), downloading free exercises only"
    }
}
```

The message includes the env var name so users know exactly what to set if they want premium exercises.

One thing I learned here: idiomatic Rust prefers `Option<&str>` over `&Option<String>` in function signatures (clippy will even flag it). A cleaner version would be:

```rust
fn auth_status_message(api_key: Option<&str>) -> &'static str {
    if api_key.is_some() {
        "Authenticating with API key"
    } else {
        "No API key set (PYBITES_API_KEY), downloading free exercises only"
    }
}
```

The caller would pass `api_key.as_deref()` — the same pattern we used in `build_request`.

## Testing Without a Server

I learned that you don't need to make HTTP requests to test request construction. Build the request, inspect it:

```rust
#[test]
fn test_build_request_without_api_key() {
    let client = reqwest::blocking::Client::new();
    let request = build_request(&client, "https://example.com/api/", None);
    let built = request.build().unwrap();
    assert!(built.headers().get("X-API-Key").is_none());
}

#[test]
fn test_build_request_with_api_key() {
    let client = reqwest::blocking::Client::new();
    let request = build_request(
        &client,
        "https://example.com/api/",
        Some("test-key-123"),
    );
    let built = request.build().unwrap();
    assert_eq!(
        built.headers().get("X-API-Key").unwrap().to_str().unwrap(),
        "test-key-123"
    );
}
```

`RequestBuilder::build()` gives you the final `Request` object without sending it. You can assert on URL, method, headers — everything except the actual response.

## Key Takeaways

- Use `env::var("KEY").ok()` to get an `Option<String>` — missing env vars aren't errors when they're optional
- `Option<&str>` in function signatures avoids unnecessary ownership transfer
- `RequestBuilder::build()` lets you test HTTP request construction without making network calls
- Always tell the user what mode the CLI is operating in

## The Open Source Side

This feature came out of iterating on the tool together with [Giuseppe Cunsolo](https://github.com/markgreene74), who originally built the CLI downloader. We added the auth support, full test coverage, and a CI gate that fails below 80% coverage (using [tarpaulin](https://github.com/xd009642/tarpaulin)). Then we published it to [crates.io](https://crates.io) so you can install it with a single command instead of cloning a repo.

It reminded me how much you learn from open source collaboration — and how nice the Rust tooling is (no wonder [uv](https://docs.astral.sh/uv/) got its inspiration from Cargo).

## Try It Yourself

If you have a CLI that talks to an API, try adding optional authentication. The pattern is always the same: env var to `Option`, conditional header, clear status message.

---
If you're a Pythonista curious about Rust, you'll feel right at home — `Option` is like Python's `Optional`, pattern matching replaces your `if/else` chains, and Cargo works the way you wish pip always did. Our [exercises at rustplatform.com](https://rustplatform.com) are designed with that Python-to-Rust journey in mind.

Use the [exercise downloader](https://github.com/PyBites-Open-Source/pybites_rust) to code locally — it's a real-world Rust CLI you can learn from too:

```bash
cargo install pybites-rust-download
# free exercises
pybites-rust-download
# premium exercises with API key
PYBITES_API_KEY=your_key pybites-rust-download
```
