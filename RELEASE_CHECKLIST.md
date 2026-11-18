# Release Checklist

Releases of the packages contained in this monorepo follow the [SemVer convention](https://semver.org/spec/v2.0.0.html).

> [!NOTE]
> The `contracts` and `bindings` are independently versioned with `X.Y.Z` and `A.B.C`, respectively. Both versions can include release candidates (suffixed with `-rc.?`).

We distinguish between two release cases:

- Releasing a **new** forwarder bases version
  - `contracts/vX.Y.Z` version
  - `bindings/vA.0.0` version

- Maintaining the bindings resulting in a new
  - `bindings/vA.B.C` version

## Releasing a new Forwarder Bases Version

### 1. Prerequisites

- [ ] Visit https://www.soliditylang.org/ and check that Solidity compiler version used in `contracts/foundry.toml` has no [known vulnerabilities](https://docs.soliditylang.org/en/latest/bugs.html).

- [ ] Install the dependencies with `just contracts-deps`

- [ ] Check that the dependencies are up-to-date and have no known vulnerabilities in the dependencies

- [ ] Check out a new git branch from `next`.

### 2. Build the Contracts

- [ ] Run `just contracts-build`

- [ ] Run the test suite with `just contracts-test`

### 3. Create a new `contracts` and `bindings` GitHub Release

- [ ] Change the `bindings` package version number in the [`./bindings/Cargo.toml`](./bindings/Cargo.toml) file to `A.0.0`, where `A` is the last `MAJOR` version number incremented by 1.

- [ ] Clean the bindings build with `just bindings-clean`.

- [ ] Regenerate the bindings with `just contracts-gen-bindings`.

- [ ] Run `just bindings-build` and check that the `Cargo.lock` file reflects the version number change.

- [ ] Run the tests with `just bindings-test`.

- [ ] Merge a PR containing the work into `next`, then a PR that promotes `next` to `main`.

- [ ] Tag the merge commit of the promotion with:
  - [ ] `contracts/vX.Y.Z` where `X.Y.Z` is the new semantic version number
  - [ ] `bindings/vA.0.0` tag, where `A` is the last `MAJOR` version incremented by 1.

- [ ] Create new [GH releases](https://github.com/anoma/forwarder-bases/releases) for both packages.

### 4. Publish a new `contracts` package

- [ ] Publish the `contracts` package on https://soldeer.xyz/ with

  ```sh
  just contracts-publish <X.Y.Z> --dry-run
  ```

  where `<X.Y.Z>` is the version number and check the resulting `contracts.zip` file. If everything is correct, remove the `--dry-run` flag and publish the package.

### 5. Publish a new `bindings` package

- [ ] Publish the `anoma-forwarder-bases-bindings` package on https://crates.io/ with

  ```sh
  just bindings-publish --dry-run
  ```

  and check the result. If everything is correct, remove the `--dry-run` flag and publish the package.

## Maintaining the Bindings

### 1. Prerequisites

- [ ] Check that the bindings are up-to-date with

  ```sh
  just bindings-check
  ```

- [ ] Check out a new git branch from `next`.

- [ ] Check that there are no staged or unstaged changes by running `git status`.

### 2. Create a new `bindings` GitHub Release

- [ ] Change the `bindings` package version number in the `./bindings/Cargo.toml` file to `A.B.C`, where `A` and `B` are the last `MAJOR` and `MINOR` version numbers and `C` is the last `PATCH` version number incremented by 1.

- [ ] Run `just bindings-build` and check that the `Cargo.lock` file reflects the version number change.

- [ ] Run the tests with `just bindings-test`.

- [ ] After merging into `next` and promoting `next` to `main`, tag the merge commit of the promotion `bindings/vA.B.C`, where `A` and `B` are the last `MAJOR` and `MINOR` version numbers, respectively, and `C` is the last `PATCH` version number incremented by 1.

- [ ] Create a new [GH release](https://github.com/anoma/forwarder-bases/releases).

### 3. Publish a new `bindings` package

- [ ] Publish the `anoma-forwarder-bases-bindings` package on https://crates.io/ with

  ```sh
  just bindings-publish --dry-run
  ```

  and check the result. If everything is correct, remove the `--dry-run` flag and publish the package.
