# JsonDiffEx

Diff and patch for JSON in Elixir, works really well and is really fast


## Installation

First, add JsonDiffEx to your `mix.exs` dependencies:

```elixir
def deps do
  [{:json_diff_ex, "~> 0.5.0"}]
end
```

Then, update your dependencies:

```sh-session
$ mix deps.get
```

## Using

### Diff

Simple example:

```elixir
JsonDiffEx.diff %{"test" => 1}, %{"test" => 2}
#=> %{"test" => [1, 2]}
```

Now with list:

```elixir
JsonDiffEx.diff %{"test" => [1,2,3]}, %{"test" => [2,3]}
#=> %{"test" => %{"_0" => [1, 0, 0], "_t" => "a"}}
```

Now with a map in the map:

```elixir
JsonDiffEx.diff %{"test" => %{"1": 1}}, %{"test" => %{"1": 2}}
#=> %{"test" => %{"1": [1, 2]}}
```

Now with a map in an list in the map:

```elixir
JsonDiffEx.diff %{"test" => [%{"1": 1}]}, %{"test" => [%{"1": 2}]}
#=> %{"test" => %{"0" => %{"1": [1, 2]}, "_t" => "a"}}
```

### Patch

Simple example of a patch:

```elixir
JsonDiffEx.patch %{"test" => 1}, %{"test" => [1, 2]}
#=> %{"test" => 2}
```

Now a patch with list:

```elixir
JsonDiffEx.patch %{"test" => [1,2,3]}, %{"test" => %{"_0" => [1, 0, 0], "_t" => "a"}}
#=> %{"test" => [2,3]}
```

Now a patch with a map in the map:

```elixir
JsonDiffEx.patch %{"test" => %{"1": 1}}, %{"test" => %{"1": [1, 2]}}
#=> %{"test" => %{"1": 2}}
```

Now with a map in an list in the map:

```elixir
JsonDiffEx.patch %{"test" => [%{"1": 1}]}, %{"test" => %{"0" => %{"1": [1, 2]}, "_t" => "a"}}
#=> %{"test" => [%{"1": 2}]}
```


## Compatibility

Should work with [jsondiffpatch](https://github.com/benjamine/jsondiffpatch)
and the test cases currently test make sure we keep that compatibility.

## Profiling


Get medium profiling tests

```sh-session
$ MIX_ENV=test mix run profile/get_usda_json.exs
```

Run medium profiling tests

```sh-session
$ MIX_ENV=test mix run profile/medium.exs
```

Run medium profiling tools

```sh-session
$ MIX_ENV=test mix profile.fprof profile/medium.exs
```

Get big profiling tests

```sh-session
$ MIX_ENV=test mix run profile/get_mtg_json.exs
```

Run big profiling tests

```sh-session
$ MIX_ENV=test mix run profile/big.exs
```

**Do not run the big profile with `mix profile.fprof` unless you
have a really good computer and don't mind crashing your computer,
haven't been able to finish it my self.**

## Links
[Package](https://hex.pm/packages/json_diff_ex)

[Documentation](http://hexdocs.pm/json_diff_ex/0.5.0/JsonDiffEx.html)
