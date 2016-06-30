# Contributing to Thermite

Thermite is a part of the Rust ecosystem. As such, all contributions to this project follow the
[Rust language's code of conduct](https://www.rust-lang.org/conduct.html) where appropriate.

This project is hosted at [GitHub](https://github.com/malept/thermite). Both pull requests and
issues of many different kinds are accepted.

## Filing Issues

Issues include bugs, questions, feedback, and feature requests. Before you file a new issue, please
make sure that your issue has not already been filed by someone else.

### Filing Bugs

When filing a bug, please include the following information:

* Operating system and version. If on Linux, please also include the distribution name.
* System architecture. Examples include: x86-64, x86, and ARMv7.
* Ruby and Rake versions that run Thermite.
* The version (and/or git revision) of Thermite.
* If it's an error related to Rust, the version of Rust, Cargo, and how you installed it.
* A detailed list of steps to reproduce the bug. A minimal testcase would be very helpful,
  if possible.
* If there any any error messages in the console, copying them in the bug summary will be
  very helpful.

## Filing Pull Requests

Here are some things to keep in mind as you file a pull request to fix a bug, add a new feature,
etc.:

* Travis CI is used to make sure that the project conforms to the coding standards.
* If your PR changes the behavior of an existing feature, or adds a new feature, please add/edit
  the RDoc inline documentation (using the Markdown format). You can see what it looks like in the
  rendered documentation by running `bundle exec rake rdoc`.
* Please ensure that your changes follow the Rubocop-enforced coding standard, by running
  `bundle exec rake rubocop`.
* If you are contributing a nontrivial change, please add an entry to `NEWS.md`. The format is
  similar to the one described at [Keep a Changelog](http://keepachangelog.com/).
* Please make sure your commits are rebased onto the latest commit in the master branch, and that
  you limit/squash the number of commits created to a "feature"-level. For instance:

bad:

```
commit 1: add foo algorithm
commit 2: run rustfmt
commit 3: add test
commit 4: add docs
commit 5: add bar
commit 6: add test + docs
```

good:

```
commit 1: add foo algorithm
commit 2: add bar
```

If you are continuing the work of another person's PR and need to rebase/squash, please retain the
attribution of the original author(s) and continue the work in subsequent commits.
