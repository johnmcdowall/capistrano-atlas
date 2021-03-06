require "digest"
require "monitor"
require "capistrano/atlas/version"
require "capistrano/atlas/compatibility"
require "capistrano/atlas/dsl"
require "capistrano/atlas/recipe"
include Capistrano::Atlas::DSL

load File.expand_path("../tasks/provision.rake", __FILE__)
load File.expand_path("../tasks/defaults.rake", __FILE__)
load File.expand_path("../tasks/enable_swap.rake", __FILE__)
load File.expand_path("../tasks/user.rake", __FILE__)
load File.expand_path("../tasks/aptitude.rake", __FILE__)
load File.expand_path("../tasks/ufw.rake", __FILE__)
load File.expand_path("../tasks/ssl.rake", __FILE__)
load File.expand_path("../tasks/dotenv.rake", __FILE__)
load File.expand_path("../tasks/postgresql.rake", __FILE__)
load File.expand_path("../tasks/nginx.rake", __FILE__)
load File.expand_path("../tasks/puma.rake", __FILE__)
load File.expand_path("../tasks/crontab.rake", __FILE__)
load File.expand_path("../tasks/logrotate.rake", __FILE__)
load File.expand_path("../tasks/rbenv.rake", __FILE__)
load File.expand_path("../tasks/maintenance.rake", __FILE__)
load File.expand_path("../tasks/migrate.rake", __FILE__)
load File.expand_path("../tasks/seed.rake", __FILE__)
load File.expand_path("../tasks/version.rake", __FILE__)
load File.expand_path("../tasks/rake.rake", __FILE__)
load File.expand_path("../tasks/sidekiq.rake", __FILE__)
load File.expand_path("../tasks/bundler.rake", __FILE__)
