+++
title = "Ownership and borrowing in Rust"
date = 2024-06-09
+++

In Python, this code runs just fine:

```python
def print_person(s):
    print(f"Inside function: {s}")

def main():
    person = "John"
    print_person(person)
    print(f"Hello, {person}!")  # person still accessible

main()
```

When I pass `person` to `print_person`, the ownership of `person` is not moved to the function. I can still use `person` after the function call.

In Rust, the same code will not compile:

```rust
fn print_person(s: String) {
    println!("Inside function: {}", s);
    // s goes out of scope here and is dropped
}

fn main() {
    let person = String::from("John");
    print_person(person);
    println!("Hello, {}!", person); // compile-time error
}
```

The Rust compiler gives this nicely descriptive error message:

```bash
...
7 |     let person = String::from("John");
  |         ------ move occurs because `person` has type `String`, which does not implement the `Copy` trait
8 |     print_person(person);
  |                  ------ value moved here
9 |     println!("Hello, {}!", person); // compile-time error
  |                            ^^^^^^ value borrowed here after move
```

What happens here is that `person` is moved to `print_person`, and I can't use it after that. This is because Rust is strict about ownership and borrowing.

This definitely takes some time to get used to, but it's a powerful and important feature of Rust.

It helps prevent memory-related bugs (e.g., use-after-free, double-free, dangling pointers, memory leaks) that are common in other languages that manage memory manually (e.g., C and C++).

The solution is to borrow `person` instead of moving it:

```rust
fn print_person(s: &String) {
    println!("Inside function: {}", s);
}

fn main() {
    let person = String::from("John");
    print_person(&person);
    println!("Hello, {}!", person); // now person is still usable
}
```

Here we pass a reference instead of the value itself. Note that you have to express this explicitly with `&` in the function signature and when calling the function.

In Rust speak `person` is _borrowed_ by `print_person`. This way the function can use `person` without taking _ownership_ of it.

## Key Takeaways:

- In Rust, passing _ownership_ to a function means the original variable can no longer be used. This is to prevent multiple owners of the same data, which can lead to bugs and memory leaks. It also helps with performance and concurrency.

- In Python, variables are references, so they remain valid after being passed to functions. Additionally, you don't have to worry about memory management because Python's garbage collector automatically handles the allocation and deallocation of memory (it tracks object references and uses reference counting and cyclic garbage collection to free memory that is no longer needed).

- Rust's _borrowing_ allows you to pass references to functions without transferring ownership, preserving the original variable’s validity.

## Mutability and borrowing

In Rust, you can have multiple immutable references to the same data, but only one mutable reference. Additionally, you have to explicitly declare that you want to mutate the data.

In Python, the burden is on the programmer to ensure that data is not modified when it shouldn't be. Python doesn't distinguish between mutable and immutable references explicitly.


```python
def modify_data(data):
    data.append(4)

def main():
    my_list = [1, 2, 3]
    modify_data(my_list)
    print(f"Modified list: {my_list}")  # my_list is modified

main()
```

For example here `my_list` is modified inside `modify_data` function. In Rust, this would not compile because `my_list` is borrowed immutably by `modify_data`:

```rust
fn modify_data(data: &Vec<i32>) {
    data.push(4);
}

fn main() {
    let my_list = vec![1, 2, 3];
    modify_data(&my_list);
    println!("Modified list: {:?}", my_list); // compile-time error
}
```

The Rust compiler will give this error:

```bash
2 |     data.push(4);
  |     ^^^^ `data` is a `&` reference, so the data it refers to cannot be borrowed as mutable
  |
help: consider changing this to be a mutable reference
  |
1 | fn modify_data(data: &mut Vec<i32>) {
  |                       +++
```

In Rust, to modify data within a function, you must pass a mutable reference using `&mut`. This ensures that only one mutable reference exists at a time, preventing data races and ensuring memory safety.

```rust
fn modify_data(data: &mut Vec<i32>) {
    data.push(4);
}

fn main() {
    let mut my_list = vec![1, 2, 3];
    modify_data(&mut my_list);
    println!("Modified list: {:?}", my_list); // now it works
}
```

__Note__: _This is for example's sake. I don't like mutating outer scope data inside functions. A more functional approach would be to return the modified data._

## Practice This

Practice these concepts on the Pybites Rust Platform:

- [Ownership and Borrowing](https://rustplatform.com/ownership-and-borrowing)
- [Move Semantics](https://rustplatform.com/move-semantics)
- [Shared References](https://rustplatform.com/shared-references)
- [Mutable References](https://rustplatform.com/mutable-references)

## Conclusion

Understanding ownership and borrowing is a key concept in Rust. It can be frustrating at first, but it's a powerful feature that helps prevent bugs and makes your code more reliable. Rust achieves a balance between performance and safety, leveraging its strict ownership model to prevent common programming errors while still being highly performant.

Python uses a different approach to memory management, relying on garbage collection to handle memory allocation and deallocation so you generally don't have to worry about these details.

I still have a lot to learn about the nuances of ownership and borrowing in Rust, but I hope this post gives you a good starting point.
