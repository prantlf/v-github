module github

import prantlf.dotenv { load_env, load_user_env }

fn testsuite_begin() {
	load_env(true)!
	load_user_env(true)!
}

fn test_get_release_latest() {
	res := get_latest_release('prantlf/v-newchanges', get_gh_token()!)!
	assert res.len > 0
}

fn test_get_release_existing() {
	res := get_release('prantlf/v-newchanges', get_gh_token()!, 'v0.4.0')!
	assert res.len > 0
}

fn test_get_release_missing() {
	res := get_release('prantlf/v-newchanges', get_gh_token()!, 'v10.0.0')!
	assert res.len == 0
}

fn test_download_release_missing() {
	res := download_asset('https://github.com/prantlf/v-newchanges/releases/download/v0.4.0/newchanges-linux-arm64.zip',
		get_gh_token()!)!
	assert res.len > 0
}
