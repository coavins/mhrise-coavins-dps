# How to contribute

First of all, **thank you** for reading this file, as it means you're interested in helping out with this project. Anyone is invited to propose changes, fixes, and new features through pull requests in this repository. The following guidelines are intended to keep the commit history clean and easy to read.

## Testing

If you're making changes to the core lua script, you can run the included unit tests by installing [busted](https://olivinelabs.com/busted/) and running `busted .` in the root directory.

We also use [luacheck](https://github.com/lunarmodules/luacheck) for linting, just run `luacheck src tests` in the root directory.

These tests will be automatically run for you every time you add commits to your pull request.

## Contributing

Please create a pull request with a clear explanation of what you've done (read more about [pull requests](http://help.github.com/pull-requests/)).

Use the `develop` branch as the base for your PR.

Rebase your PR branch into as few commits as possible. Rebasing is encouraged to help keep a linear commit history.

This repository generally follows the [Chris Beams standards](https://cbea.ms/git-commit/) for commit messages:

    Separate subject from body with a blank line
    Limit the subject line to 50 characters
    Capitalize the subject line
    Do not end the subject line with a period
    Use the imperative mood in the subject line
    Wrap the body at 72 characters
    Use the body to explain what and why vs. how

Please ensure you've followed the above guidelines for your commit messages.

Thanks again and I look forward to reviewing your work.