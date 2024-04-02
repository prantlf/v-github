# GitHub Project Library for V

Several functions for managing GitHub projects.

## Synopsis

```v
import prantlf.github { find_git, get_repo_path }
import prantlf.json { parse }

// Get repository path, for example: 'prantlf/v-github'
git_path := find_git()!
repo_path := get_repo_path(git_path)!

// Get authorisation token from environment variables GITHUB_TOKEN or GH_TOKEN
gh_token := get_gh_token()!

// Get tag of the latest release
output := get_latest_release(repo_path, gh_token)!
release := parse(output)!.object()!
tag := release['tag_name']!.string()!
```

## Installation

You can install this package either from [VPM] or from GitHub:

```txt
v install prantlf.github
v install --git https://github.com/prantlf/v-github
```

## API

The following functions are exported:

    find_git() !string
    get_repo_url(git_dir string) !string
    cut_repo_path(repo_url string) !string
    get_repo_path(git_dir string) !string
    is_github(repo_url string) bool
    is_gitlab(repo_url string) bool
    get_gh_token() !string

    get_release(repo string, token string, tag string) !string
    get_latest_release(repo string, token string) !string
    create_release(repo string, token string, tag string, ver string, log string) !string
    download_asset(url string, token string) !string
    upload_asset(repo string, token string, id int, name string, data string, typ string) !string

## Contributing

In lieu of a formal styleguide, take care to maintain the existing coding style. Lint and test your code.

## License

Copyright (c) 2023 Ferdinand Prantl

Licensed under the MIT license.

[VPM]: https://vpm.vlang.io/packages/prantlf.github
