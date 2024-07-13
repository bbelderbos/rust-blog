+++
title = "Automating test runs and checking coverage"
date = 2024-07-06
+++

The other day I did [a post on testing in Rust](/testing-in-rust) and the next logical step is to automate test runs and check coverage. Here's how you can do that:

1. Automating test runs using GitHub Actions

This is quite easy to do with a workflow file that runs the tests on every push and pull request. Here's an example:

```yaml
# .github/workflows/tests.yml
name: Rust

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Set up Rust
      uses: actions-rs/toolchain@v1
      with:
        toolchain: stable
        override: true

    - name: Cache Cargo registry
      uses: actions/cache@v2
      with:
        path: ~/.cargo/registry
        key: ${{ runner.os }}-cargo-registry-${{ hashFiles('**/Cargo.lock') }}
        restore-keys: |
          ${{ runner.os }}-cargo-registry-

    - name: Cache Cargo index
      uses: actions/cache@v2
      with:
        path: ~/.cargo/git
        key: ${{ runner.os }}-cargo-index-${{ hashFiles('**/Cargo.lock') }}
        restore-keys: |
          ${{ runner.os }}-cargo-index-

    - name: Cache Cargo build
      uses: actions/cache@v2
      with:
        path: target
        key: ${{ runner.os }}-cargo-build-${{ hashFiles('**/Cargo.lock') }}
        restore-keys: |
          ${{ runner.os }}-cargo-build-

    - name: Run tests
      run: cargo test --verbose
```

[Example job](https://github.com/bbelderbos/cli_alarm/actions/runs/9777385892/job/26991960298)

2. Checking test coverage using `tarpaulin`

I was wondering if there was an equivalent to `pytest-cov` in Rust and I found `tarpaulin`. First install it:

```bash
cargo install cargo-tarpaulin
```

Then run it:

```bash
$ cargo install cargo-tarpaulin
2024-07-03T11:29:24.739505Z  INFO cargo_tarpaulin::process_handling: running /Users/bbelderbos/code/rust/cli_alarm/target/debug/deps/alarm-556e1e717eaa9b33
2024-07-03T11:29:24.739591Z  INFO cargo_tarpaulin::process_handling: Setting LLVM_PROFILE_FILE

running 4 tests
test tests::test_edge_cases ... ok
test tests::test_exact_minute_durations ... ok
test tests::test_minute_and_second_durations ... ok
test tests::test_short_durations ... ok

test result: ok. 4 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

2024-07-03T11:29:25.052962Z  INFO cargo_tarpaulin::statemachine::instrumented: For binary: target/debug/deps/alarm-556e1e717eaa9b33
2024-07-03T11:29:25.052976Z  INFO cargo_tarpaulin::statemachine::instrumented: Generated: target/tarpaulin/profraws/alarm-556e1e717eaa9b33_14793736282992077593_0-7692.profraw
2024-07-03T11:29:25.052979Z  INFO cargo_tarpaulin::statemachine::instrumented: Merging coverage reports
2024-07-03T11:29:25.056944Z  INFO cargo_tarpaulin::statemachine::instrumented: Mapping coverage data to source
2024-07-03T11:29:25.083725Z  INFO cargo_tarpaulin::report: Coverage Results:
|| Uncovered Lines:
|| src/main.rs: 55, 57-58, 62, 64, 68-69, 73, 75, 78-79, 91-92, 94, 97-98, 100-101, 104-105
|| Tested/Total Lines:
|| src/main.rs: 12/32
||
37.50% coverage, 12/32 lines covered
```

And to make it more visual, generate an HTML report (the equivalent of `pytest --cov --cov-report=html`):

```bash
$ cargo tarpaulin --out Html
```

Beautiful:

{{ image(src="/images/tarpaulin-example.png", alt="example test report tarpaulin makes", style="border-radius: 8px;") }}

There you go, two more tools to help you test your Rust code.
