module github

import os { getwd }
import prantlf.dotenv { load_env, load_user_env }

fn testsuite_begin() {
	load_env(true)!
	load_user_env(true)!
}

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

fn test_is_github() {
	url := get_repo_path(find_git()!)!
	assert is_github('github.com')
	assert !is_github('gitlab.com')
}

fn test_is_gitlab() {
	url := get_repo_path(find_git()!)!
	assert is_gitlab('gitlab.com')
	assert !is_gitlab('github.com')
}

fn test_get_gh_token() {
	token := get_gh_token()!
	assert token.len > 0
}
