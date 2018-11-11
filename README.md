## What is ansible-nginx? [![Build Status](https://secure.travis-ci.org/nickjj/ansible-nginx.png)](http://travis-ci.org/nickjj/ansible-nginx)

It is an [Ansible](http://www.ansible.com/home) role to install and configure
nginx. It has first class support for Let's Encrypt but works out of the box
with self signed SSL certificates for non-production environments.

##### Supported platforms:

- Ubuntu 16.04 LTS (Xenial)
- Debian 8 (Jessie)

### What problem does it solve and why is it useful?

I wasn't happy with any of the nginx roles that I came across. They were either
overly complex or were missing features that I really wanted.

Here's what you get with this role:

- Configure 1 or more sites-enabled (virtual hosts)
- Configure 0 or more upstreams per virtual host
- Configure a working site in as little as 3 lines of YAML
- Forced HTTPS with A+ certificate ratings (bearing your certificate authority)
- Self signed certs are generated to work out of the box for non-production environments
- First class support for Let's Encrypt SSL certificates for production environments
- Tune a bunch of `nginx.conf` settings for performance
- Allow you to optionally declare custom nginx and vhost directives easily
- Allow you to easily customize your upstream's proxy settings

## Role variables

Below is a list of default values along with a description of what they do.

```yaml
---

# Should nginx itself be installed? You may want to set this to False in
# situations where you use Ansible to provision a server but run everything
# inside of Docker containers. You could use this role to manage your configs
# but not run nginx by setting this to False.
nginx_install_service: True

# Which user/group should nginx belong to?
nginx_user: 'www-data'

# Various nginx config values set up to be efficient and secure, feel free to
# Google each one as needed for details.
nginx_worker_processes: 'auto'
nginx_worker_rlimit_nofile: 4096
nginx_events_worker_connections: 1024
nginx_http_server_tokens: 'off'
nginx_http_add_headers:
  - 'X-Frame-Options SAMEORIGIN'
  - 'X-Content-Type-Options nosniff'
  - 'X-XSS-Protection "1; mode=block"'
nginx_http_server_names_hash_bucket_size: 64
nginx_http_server_names_hash_max_size: 512
nginx_http_sendfile: 'on'
nginx_http_tcp_nopush: 'on'
nginx_http_keepalive_timeout: 60
nginx_http_client_max_body_size: '1m'
nginx_http_types_hash_max_size: 2048
nginx_http_gzip: 'on'
nginx_http_gzip_types: 'text/plain text/css application/javascript application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript image/svg+xml image/svg'
nginx_http_gzip_disable: 'msie6'

# Add your own custom nginx.conf main directives in a list.
# Example:
#   nginx_main_directives:
#     - 'include /etc/nginx/modules-enabled/*.conf'
nginx_main_directives: []

# Add your own custom nginx.conf http directives in a list.
# Example:
#   nginx_http_directives:
#     - 'auth_http_header X-Auth-Key "secret_string"'
nginx_http_directives: []

# Configure 0 or more basic auth logins, for example:
#  nginx_basic_auth:
#    - { user: 'nick', password: 'insecurepassword' }
nginx_basic_auth: []

# Where should we find the SSL certificate?
nginx_ssl_directory: /etc/nginx/ssl

# How many bits should we use to generate a dhparam?
# Technically 2048 is 'good enough' but 4096 combined with a few other
# things will get you to a perfect 100 A+ SSL rating, do not go below 2048.
#
# Time to generate on a 512MB DO droplet: 2048 = 40 seconds, 4096 = 40 minutes.
nginx_ssl_dhparam_bits: 2048

# If defined, overrides the default value for SSL certificate names. If you
# leave this undefined, then it will become the file name of the first domain listed
# in the domains list when defining a virtual host (look in the next section).
#
# Setting this comes in handy if you use Let's Encrypt and want to register a
# single certificate that has multiple domains attached to it.
# This variable should not be left blank as it may cause undesired results
# nginx_ssl_override_filename: 'customname'

# Should self signed certificates get generated? Some form of certificate needs
# to be available for this role to work, so it's enabled by default. You would
# set it to false once you have your real certificates in place.
nginx_ssl_generate_self_signed_certs: True

# Default values for your virtual hosts and upstreams.
nginx_default_sites:
  # Name of the virtual host and file name of the config, example: default.conf.
  default:
    # 1 or more domains to be set for server_name. If you wish to support both
    # www and no www then supply them like so: domains: ['foo.com', 'www.foo.com'].
    # In the above case, www.foo.com will redirect to foo.com.
    # If you want www in your URL then swap the order in the domains list.
    domains: []
    # Will this virtual host be the default server? You should set this to
    # True so that if someone accesses your server's IP address directly, it
    # will automatically redirect to this vhost.
    default_server: False
    # Listen ports for both HTTP and HTTPS.
    listen_http: 80
    listen_https: 443
    # Where are your public files located?
    # If you're using an upstream, this will likely need to change to your web
    # framework's public path, such as: /path/to/myapp/public.
    root: '/usr/share/nginx/html'
    # Do you have any custom directives for this vhost?
    # Example:
    #   nginx_directives:
    #     - 'access_log logs/access.log combined'
    directives: []
    ssl:
      # Default SSL settings that get you an A+ rating as long as you chain your
      # certificate with an intermediate certificate.
      protocols: 'TLSv1 TLSv1.1 TLSv1.2'
      ciphers: 'ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4'
      prefer_server_ciphers: 'on'
      session_cache: 'shared:SSL:50m'
      session_timeout: '5m'
      ssl_stapling: 'on'
      ssl_stapling_verify: 'on'
      resolver: '8.8.8.8'
      resolver_timeout: '5s'
      # You may want to consider adding ;preload once you're 100% confident
      # that your server is working over HTTPS and you won't use HTTP for 2 years.
      # See: https://www.owasp.org/index.php/HTTP_Strict_Transport_Security_Cheat_Sheet
      sts_header: 'Strict-Transport-Security "max-age=63072000; includeSubdomains;"'
    cache_all_locations:
      # Shall we cache all requests for a bit of time? If so, how long?
      enabled: True
      duration: '30s'
    error_pages:
      # You will need to supply your own 404.html and 500.html files if you enable
      # this. It's enabled by default because 99.9% of the time you do want these.
      # You can disable this by setting, error_pages: [].
      - { code: 404, page: '404.html' }
      - { code: 500, page: '500.html' }
    serve_assets:
      # Let's serve assets through nginx, adjust the pattern depending on what web
      # framework you use. Caching is set to maximum time because most frameworks
      # have a way for you to md5 tag assets to cache bust them in one way or another.
      # If your framework does not have that capability, disable the cache setting,
      # or set it to a lower amount of your choosing.
      enabled: True
      pattern: ' ~ ^/assets/'
      expires: 'max'
    # Perhaps you'd like to include your own location blocks, no problem. Just add
    # in your location block(s) as you would inside of an nginx config. Example:
    #   custom_locations: |
    #     location ~ / {
    #       return;
    #     }
    custom_locations: ''
    # If you want to override the default / location's try_files, this is the
    # place to do it. This could be useful for php-fpm based virtual hosts.
    custom_root_location_try_files: ''
    # Set direct_proxy to the name of an upstream to proxy ALL requests to it
    # (bypasses try_file directive). Example:
    # direct_proxy: apache
    # upstreams:
    #     - name: apache
    #       servers: ['apache_upstream_server']
    direct_proxy: ''
    # Is basic auth enabled for this virtual host?
    basic_auth: False
    # A 1 line message to show during the authentication required dialog.
    basic_auth_message: 'Please sign in.'
    disallow_hidden_files:
      # Block all hidden files and directories, disable at your own risk.
      enabled: True
    # Configure 0 or more upstreams in a list, the first item in the list will
    # be the default try_files fall-back endpoint, for example:
    #   upstreams:
          - name: 'myapp'
            servers: ['localhost:3000']
          - name: 'websocketapp'
            servers: ['localhost:3001']
            add_proxy_settings:
              - 'proxy_http_version 1.1'
              - 'proxy_set_header Upgrade $http_upgrade'
    # The template that generates this config expects you to define at least
    # the name and servers. It will blow up if you don't.
    upstreams: []

# Customize the upstream's proxy settings if you want, these are the defaults
# and they will be pre-pended to your list of optional upstream proxy settings.
nginx_default_upstream_proxy_settings:
  - 'proxy_set_header X-Real-IP $remote_addr'
  - 'proxy_set_header X-Forwarded-Proto $scheme'
  - 'proxy_set_header Host $http_host'
  - 'proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for'
  - 'proxy_redirect off'

# If you're using Let's Encrypt, you can configure nginx to accept challenges to
# validate your domain(s). An HTTP based challenge is already set up for you.
#
# If you're using this role along with my LE role you don't need to touch this.
#
# That role can be found here: https://github.com/nickjj/ansible-letsencrypt
nginx_letsencrypt_root: '/usr/share/nginx/challenges'

# This is the value you'll set in your inventory to override any of the defaults
# from nginx_default_sites. A complete example is shown later on in this README.
nginx_sites: {}
```

## Example playbook

For the sake of this example let's assume you have a group called **app** and
you have a typical `site.yml` file.

To use this role edit your `site.yml` file to look something like this:

```yaml
---

- name: Configure app server(s)
  hosts: app
  become: True

  roles:
    - { role: nickjj.nginx, tags: nginx }
```

Let's say you want to accomplish the following goals:

- Set up your main site to work on non-www and www
- Have all www requests get redirected to non-www
- Set up the main host as the default server
- Set up an upstream to serve a back-end using your web framework of choice
- Load balance between 2 upstream servers
- Configure a blog sub-domain with assets being served by a CDN
- Password protect the blog because who needs visitors!

Start by opening or creating `group_vars/app.yml` which is located relative
to your `inventory` directory and then making it look like this:

```yaml
---

nginx_basic_auth:
  - { user: 'coolperson', password: 'heylookatmeicanviewtheprivateblog' }

nginx_sites:
  default:
    domains: ['example.com', 'www.example.com']
    default_server: True
    upstreams:
      - name: 'myapp'
        servers: ['localhost:3000', 'localhost:3001']
  blog:
    domains: ['blog.example.com']
    serve_assets:
      enabled: False
    basic_auth: True
```

## Installation

`$ ansible-galaxy install nickjj.nginx`

## Ansible Galaxy

You can find it on the official
[Ansible Galaxy](https://galaxy.ansible.com/nickjj/nginx/) if you want to
rate it.

## License

MIT

## Special thanks

Thanks to [Maciej Delmanowski](https://twitter.com/drybjed) for helping me debug
a few tricky issues with this role. He is the creator of [DebOps](https://debops.org/).
