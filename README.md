# Thermite

[![Build Status](https://travis-ci.org/malept/thermite.svg?branch=master)](https://travis-ci.org/malept/thermite)
[![Inline docs](http://inch-ci.org/github/malept/thermite.svg?branch=master)](http://inch-ci.org/github/malept/thermite)

Thermite is a Rake-based helper for building and distributing Rust-based Ruby extensions.

## Usage

1. Add `thermite` as a runtime dependency in your gem.
2. In your gemspec, add `Rakefile` to the specification's `extensions` list.
3. In `Rakefile`, add `require 'thermite/tasks'` and then add the tasks to the file by running:

```ruby
Thermite::Tasks.new
```

You can optionally pass arguments to `Thermite::Tasks.new`, which configure the tasks for your
specific project:

* `cargo_project_path` - the path to the Cargo project. Defaults to the current working directory.
* `github_releases` - whether to look for rust binaries via GitHub releases when installing
  the gem, and `cargo` is not found. Defaults to `false`.

### Example

Using the cliché Rust+Ruby example, the [`rusty_blank`](https://github.com/malept/rusty_blank)
repository contains an example of using Thermite with [ruru](https://github.com/d-unseductable/ruru)
to provide a `String.blank?` speedup extension.

## FAQ

### Why is it named Thermite?

According to Wikipedia:

* The chemical formula for ruby includes Al<sub>2</sub>O<sub>3</sub>, or aluminum oxide.
* Rust is iron oxide, or Fe<sub>2</sub>O<sub>3</sub>.
* A common thermite reaction uses iron oxide and aluminum to produce iron and aluminum oxide:
  Fe<sub>2</sub>O<sub>3</sub> + 2Al → 2Fe + Al<sub>2</sub>O<sub>3</sub>

## Legal

This gem is licensed under the MIT license.
