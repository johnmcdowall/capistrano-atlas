atlas_recipe :nginx do
  during :provision, "configure"
end

namespace :atlas do
  namespace :nginx do
    desc "Install nginx.conf files and restart nginx"
    task :configure do
      privileged_on roles(:web) do
        template("nginx.erb", "/etc/nginx/nginx.conf", :sudo => true)

        execute "sudo service nginx restart"
      end
    end

    %w(start stop restart).each do |command|
      desc "#{command} nginx"
      task command.intern do
        privileged_on roles(:web) do
          execute "sudo service nginx #{command}"
        end
      end
    end
  end
end
