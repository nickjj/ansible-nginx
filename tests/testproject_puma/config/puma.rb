threads 0,16
workers 2

pidfile 'tmp/puma.pid'
bind "unix://tmp/puma.sock"

# https://github.com/puma/puma/blob/master/examples/config.rb#L125
prune_bundler

restart_command 'bundle exec bin/puma'

on_worker_boot do
  require 'active_record'

  config_path = File.expand_path('../database.yml', __FILE__)
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || YAML.load_file(config_path)[ENV['RAILS_ENV']])
end
