atlas_recipe :ufw do
  during :provision, "configure"
end

namespace :atlas do
  namespace :ufw do
    desc "Configure role-based ufw rules on each server"
    task :configure do
      rules = fetch(:atlas_ufw_rules, {})
      distinct_roles = rules.values.flatten.uniq

      # First reset the firewall on all affected servers
      privileged_on roles(*distinct_roles) do
        execute "sudo ufw --force reset"
        execute "sudo ufw default deny incoming"
        execute "sudo ufw default allow outgoing"
      end

      # Then set up all ufw rules according to the atlas_ufw_rules hash
      rules.each do |command, *role_names|
        privileged_on roles(*role_names.flatten) do
          execute "sudo ufw #{command}"
        end
      end

      # Finally, enable the firewall on all affected servers
      privileged_on roles(*distinct_roles) do
        execute "sudo ufw --force enable"
      end
    end
  end
end
