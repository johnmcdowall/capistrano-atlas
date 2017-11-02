atlas_recipe :crontab do
  during "deploy:published", "atlas:crontab"
end

namespace :atlas do
  desc "Install crontab using crontab.erb template"
  task :crontab do
    on roles(:cron) do
      tmp_file = "/tmp/crontab"
      template "crontab.erb", tmp_file
      execute "crontab #{tmp_file} && rm #{tmp_file}"
    end
  end
end
