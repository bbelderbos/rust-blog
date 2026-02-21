+++
title = "Making an immutable hashmap constant"
date = 2024-06-23
+++

The other day I needed an dictionary / HashMap to look up [abbreviated content types](https://github.com/bbelderbos/pybites-search/issues/5).

## Constant dictionary / hashmap

I wondered how to make it constant and if I could use the nice Python `dict.get(key, key)` idiom to return the key itself if it is not found in the dictionary.

I found the `phf` crate, which is a perfect fit for this it seems. And it supports the `get` method and the `unwrap_or` method to provide a default value if the key is not found.

Another option is `lazy_static` but I read that `phf` enforces immutability more strictly by design and that it can provide more efficient access patterns due to its compile-time optimizations (the data is embedded in the binary).

## `phf` example

I added this code ([commit](https://github.com/bbelderbos/pybites-search/commit/6fb8b032f36c0564e843a0072ee0960ac8f1543f)):

```rust
use phf::phf_map;

static CATEGORY_MAPPING: phf::Map<&'static str, &'static str> = phf_map! {
    "a" => "article",
    "b" => "bite",
    "p" => "podcast",
    "v" => "video",
    "t" => "tip",
};


fn main() {
    for ct in &["a", "b", "p", "v", "t", "not found"] {
        let value = CATEGORY_MAPPING.get(ct).unwrap_or(&ct).to_string();
        println!("{} -> {}", ct, value);
    }
}
```

This prints:

```bash
a -> article
b -> bite
p -> podcast
v -> video
t -> tip
not found -> not found
```

- The `phf_map!` macro creates a constant hashmap.
- The `CATEGORY_MAPPING` is a static variable that holds the hashmap.
- The `get` method is used to lookup the key in the hashmap.
- The `unwrap_or` method is used to provide a default value if the key is not found.
- The `to_string` method is used to convert the value to a string.

Note that you need to enable the `macros` feature in your `Cargo.toml` file:

## Configuring `phf`

```toml
phf = { version = "0.11.2", features = ["macros"] }
```

## Practice This

Try the [HashMap Entry API](https://rustplatform.com/hashmap-entry-api) exercise on the Pybites Rust Platform to practice working with HashMaps in Rust.

## Conclusion

With `phf` you can create a constant hashmap in an efficient way. It is a good fit for cases where you need to look up values by key and you want to enforce immutability. 💡

And with that you can now use Pybites Search with both `-c a` and `-c article`, `-c b` and `-c bite`, etc. 🎉 🚀
