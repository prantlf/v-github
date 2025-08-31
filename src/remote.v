module github

import net.http { Request }
import net.urllib { query_escape }
import prantlf.jany { Any }
import prantlf.json { parse, stringify }

pub fn get_release(repo string, token string, tag string) !string {
	url := 'https://api.github.com/repos/${repo}/releases/tags/${tag}'
	d.log('getting "%s"', url)
	mut req := Request{
		method: .get
		url:    url
	}
	req.add_header(.accept, 'application/vnd.github+json')
	req.add_header(.authorization, 'Bearer ${token}')
	req.add_custom_header('X-GitHub-Api-Version', '2022-11-28')!
	res := req.do()!
	d.log('received "%s"', res.body)
	if res.status_code == 200 {
		return res.body
	} else if res.status_code == 404 {
		return ''
	}
	return error('enquiring ${tag} from ${repo} failed: ${res.status_code} (${res.status_msg})')
}

pub fn get_latest_release(repo string, token string) !string {
	url := 'https://api.github.com/repos/${repo}/releases/latest'
	d.log('getting "%s"', url)
	mut req := Request{
		method: .get
		url:    url
	}
	req.add_header(.accept, 'application/vnd.github+json')
	req.add_header(.authorization, 'Bearer ${token}')
	req.add_custom_header('X-GitHub-Api-Version', '2022-11-28')!
	res := req.do()!
	d.log('received "%s"', res.body)
	if res.status_code == 200 {
		return res.body
	} else if res.status_code == 404 {
		return ''
	}
	return error('enquiring latest release from ${repo} failed: ${res.status_code} (${res.status_msg})')
}

pub fn create_release(repo string, token string, tag string, ver string, log string) !string {
	url := 'https://api.github.com/repos/${repo}/releases'
	body := stringify(Any(log))
	data := '{"tag_name":"${tag}","name":"${ver}","body":${body}}'
	d.log('posting "%s" to "%s"', data, url)
	mut req := Request{
		method: .post
		url:    url
		data:   data
	}
	req.add_header(.accept, 'application/vnd.github+json')
	req.add_header(.authorization, 'Bearer ${token}')
	req.add_header(.content_type, 'application/json')
	req.add_custom_header('X-GitHub-Api-Version', '2022-11-28')!
	res := req.do()!
	d.log('received "%s"', res.body)
	if res.status_code == 201 {
		return res.body
	}
	return error('creating ${tag} to ${repo} failed: ${res.status_code} (${res.status_msg})')
}

pub fn download_asset(url string, token string) !string {
	d.log('getting "%s"', url)
	mut req := Request{
		method: .get
		url:    url
	}
	req.add_header(.authorization, 'Bearer ${token}')
	req.add_custom_header('X-GitHub-Api-Version', '2022-11-28')!
	res := req.do()!
	d.log('received "%d" bytes', res.body.len)
	if res.status_code == 200 {
		return res.body
	}
	return error('downloading ${url} failed: ${res.status_code} (${res.status_msg})')
}

pub fn upload_asset(repo string, token string, id int, name string, data string, typ string) !string {
	url := 'https://uploads.github.com/repos/${repo}/releases/${id}/assets?name=${query_escape(name)}'
	d.log('posting "%s" to "%s"', name, url)
	mut req := Request{
		method: .post
		url:    url
		data:   data
	}
	req.add_header(.accept, 'application/vnd.github+json')
	req.add_header(.authorization, 'Bearer ${token}')
	req.add_header(.content_type, typ)
	req.add_header(.content_length, data.len.str())
	req.add_custom_header('X-GitHub-Api-Version', '2022-11-28')!
	res := req.do()!
	d.log('received "%s"', res.body)
	if res.status_code == 201 {
		return res.body
	}
	if res.status_code == 422 {
		asset := get_asset_by_name(repo, token, id, name)!
		if asset.len > 0 {
			return asset
		}
	}
	return error('adding "${name}" to release ${id} in ${repo} failed: ${res.status_code} (${res.status_msg})')
}

fn get_asset_by_name(repo string, token string, id int, name string) !string {
	assets := list_assets(repo, token, id)!
	asset_objects := parse(assets)!.array()!
	for asset_object in asset_objects {
		asset := asset_object.object()!
		asset_name := asset['name']!.string()!
		if name == asset_name {
			asset_string := stringify(asset_object)
			return asset_string
		}
	}
	return ''
}

pub fn list_assets(repo string, token string, id int) !string {
	url := 'https://api.github.com/repos/${repo}/releases/${id}/assets'
	d.log('getting "%s"', url)
	mut req := Request{
		method: .get
		url:    url
	}
	req.add_header(.accept, 'application/vnd.github+json')
	req.add_header(.authorization, 'Bearer ${token}')
	req.add_custom_header('X-GitHub-Api-Version', '2022-11-28')!
	res := req.do()!
	d.log('received "%s"', res.body)
	if res.status_code == 200 {
		return res.body
	}
	return error('listing assets from ${repo}, release ${id} failed: ${res.status_code} (${res.status_msg})')
}
