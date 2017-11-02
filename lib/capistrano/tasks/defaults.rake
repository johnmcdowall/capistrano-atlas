namespace :load do
  task :defaults do

    set :atlas_recipes, %w(
      aptitude
      enable_swap
      bundler
      crontab
      dotenv
      logrotate
      migrate
      nginx
      puma
      postgresql
      rbenv
      seed
      ssl
      ufw
      user
      version
    )

    set :atlas_privileged_user, "root"

    set :atlas_aptitude_packages,
        "build-essential"                        => :all,
        "curl"                                   => :all,
        "debian-goodies"                         => :all,
        "git-core"                               => :all,
        "libpq-dev@ppa:pitti/postgresql"         => :all,
        "libreadline-gplv2-dev"                  => :all,
        "libssl-dev"                             => :all,
        "libxml2"                                => :all,
        "libxml2-dev"                            => :all,
        "libxslt1-dev"                           => :all,
        "nginx@ppa:nginx/stable"                 => :web,
        "nodejs"                                 => :web,
        "ntp"                                    => :all,
        "postgresql-client@ppa:pitti/postgresql" => :all,
        "postgresql@ppa:pitti/postgresql"        => :db,
        "tklib"                                  => :all,
        "ufw"                                    => :all,
        "zlib1g-dev"                             => :all

    set :atlas_bundler_lockfile, "Gemfile.lock"
    set :atlas_bundler_gem_install_command,
        "gem install bundler --conservative --no-document"

    set :atlas_dotenv_keys, %w(rails_secret_key_base postmark_api_key)
    set :atlas_dotenv_filename, -> { ".env.#{fetch(:rails_env)}" }

    set :atlas_log_file, "log/capistrano.log"

    set :atlas_nginx_force_https, false
    set :atlas_nginx_redirect_hosts, {}

    set :atlas_puma_threads, "0, 8"
    set :atlas_puma_workers, 2
    set :atlas_puma_timeout, 30
    set :atlas_puma_config, ->{ "#{current_path}/config/puma.rb" }
    set :atlas_puma_stdout_log, ->{ "#{current_path}/log/puma.stdout.log" }
    set :atlas_puma_stderr_log, ->{ "#{current_path}/log/puma.stderr.log" }
    set :atlas_puma_pid, ->{ "#{current_path}/tmp/pids/puma.pid" }

    ask :atlas_postgresql_password, nil, :echo => false
    set :atlas_postgresql_pool_size, 5
    set :atlas_postgresql_host, "localhost"
    set :atlas_postgresql_database,
        -> { "#{application_basename}_#{fetch(:rails_env)}" }
    set :atlas_postgresql_user, -> { application_basename }
    set :atlas_postgresql_pgpass_path,
        proc{ "#{shared_path}/config/pgpass" }
    set :atlas_postgresql_backup_path, -> {
      "#{shared_path}/backups/postgresql-dump.dmp"
    }
    set :atlas_postgresql_backup_exclude_tables, []
    set :atlas_postgresql_dump_options, -> {
      options = fetch(:atlas_postgresql_backup_exclude_tables).map do |t|
        "-T #{t.shellescape}"
      end
      options.join(" ")
    }

    set :atlas_rbenv_ruby_version, -> { IO.read(".ruby-version").strip }
    set :atlas_rbenv_vars, -> {
      {
        "RAILS_ENV" => fetch(:rails_env),
        "PGPASSFILE" => fetch(:atlas_postgresql_pgpass_path)
      }
    }

    set :atlas_sidekiq_concurrency, 25
    set :atlas_sidekiq_role, :sidekiq

    ask :atlas_ssl_csr_country, "US"
    ask :atlas_ssl_csr_state, "California"
    ask :atlas_ssl_csr_city, "San Francisco"
    ask :atlas_ssl_csr_org, "Example Company"
    ask :atlas_ssl_csr_name, "www.example.com"

    # WARNING: misconfiguring firewall rules could lock you out of the server!
    set :atlas_ufw_rules,
        "allow ssh" => :all,
        "allow http" => :web,
        "allow https" => :web


    set :bundle_binstubs, false
    set :bundle_flags, "--deployment --retry=3 --quiet"
    set :bundle_path, -> { shared_path.join("bundle") }
    set :deploy_to, -> { "/home/deployer/apps/#{fetch(:application)}" }
    set :keep_releases, 10
    set :linked_dirs, -> {
        ["public/#{fetch(:assets_prefix, 'assets')}"] +
        %w(
          .bundle
          log
          tmp/pids
          tmp/cache
          tmp/sockets
          public/.well-known
          public/system
          node_modules
        )
    }
    set :linked_files, -> {
        [fetch(:atlas_dotenv_filename)] +
        %w(
          config/database.yml
        )
    }
    set :log_level, :debug
    set :migration_role, :app
    set :rails_env, -> { fetch(:stage) }
    set :ssh_options, :compression => true, :keepalive => true

    SSHKit.config.command_map[:rake] = "bundle exec rake"
  end
end
