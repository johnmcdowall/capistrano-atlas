atlas_recipe :logrotate do
  during :provision, "atlas:logrotate"
end

namespace :atlas do
  desc "Configure logrotate for Rails logs"
  task :logrotate do
    privileged_on release_roles(:all) do
      template "logrotate.erb",
               "/etc/logrotate.d/#{application_basename}-logs",
               :mode => 644,
               :owner => "root:root",
               :sudo => true
    end
  end
end
