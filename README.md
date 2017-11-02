# capistrano-atlas

[![Gem Version](https://badge.fury.io/rb/capistrano-atlas.svg)](http://badge.fury.io/rb/capistrano-atlas)

**This is a fork of `capistrano-mb` by the excellent Matt Brictson and FiftyFive. I've changed things to use Puma and Let's Encrypt in production.**

Capistrano is great for deploying Rails applications, but what about all the prerequisites, like Nginx and PostgreSQL? Do you have a firewall configured on your VPS? Have you installed the latest OS security updates? Is HTTPS working right?

The capistrano-atlas gem adds a `cap <stage> provision` task to Capistrano that takes care of all that. Out of the box, `provision` will:

* Install the latest `postgresql`, `node.js`, and `nginx` apt packages
* Install all libraries needed to build Ruby
* Lock down your VPS using `ufw` (a simple front-end to iptables)
* Set up `logrotated` for your Rails logs
* Schedule an automatic daily backup of your Rails database
* Generate a self-signed SSL certificate if you need one
* Set up ngnix with the latest SSL practices and integrate it with Puma for your Rails app
* Create the `deployer` user and install an SSH public key
* Install `rbenv` and use `ruby-build` to compile the version of Ruby required by your app (by inspecting your `.ruby-version` file)
* And more!

The gem is named "capistrano-atlas" because it is prescribes my ([@mattbrictson](https://github.com/mattbrictson)) personal preferences for automating deployments of Rails projects. I'm a freelance developer juggling lots of Rails codebases, so its important for me to have a good, consistent server configuration. You'll notice that capistrano-atlas is opinionated and strictly uses the following stack:

* Ubuntu 14.04 LTS
* PostgreSQL
* Puma
* Nginx
* rbenv
* dotenv

In addition, capistrano-atlas changes many of Capistrano's defaults, including the deployment location, Bundler behavior, and SSH keep-alive settings. (See [defaults.rake][] for details.)

Not quite to your liking? Consider forking the project to meet your needs.


## Quick start

Please note that this project requires **Capistrano 3.x**, which is a complete rewrite of Capistrano 2.x. The two major versions are not compatible.

### 1. Purchase an Ubuntu 14.04 VPS

To use capistrano-atlas, you'll need a clean Ubuntu server to deploy to. The only special requirement is that your public SSH key must be installed on the server for the `root` user.

Test that you can SSH to the server as `root` without being prompted for a password. If that works, capistrano-atlas can take care of the rest. You're ready to proceed!

### 2. .ruby-version

capistrano-atlas needs to know the version of Ruby that your app requires, so that it can install Ruby during the provisioning process. Place a `.ruby-version` file in the root of your project containing the desired version, like this:

```
2.2.3
```

*If you are using `rbenv`, just run `rbenv local 2.2.3` and it will create this file for you.*

### 3. Gemfile

capistrano-atlas makes certain assumptions about your Rails app, namely that it uses [dotenv][] to manage Rails secrets via environment variables, and that it runs on top of PostgreSQL and [Puma][]. Make sure they are specified in the Gemfile:

```ruby
gem "dotenv-rails", ">= 2.0.0"
gem "pg", "~> 0.18"
gem "Puma"
```

Then for the capistrano-atlas tools themselves, add these gems to the development group:

```ruby
group :development do
  gem "capistrano-bundler", :require => false
  gem "capistrano-rails", :require => false
  gem "capistrano", "~> 3.4.0", :require => false
  gem "capistrano-atlas", :require => false
end
```

And then execute:

```
$ bundle
```

### 4. cap install

If your project doesn't yet have a `Capfile`, run `cap install` with the list of desired stages (environments). For simplicity, this installation guide will assume a single production stage:

```
cap install STAGES=production
```

### 5. Capfile

Add these lines to the **bottom** of your app's `Capfile` (order is important!):

```ruby
require "capistrano/bundler"
require "capistrano/rails"
require "capistrano/atlas"
```

### 6. deploy.rb

Modify `config/deploy.rb` to set the specifics of your Rails app. At the minimum, you'll need to set these two options:

```ruby
set :application, "my_app_name"
set :repo_url, "git@github.com:username/repository.git"
```

### 7. production.rb

Modify `config/deploy/production.rb` to specify the IP address of your production server. In this example, I have a single 1GB VPS (e.g. at DigitalOcean) that plays all the roles:

```ruby
server "my.production.ip",
       :user => "deployer",
       :roles => %w(app backup cron db web)
```

*Note that you must include the `backup` and `cron` roles if you want to make use of capistrano-atlas's database backups and crontab features.*

### 8. secrets.yml

By default, Rails 4.2 apps have a `config/secrets.yml` file that specifies the Rails secret key. capistrano-atlas configures dotenv to provide this secret in a `RAILS_SECRET_KEY_BASE` environment variable. You'll therefore need to modify `secrets.yml` as follows:

```ruby
production:
  secret_key_base: <%= ENV["RAILS_SECRET_KEY_BASE"] %>
```

### 9. Provision and deploy!

Run capistrano-atlas's `provision:14_04` task (named for Ubuntu 14.04). This will ask you a few questions, install Ruby, PostgreSQL, Nginx, etc., and set everything up. The entire process takes about 10 minutes (mostly due to compiling Ruby from source).

```
bundle exec cap production provision:14_04
```

Once that's done, your app is now ready to deploy!

```
bundle exec cap production deploy
```

## Advanced usage

### Choosing which recipes to auto-run

Most of the capistrano-atlas recipes are designed to run automatically as part of `cap <stage> provision`, for installing and setting up various bits of the Rails infrastructure, like nginx, Puma, and postgres. Some recipes also contribute to the `cap <stage> deploy` process.

*This auto-run behavior is fully under your control.*  In your `deploy.rb`, set `:atlas_recipes` to an array of the desired recipes. If you don't want a recipe to execute as part of `deploy`/`provision`, simply omit it from the list.

The following list will suffice for most out-of-the-box Rails apps. The order of the list is not important.

```ruby
set :atlas_recipes, %w(
  aptitude
  crontab
  dotenv
  logrotate
  migrate
  nginx
  postgresql
  rbenv
  seed
  ssl
  ufw
  Puma
  user
  version
)
```

Even if you don't include a recipe in the auto-run list, you can still invoke the tasks of those recipes manually at your discretion. Run `bundle exec cap -T` to see the full list of tasks.

### Configuration

Many of the recipes have default settings that can be overridden. Use your
`deploy.rb` file to specify these overrides. Or, you can override per stage.
Here is an example override:

    set :atlas_Puma_workers, 8

For the full list of settings and their default values, refer to [defaults.rake][].


## Further reading

Check out my [rails-template][] project, which generates Rails applications with capistrano-atlas pre-configured and ready to go.


## History

This gem used to be called capistrano-fiftyfive, because it was initially built by [55 Minutes](http://55minutes.com) to automate its Rails deployments. I have since taken over ownership of the gem and renamed it to capistrano-atlas to avoid any confusion.

If you are upgrading from `capistrano-fiftyfive`, refer to the [CHANGELOG entry for v0.22.0](CHANGELOG.md#0220-2015-06-22) for migration instructions.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


[Postmark]:https://postmarkapp.com
[cast337]:http://railscasts.com/episodes/337-capistrano-recipes
[cast373]:http://railscasts.com/episodes/373-zero-downtime-deployment
[defaults.rake]:lib/capistrano/tasks/defaults.rake
[rails-template]:https://github.com/mattbrictson/rails-template/
[dotenv]:https://github.com/bkeepers/dotenv
[Puma]:http://Puma.bogomips.org/
