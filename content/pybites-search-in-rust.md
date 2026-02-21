+++
title = "Building Pybites Search in Rust"
date = 2024-06-05
+++

> "The only way to learn a new programming language is by writing programs in it."
> - Dennis Ritchie

So true! Hence after my morning reading I picked up the laptop and tried to re-build [Pybites search](https://pypi.org/project/pybites-search/) in Rust :)

I came up with the following, iterating over code and learning Rust with ChatGPT (repo [here](https://github.com/bbelderbos/pybites-search)).

_Note that I first consolidated 5 endpoints (articles, bites, videos, podcasts and tips) on our platform to one endpoint, so I only had to do a single request._

## The Rust script

```rust
use cached::proc_macro::cached;
use reqwest;
use serde::Deserialize;
use regex::Regex;
use std::env;
use std::time::Duration;

const TIMEOUT: u64 = 10;
const ENDPOINT: &str = "http://localhost:8000/api/content";

#[derive(Deserialize, Debug, Clone)]
struct Item {
    content_type: String,
    title: String,
    summary: String,
    link: String,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 || args.len() > 4 {
        eprintln!("Usage: search <search_term> [<content_type>] [--title-only]");
        return Ok(());
    }

    let search_term = &args[1];
    let content_type = if args.len() >= 3 && !args[2].starts_with("--") { Some(&args[2]) } else { None };
    let title_only = args.contains(&"--title-only".to_string());

    let items = match fetch_items(ENDPOINT.to_string()).await {
        Ok(items) => items,
        Err(e) => {
            eprintln!("Error fetching items: {:?}", e);
            return Err(e.into());
        }
    };

    search_items(&items, search_term, content_type.map(String::as_str), title_only);

    Ok(())
}

#[cached(time = 600, result = true, sync_writes = true)]
async fn fetch_items(endpoint: String) -> Result<Vec<Item>, Box<dyn std::error::Error>> {
    let client = reqwest::Client::new();
    let response = client
        .get(&endpoint)
        .timeout(Duration::from_secs(TIMEOUT))
        .send()
        .await?
        .error_for_status()? // Ensure the response status is a success
        .json::<Vec<Item>>()
        .await?;
    Ok(response)
}

fn search_items(items: &[Item], search_term: &str, content_type: Option<&str>, title_only: bool) {
    let re = Regex::new(&format!("(?i){}", regex::escape(search_term))).unwrap();

    for item in items {
        let matches = if title_only {
            re.is_match(&item.title)
        } else {
            re.is_match(&item.title) || re.is_match(&item.summary)
        };
        if content_type.map_or(true, |t| t.eq_ignore_ascii_case(&item.content_type)) && matches {
            if content_type.is_none() {
                println!("Type: {}", item.content_type);
            }
            println!("Title: {}", item.title);
            println!("Link: {}\n", item.link);
        }
    }
}
```

Note this is AI generated code so it might not be as idiomatic as it could be. But that doesn't matter, I can always refactor it later. The point is I got a working script in Rust that searches our content. 🦀

Plus I feel I learned a lot in the process, a lot faster by just consuming tutorials and reading books! 💡

## Some things I learned

- How to make requests with `reqwest` (and `tokio` for async requests)
- How to cache requests with `cached` (note that this is a simple in-memory cache so it turned out to not be that useful for this script, in a later revision I added manual memoization, see [this post](/pybites-search-caching-serde-json))
- How to use `serde` to deserialize JSON
- Handle command line arguments
- Use `regex` to search for a term in a string
- Print to stdout and stderr
- Method chaining in Rust
- Some error handling in Rust
- Simple things like how to best define constants

## Config

```toml
$ cat Cargo.toml
[package]
name = "pybites-search"
version = "0.1.0"
authors = ["Bob Belderbos <bob@pybit.es>"]
edition = "2021"
description = "A command-line search tool for Pybites content"
license = "MIT"

[dependencies]
cached = "0.34.0"
reqwest = { version = "0.11", features = ["json"] }
tokio = { version = "1", features = ["full"] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
regex = "1"

[[bin]]
name = "psearch"
path = "src/main.rs"
```

- There is some metadata at the top about the package.
- Below I listed the dependencies I used in the script.
- I also defined the binary name and path to the script, that's why you see me running `./target/release/psearch` below aafter the build step.

## Compiling and running the script

```bash
√ search (main) $ cargo build --release
...
...

√ search (main) $ ./target/release/psearch
Usage: search <search_term> [<content_type>] [--title-only]

√ search (main) $ ./target/release/psearch rust
Type: article
Title: Jim Hodapp on coaching software engineers and the power of Rust
Link: https://pybit.es/articles/jim-hodapp-on-coaching-software-engineers-and-the-power-of-rust/

Type: article
Title: Talking to API's and goodlooking tools
Link: https://pybit.es/articles/guest-talking-to-apis-goodlooking-tools

Type: bite
Title: Create Wikipedia Lorem Ipsum text
Link: http://localhost:8000/bites/364

...
...

√ search (main) $ ./target/release/psearch rust article
Title: Jim Hodapp on coaching software engineers and the power of Rust
Link: https://pybit.es/articles/jim-hodapp-on-coaching-software-engineers-and-the-power-of-rust/

Title: Talking to API's and goodlooking tools
Link: https://pybit.es/articles/guest-talking-to-apis-goodlooking-tools

...
...

√ search (main) $ ./target/release/psearch rust  --title-only
Type: article
Title: Jim Hodapp on coaching software engineers and the power of Rust
Link: https://pybit.es/articles/jim-hodapp-on-coaching-software-engineers-and-the-power-of-rust/

Type: video
Title: Pybites Podcast 146 - Armin Ronacher: Flask 3.0, Open Source, Rust and Developer Mindset
Link: https://www.youtube.com/watch?v=yV4OXDy_DwE

Type: video
Title: Pybites Podcast 105 - Jim Hodapp on coaching software engineers and the power of Rust
Link: https://www.youtube.com/watch?v=LojYjASdOHk

Type: podcast
Title: #146 - Armin Ronacher: Flask 3.0, Open Source, Rust and Developer Mindset
Link: https://www.pybitespodcast.com/14165010/14165010-146-armin-ronacher-flask-3-0-open-source-rust-and-developer-mindset

Type: podcast
Title: #105 - Jim Hodapp on coaching software engineers and the power of Rust
Link: https://www.pybitespodcast.com/12368334/12368334-105-jim-hodapp-on-coaching-software-engineers-and-the-power-of-rust

√ search (main) $ ./target/release/psearch rust video --title-only
Title: Pybites Podcast 146 - Armin Ronacher: Flask 3.0, Open Source, Rust and Developer Mindset
Link: https://www.youtube.com/watch?v=yV4OXDy_DwE

Title: Pybites Podcast 105 - Jim Hodapp on coaching software engineers and the power of Rust
Link: https://www.youtube.com/watch?v=LojYjASdOHk
```

TIL we DO have some Rust content on Pybites! 🦀 😎

Next steps:
- Deploy the new endpoint on our platform and have the script point to it
- Add some tests
- Deploy it to crates.io
- Automate the deployment with GitHub Actions (upon pushing a new tag)
- New features (as per your feedback ...)

## Practice, Practice, Practice 🦀 - work on projects you care about 📈

A note about this type of learning: I find it very effective to learn a new language by (re-)building something you already know and/or you're passionate about.

You have to practice! It's a lot like language learning. You can't just read a book and expect to be fluent. You have to practice speaking and listening.

This is exactly what I did when I was interrailing around Europe in my early 20s and wanted to become more fluent in French and Spanish. I would speak to locals, watch TV, and read newspapers. I completely immersed myself in the language. And I made a lot of mistakes. That's how you learn!

The same is true for programming. Yes, you need to read the docs and books to grasp fundamentals, but above all you need to get into the trenches and write a lot of code, ideally in the context of building real-world projects. It's where things start to click and you start to see the bigger picture. It's also way more fun!

## Practice This

This project uses `serde` for JSON deserialization. Try the [JSON Serialization](https://rustplatform.com/json-serialization) exercise on the Pybites Rust Platform to practice working with `serde` and `serde_json`.

---

If you enjoy this content hit me up on [X](https://twitter.com/bbelderbos). I'm always up for a chat about programming. I also coach developers, so if you need help with your coding journey let me now, I can help you with this. 🚀
