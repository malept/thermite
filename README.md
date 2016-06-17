# Thermite

Thermite is a Rake-based helper for building and distributing Rust-based Ruby extensions.

## Usage

1. Add `thermite` as a runtime dependency in your gem.
2. In your gemspec, add `Rakefile` to specification's `extensions` list.
3. In `Rakefile`, add `require 'thermite/tasks'` and then add the tasks to the file by running:

```ruby
Thermite::Tasks.new
```

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
