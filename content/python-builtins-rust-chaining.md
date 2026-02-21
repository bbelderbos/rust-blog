+++
title = "Python Built-ins vs. Rust method chaining (and how it works)"
date = 2024-06-20
+++

If you're familiar with Python, you know how powerful its built-in functions for iterables can be.

Functions like `map`, `filter`, and `reduce` provide a simple and expressive way to handle collections.

Rust offers similar functionality through iterators and method chaining, which, while different in syntax, provide equally powerful capabilities.

This post explores how Python built-ins translate to Rust's method chaining with iterators.

## Python Built-ins vs. Rust Method Chaining

### Python's Approach

Python provides many built-in functions to operate on iterables, such as `map`, `filter`, `zip`, `enumerate`, `all`, `any`, etc.

These functions are easy to use and understand, making them a staple in Python programming. I did an overview video of them you can watch [here](https://www.youtube.com/watch?v=ejvql4eKev4).

### Rust's Approach

Rust, on the other hand, implements these functionalities as methods on iterator types.

This approach leverages Rust's strengths in type safety and performance. By chaining methods, Rust allows you to build complex operations in a concise and readable manner.

## Example Comparisons

Let's compare some common operations using Python built-ins and Rust method chaining:

### `map`

**Python:**

```python
numbers = [1, 2, 3]
squared = list(map(lambda x: x**2, numbers))
print(squared)  # Output: [1, 4, 9]
```

**Rust:**

```rust
let numbers = vec![1, 2, 3];
let squared: Vec<i32> = numbers.iter().map(|&x| x * x).collect();
println!("{:?}", squared);  // Output: [1, 4, 9]
```

### `filter`

**Python:**

```python
numbers = [1, 2, 3, 4]
even = list(filter(lambda x: x % 2 == 0, numbers))
print(even)  # Output: [2, 4]
```

**Rust:**

```rust
let numbers = vec![1, 2, 3, 4];
let even: Vec<i32> = numbers.iter().filter(|&&x| x % 2 == 0).copied().collect();
println!("{:?}", even);  // Output: [2, 4]
```

### `zip`

**Python:**

```python
list1 = [1, 2, 3]
list2 = ['a', 'b', 'c']
for item1, item2 in zip(list1, list2):
    print(item1, item2)  # Output: 1 a, 2 b, 3
```

**Rust:**

```rust
let list1 = vec![1, 2, 3];
let list2 = vec!['a', 'b', 'c'];
for (item1, item2) in list1.iter().zip(list2.iter()) {
    println!("{} {}", item1, item2);  // Output: 1 a, 2 b, 3 c
}
```

### `enumerate`

**Python:**

```python
items = ['a', 'b', 'c']
for index, value in enumerate(items):
    print(index, value)  # Output: 0 a, 1 b, 2 c
```

**Rust:**

```rust
let items = vec!['a', 'b', 'c'];
for (index, value) in items.iter().enumerate() {
    println!("{} {}", index, value);  // Output: 0 a, 1 b, 2 c
}
```

## How Method Chaining Works in Rust

Rust’s method chaining is possible because each method in the iterator chain returns another iterator. This allows you to call multiple methods in sequence. Here's a deeper dive into how this works:

### Example: Chaining `map` and `filter`

```rust
let numbers = vec![1, 2, 3, 4];

let result: Vec<i32> = numbers
    .iter()                   // Creates an iterator over the elements of the vector
    .map(|&x| x * x)          // Applies the closure to each item, returns an iterator of squared values
    .filter(|&x| x % 2 == 0)  // Filters the items, returning only those that are even
    .collect();               // Collects the iterator into a vector

println!("{:?}", result);  // Output: [4, 16]
```

Quite elegant, isn't it? Let's break down the steps:

### Step-by-Step Breakdown

1. **Creating the Iterator**:
    ```rust
    numbers.iter()
    ```
    This creates an iterator over the references to the elements of the vector `numbers`.

2. **Mapping Values**:
    ```rust
    .map(|&x| x * x)
    ```
    The `map` method creates a new iterator that applies the given closure to each item, in this case, squaring the values.

3. **Filtering Values**:
    ```rust
    .filter(|&x| x % 2 == 0)
    ```
    The `filter` method creates another iterator that only yields items for which the given predicate is `true`, in this case, retaining even numbers.

4. **Collecting Results**:
    ```rust
    .collect()
    ```
    The `collect` method consumes the iterator and collects the resulting items into a new collection, in this case, a vector.

### How It Works Internally

Each method (`map`, `filter`, etc.) returns a new iterator type. For example:

- `numbers.iter()` returns an `Iter` iterator.
- `Iter` has a method `map` that returns a `Map<Iter, F>` iterator.
- `Map<Iter, F>` has a method `filter` that returns a `Filter<Map<Iter, F>, G>` iterator.

These iterator types (`Iter`, `Map`, `Filter`) all implement the `Iterator` trait, allowing them to be chained together seamlessly.

In Python we really like generators and _lazy_ operations (meaning any computation is only done when needed). Rust iterators are also lazy by default, which can lead to significant performance improvements, especially when working with large collections.

---

_Traits_ are a fundamental feature in Rust that allow you to define shared behavior across different types. A trait is a collection of methods defined for an unknown type: `Self`. Traits can be implemented for any data type. In this case, the `Iterator` trait provides a common interface for all iterators, enabling method chaining.

By implementing the `Iterator` trait, a type gains the ability to be iterated over using methods like `map`, `filter`, and `collect`. This trait-based approach ensures that any type that implements `Iterator` can seamlessly integrate with Rust's powerful iterator combinators, promoting code reuse and modularity.

A dedicated article to follow on this topic...

## Benefits of Chaining

1. **Readability**: Method chaining provides a clear and concise way to express a series of operations on a collection.
2. **Performance**: Iterators in Rust are lazy and can be highly optimized by the compiler. Operations are performed only when needed.
3. **Extensibility**: By implementing the `Iterator` trait for custom types, you can leverage all the powerful methods available on iterators.

## Practice This

Practice iterators on the Pybites Rust Platform:

- [Iterator Basics](https://rustplatform.com/iterator-basics)
- [Map and Filter](https://rustplatform.com/map-and-filter)
- [Iterator Chaining](https://rustplatform.com/iterator-chaining)

## Conclusion

So what are Python's robust and performant built-ins in Rust? You'll often find them as methods on iterator types, allowing you to chain operations together in a fluent and efficient manner. 😍 📈

I hope this comparison has given you a better understanding of how Rust's method chaining with iterators can be a powerful tool in your programming arsenal. Happy coding! 🦀 🚀
