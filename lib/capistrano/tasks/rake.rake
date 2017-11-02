atlas_recipe :rake do
  # No hooks
end

namespace :atlas do
  desc "Remotely execute a rake task"
  task :rake do
    if ENV['COMMAND'].nil?
      raise "USAGE: cap #{fetch(:stage)} atlas:rake COMMAND=my:task"
    end

    on primary(:app) do
      within current_path do
        with :rails_env => fetch(:rails_env) do
          execute :rake, ENV['COMMAND']
        end
      end
    end
  end
end
