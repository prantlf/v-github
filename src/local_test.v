module github

import os { getwd }

fn test_find_git() {
	path := find_git()!
	assert path == '${getwd()}${os.path_separator}.git'
}

fn test_get_repo_url() {
	url := get_repo_url(find_git()!)!
	assert url == 'git@github.com:prantlf/v-github.git'
		|| url == 'https://github.com/prantlf/v-github'
}

fn test_get_repo_path() {
	url := get_repo_path(find_git()!)!
	assert url == 'prantlf/v-github'
}
