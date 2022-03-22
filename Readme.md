## Demonstrating how IFD breaks parallel building

The flake contains 2 packages (`ifd` and `non-ifd`), which are equivalent, except one of them is constructed using IFD.
Both packages depend on 3 other packages, `slow-1`, `slow-2` and `slow-3`, each taking 10s to build.

First, execute a `nix flake show` to make sure inputs are cached. We don't want fetching nixpkgs to influence the benchmark:
```shell
nix flake show
```

Let's build the `non-ifd` package first.
We bring in some impurities via environment variable `VAR` ensuring to never hit the cache.

```shell
VAR=$(date) time nix build --substituters "" --impure .#non-ifd
```
-> building took roughly **10s**, which means all 3 dependencies have been built in parallel

Let's build the IFD based package:

```shell
VAR=$(date) time nix build --substituters "" --impure .#ifd
```
-> building required around 30s, which means that the dependencies have **NOT** been built in parallel.
