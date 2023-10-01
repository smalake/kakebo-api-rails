max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

rails_env = ENV.fetch("RAILS_ENV") { "development" }

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
# port ENV.fetch("PORT") { 3000 }
port ENV.fetch("PORT") { 8080 }

# Specifies the `environment` that Puma will run in.
environment rails_env

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

workers ENV.fetch("WEB_CONCURRENCY") { 4 }
preload_app!

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
