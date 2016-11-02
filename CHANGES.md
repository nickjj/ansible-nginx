# Changelog

### v0.3.1

*Released: November 2nd 2016*

- Add basic auth support
- Add `custom_root_location_try_files` property to virtual hosts
- Rename `nginx_default_upstream_proxy_settings` to describe it's a default

### v0.3.0

*Released: October 27nd 2016*

- Support for multiple vhosts
- Support for 0 or 1 more optionally load balanced upstreams
- Add many more configurable `nginx.conf` variables
- Add more optional customizations for vhosts
- Generate self signed SSL certificates for non-production environments
- Forces HTTPS (seamless integration with Let's Encrypt with 3rd party roles)
- Generate a unique `dhparam.pem` file when it doesn't exist
- Test against Ubuntu 16.04 LTS and Debian Jessie on Travis-CI
- Update to Ansible 2.0+

### v0.2.0

*Released: February 18th 2014*

- SSL protocols can be configured
- Redirect properly sets trailing forward slash

Thanks to PRs https://github.com/nickjj/ansible-nginx/pull/4 and https://github.com/nickjj/ansible-nginx/pull/5.

### v0.1.6

*Released: February 18th 2014*

- Option to disable the custom PPA
- Option to disable spdy
- Option to configure `server_names_hash_bucket_size`

Thanks to this PR https://github.com/nickjj/ansible-nginx/pull/3.

### v0.1.5

*Released: June 12th 2014*

- Merged #1 which introduces `nginx_ssl_manage_certs` (true / false)
  - Now you can enable ssl but you can use whatever means necessary to transfer the certs

### v0.1.4

*Released: August 18th 2014*

- Fixed a bug that caused the handlers not to execute

### v0.1.3

*Released: June 2nd 2014*

- Fix a bug that caused testproj to be hard coded as the sites-available name
- Change nginx_extra_locations to take a text block so it's easier to add location block

### v0.1.2

*Released: June 1st 2014*

- Use a variable to store the apt-update cache time

### v0.1.1

*Released: May 9th 2014*

- Add a section linking to the Ansible Galaxy
- Update a few sentences and fix grammar mistakes
- Reload nginx if the SSL cert/key change

### v0.1.0

*Released: May 9th 2014*

- Initial release
