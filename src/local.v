module github

import os { getenv_opt, join_path_single, read_lines }
import prantlf.debug { new_debug }
import prantlf.osutil { find_file }
import prantlf.pcre { NoMatch, pcre_compile }

const d = new_debug('vp')

pub fn find_git() !string {
	_, path := find_file('.git') or { return error('missing ".git" directory') }
	return path
}

pub fn get_repo_url(git_dir string) !string {
	file := join_path_single(git_dir, 'config')
	dfile := github.d.rwd(file)
	github.d.log('reading file "%s"', dfile)
	lines := read_lines(file)!

	mut re_url := pcre_compile(r'\s*url\s*=\s*(.+)$', 0) or { panic(err) }
	for line in lines {
		github.d.log('looking for url in "%s"', line)
		if m := re_url.exec(line, 0) {
			url := m.group_text(line, 1) or { panic(err) }
			github.d.log('url "%s" found', url)
			return url
		}
	}

	return error('url in ".git/config" not detected')
}

pub fn get_repo_path(git_dir string) !string {
	mut url := get_repo_url(git_dir)!
	if url.ends_with('.git') {
		url = url[..url.len - 4]
	}

	re_name := pcre_compile(r'^.+github\.com[:/]([^/]+/(?:.+))', 0) or { panic(err) }
	m := re_name.exec(url, 0) or {
		return if err is NoMatch {
			error('unsupported git url "${url}"')
		} else {
			err
		}
	}
	path := m.group_text(url, 1) or { panic(err) }

	github.d.log('git repo "%s" detected', path)
	return path
}

pub fn get_gh_token() !string {
	return getenv_opt('GITHUB_TOKEN') or {
		getenv_opt('GH_TOKEN') or { return error('neither GITHUB_TOKEN nor GH_TOKEN found') }
	}
}
