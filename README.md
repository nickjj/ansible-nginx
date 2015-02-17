## WARNING: This role will be deprecated very soon

All of the functionality provided by this role and more is available in the [DebOps project](http://debops.org). If you are using some of my roles in conjunction with each other, you will find the move to DebOps most pleasurable.

This role will be **removed** from the **galaxy** and from **github** anywhere from 42 microseconds to 2-3 weeks after you read this message.

---


## What is ansible-nginx? [![Build Status](https://secure.travis-ci.org/nickjj/ansible-nginx.png)](http://travis-ci.org/nickjj/ansible-nginx)

It is an [ansible](http://www.ansible.com/home) role to install the latest version of nginx stable, configure a backend (upstream) and optionally configure ssl.

### What problem does it solve and why is it useful?

I wasn't happy with any of the nginx roles that I came across. They were either overly complex, tried to be too modular by allowing you to define an entire backend using yaml syntax or were missing features that I really wanted.

Here is a feature list of this role:

- Configure an nginx server with sane defaults in less than 5 lines of yaml settings
- Change the listen ports for both http and https
- Toggle the ability to serve static assets and supply your own asset matching regex
- Toggle the ability to redirect a server to the www variant
- Add as many location blocks as you want with the least amount of pain
- Setup any number of error pages using the most simple syntax possible
  - This is useful if you want custom 404, 500 or maintenance pages
- Define a root path and upsteam name/server location
- Optionally support ssl
  - Toggle a single variable to turn ssl on or off
  - Toggle whether or not http requests should redirect to https
  - Transfer your cert/key to the server
  - Choose the ssl type
  - Pick the cipher and curve
  - Support and set the strict transport header with tweakable values
  - Support session caching and timeout with tweakable values

## Role variables

Below is a list of default values along with a description of what they do.

```
# What port should nginx listen on for http requests?
nginx_listen: 80

# Your domain name.
nginx_base_domain: "{{ ansible_fqdn }}"

# The server name. This could be the base domain or perhaps
# foo.{{ nginx_base_domain }} or www.{{ nginx_base_domain }}
nginx_server_name: "{{ nginx_base_domain }}"

# Should it automatically redirect the base domain to the www version?
nginx_base_redirect_to_www: false

# What type of backend are you using and what is its location?
nginx_upstream_name: testproject
nginx_upstream_server: unix:///srv/{{ nginx_upstream_name }}/tmp/puma.sock
nginx_backend_name: puma

# Where are your public files stored?
nginx_root_path: /srv/{{ nginx_upstream_name }}/public

# Should nginx serve static assets?
nginx_assets_enabled: true

# The regex to match for serving static assets.
nginx_assets_regex: "~ ^/(system|assets)/"

# A dict containing an array of error pages.
# If you have none then set the nginx_error_pages to be an empty string.
nginx_error_pages:
  - { error_code: 404, error_page: 404.html }
  - { error_code: 500, error_page: 500.html }
  - { error_code: 502 503 504, error_page: 502.html }

# By default there are no extra locations but you can add as many as you want.
# Don't forget the | to enable text blocks, feel free to use template tags too.
# The values must be valid nginx syntax, don't forget the semi-colons!
nginx_extra_locations: |
#  location / {
#    return;
#  }
#
#  location ~ ^/(images|javascript|js|css|flash|media|static)/ {
#    # directive 1 would go here;
#    # directive 2 would go here;
#    # ... add as many directives as you want;
#  }

# If this is false then none of the ssl values are output to your nginx config.
nginx_ssl: false

# Set this to false if you have a separate role that manages copying
# SSL certificates/keys to the server, and don't want this role
# to attempt copying your SSL keys over
nginx_ssl_manage_certs: true

# What port should nginx listen on for https requests?
nginx_listen_ssl: 443

# Should all requests be redirected to https?
nginx_server_redirect_to_ssl: false

# Legal values are: selfsigned, signed or wildcard
nginx_ssl_type: selfsigned

# Perfect forward secrecy cipher.
nginx_ssl_ciphers: "EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH+aRSA+RC4:EECDH:EDH+aRSA:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS:!RC4"

# Best practice according to https://bettercrypto.org/.
nginx_ssl_ecdh_curve: secp384r1

# If you are using a wildcard certificate then which domain will be used?
nginx_ssl_wildcard_domain: "{{ ansible_domain }}"

# http://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security
nginx_ssl_strict_transport_header_age: 15768000

# Non-default values to increase performance, the nginx default is:
# nginx_ssl_session_cache: none
nginx_ssl_session_cache: shared:SSL:10m

# Non-default values to increase performance, the nginx default is:
# nginx_ssl_session_timeout: 5m
nginx_ssl_session_timeout: 10m

# What local path contains your cert and key?
nginx_ssl_local_path: /home/yourname/dev/testproject/secrets

# What are the file names for both your cert and key?
nginx_ssl_cert_name: sslcert.crt
nginx_ssl_key_name: sslkey.key

# The amount in seconds to cache apt-update.
apt_cache_valid_time: 86400

# Should we install the Custom PPA for nginx?
# Disable this if you are not using Ubuntu. If you set nginx_configure_ppa to false,
# you will probably need to set 'nginx_spdy_enabled: false' too, since only the PPA version
# includes spdy. nginx_names_hash_bucket_size will also need to be set to 64 in most cases
nginx_configure_ppa: true

# Should the SPDY extension be enabled?
nginx_spdy_enabled: true

# Configure server_names_hash_bucket_size
nginx_names_hash_bucket_size: 32

```

## Example playbook without ssl

For the sake of this example let's assume you have a group called **app** and you have a typical `site.yml` file.

To use this role edit your `site.yml` file to look something like this:

```
---
- name: ensure app servers are configured
- hosts: app

  roles:
    - { role: nickjj.nginx, tags: nginx }
```

Let's say you want to edit a few defaults, you can do this by opening or creating `group_vars/app.yml` which is located relative to your `inventory` directory and then making it look something like this:

```
---
nginx_upstream_name: awesomeapp
nginx_base_redirect_to_www: true
```

## Example playbook with ssl

First things first, make sure you read the section above because setting up the ssl version of this role is the same as the non-ssl version except it requires a few more defaults to be changed.

#### Do you need an ssl certificate and key?

If you just want to mess around and ensure your server responds correctly to https requests then you can use self signed keys. The downside to using self signed keys is that users of your site will see a giant warning saying your domain cannot be trusted because the keys are not verified.

This is fine for testing because you can just click the proceed button and your site will work as planned.

To generate your own self signed keys, open a terminal and goto some directory, let's say `~/tmp`. Within this directory enter the following command:

`$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout sslkey.key -out sslcert.crt`

That will generate both a certificate and key using 2048 bit encryption. Keep note of the path of where you created these files.

#### Do you have a signed ssl certificate and key from a trusted source?

Excellent, put them somewhere and keep note of their file names.

#### You are ready to change a few defaults

Overwrite at least the following default value(s) in `group_vars/all.yml`:

```
nginx_ssl: true

nginx_ssl_local_path: PUT_YOUR_CERT_AND_KEY_PATH_HERE

# If you are using a signed key from a trusted source then you need to also change:
# nginx_ssl_type: signed

# If your files are not called `sslcert.crt` and `sslkey.key` then overwrite them:
# nginx_ssl_cert_name: sslcert.crt
# nginx_ssl_key_name: sslkey.key
```

## Installation

`$ ansible-galaxy install nickjj.nginx`

## Requirements

Tested on ubuntu 12.04 LTS but it should work on other versions that are similar.

## Troubleshooting common errors

#### The server hangs when trying to connect to either http or https
Assuming you have no syntax errors in your nginx config and the ansible run completed successfully then the most common error would be that you have a firewall blocking port 80 and/or port 443.

If that's not the case then make sure your backend is working as intended and check any relevant log files.

#### The ansible run finished without errors but you do not see any changes
This is likely due to their being a syntax error in your nginx config. Check your regular expressions, paths and if you are using extra locations then make sure they are all good.

Chances are you forgot a trailing semi-colon in one of the directives or some path didn't exist.

You can ssh into the server manually and run `$ sudo service nginx reload`. If it fails then you can be sure there is a syntax error somewhere.

#### None of my assets are being updated
I made an assumption that you are minifying, concatinating and tagging each asset with an md5 of their contents as well as gzipping them with maximum compression before hand as part of your build process.

This is common for rails apps and apps developed with other web frameworks. With that said, I automatically set them to be cached for a year and turned `gzip_static on` for just those assets.

If your web application does not perform the above tasks then you should start doing them but if you're stubborn or do not have the ability to make this decision then set `nginx_assets_enabled` to false and write your own location block with `nginx_extra_locations`.

## Ansible galaxy

You can find it on the official [ansible galaxy](https://galaxy.ansible.com/list#/roles/856) if you want to rate it.

## License

MIT