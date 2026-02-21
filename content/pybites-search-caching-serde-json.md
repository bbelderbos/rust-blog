+++
title = "Enhancing Pybites Search caching using serde_json"
date = 2024-06-07
+++

I made a [Pybites search command-line tool](/pybites-search-in-rust) the other day, only to find out that the caching was in-memory which was not very useful for a CLI tool.

So I decided to add caching manually to it using `serde_json`. Here's how I did it (with the help of ChatGPT).

```rust
fn save_to_cache(items: &Vec<Item>) -> Result<(), Box<dyn std::error::Error>> {
    let cache_path = get_cache_file_path();
    let cache_data = CacheData {
        timestamp: SystemTime::now().duration_since(UNIX_EPOCH)?.as_secs(),
        items: items.clone(),
    };
    let serialized = serde_json::to_string(&cache_data)?;
    fs::write(cache_path, serialized)?;
    Ok(())
}

fn load_from_cache(cache_duration: u64) -> Result<Vec<Item>, Box<dyn std::error::Error>> {
    let cache_path = get_cache_file_path();
    let data = fs::read_to_string(cache_path)?;
    let cache_data: CacheData = serde_json::from_str(&data)?;

    let current_time = SystemTime::now().duration_since(UNIX_EPOCH)?.as_secs();
    if current_time - cache_data.timestamp <= cache_duration {
        Ok(cache_data.items)
    } else {
        Err("Cache expired".into())
    }
}

#[derive(Deserialize, Serialize)]
struct CacheData {
    timestamp: u64,
    items: Vec<Item>,
}

fn get_cache_file_path() -> PathBuf {
    let mut path = home_dir().expect("Could not find home directory");
    path.push(CACHE_FILE_NAME);
    path
}
```

[Full code](https://github.com/bbelderbos/pybites-search/blob/main/src/main.rs)

- I added a `CacheData` struct to hold the timestamp and the items.
- I added a `save_to_cache` function to save the items to a file (using the `CACHE_FILE_NAME` constant to define the file name).
- I added a `load_from_cache` function to load the items from a file with a cache duration check.
- I added a `get_cache_file_path` function to get the path to the cache file (using the `home_dir` function from the `dirs` crate).
- The cache duration is set to 24 hours by default (`DEFAULT_CACHE_DURATION` constant) but can be overridden by setting the `CACHE_DURATION` environment variable. I like how you can chain methods in Rust, it's very concise and readable 😍 📈

```rust
    let cache_duration = env::var("CACHE_DURATION")
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(DEFAULT_CACHE_DURATION);
```

Now it works well: the items are saved to the cache file and loaded from it till the cache expires. Apart from the first run, when the cache is created, the search results are now almost instant!

First install the crate (see [my previous article](/shipped-first-crate) how to publish Rust code to crates.io):

```bash
$ cargo install pybites-search
```

Then run it:

```bash
$ time psearch pixi
...

[podcast] #141 - Wolf Vollprecht: Making Conda More Poetic With Pixi
https://www.pybitespodcast.com/14040203/14040203-141-wolf-vollprecht-making-conda-more-poetic-with-pixi

psearch pixi  0.06s user 0.06s system 5% cpu 2.323 total

$ time psearch pixi
...

[podcast] #141 - Wolf Vollprecht: Making Conda More Poetic With Pixi
https://www.pybitespodcast.com/14040203/14040203-141-wolf-vollprecht-making-conda-more-poetic-with-pixi

psearch pixi  0.01s user 0.01s system 82% cpu 0.018 total
```

After the caching it's almost instant!

I compared it to [our Python search tool](https://pypi.org/project/pybites-search/) and it's now faster than that one:

```bash
$ time search all pixi
...
search all pixi  0.33s user 0.06s system 96% cpu 0.410 total
```

That's like 20x faster. 🤯

But that might not be fair, because it uses requests-cache with sqlite and I also started a new API endpoint on our platform specially for the Rust search tool.

So I had ChatGPT translate the Rust code [to Python](https://gist.github.com/pybites/9717243b4d573ffa4e6f5ff987f22e2f) and after a few Pythonic tweaks and fixes it was faster and more comparable to the Rust tool:

```bash
$ time python script.py pixi
...
python script.py pixi  0.18s user 0.03s system 98% cpu 0.214 total
```

That's faster but not as fast as the Rust tool. 🚀😎

## Practice This

This post uses `serde_json` for serialization and deserialization. Try the [JSON Serialization](https://rustplatform.com/json-serialization) exercise on the Pybites Rust Platform to practice these patterns.

---
I still have a lot of Rust fundamentals to learn, but by building practical tools I am learning much more, faster and seeing results like these is way more fun and gratifying than only studying or even doing exercises.

So if you're learning Rust or any other language, I recommend building real-world tools with it. It really works! 🛠️
