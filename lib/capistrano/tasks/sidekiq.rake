atlas_recipe :sidekiq do
  during :provision, "init_d"
  during "deploy:start", "start"
  during "deploy:stop", "stop"
  during "deploy:restart", "restart"
  during "deploy:publishing", "restart"
end

namespace :atlas do
  namespace :sidekiq do
    desc "Install sidekiq service script"
    task :init_d do
      privileged_on roles(fetch(:atlas_sidekiq_role)) do |host, user|
        template "sidekiq_init.erb",
                 "/etc/init.d/sidekiq_#{application_basename}",
                 :mode => "a+rx",
                 :binding => binding,
                 :sudo => true

        execute "sudo update-rc.d -f sidekiq_#{application_basename} defaults"
      end
    end

    %w[start stop].each do |command|
      desc "#{command} sidekiq"
      task command do
        on roles(fetch(:atlas_sidekiq_role)) do
          execute "service sidekiq_#{application_basename} #{command}"
        end
      end
    end

    desc "restart sidekiq"
    task :restart do
      # Re-enable the "stop" task, just in case we called it once already
      # (as would happen during deploy:migrate_and_restart).
      Rake::Task["atlas:sidekiq:stop"].reenable
      invoke "atlas:sidekiq:stop"
      invoke "atlas:sidekiq:start"
    end
  end
end
