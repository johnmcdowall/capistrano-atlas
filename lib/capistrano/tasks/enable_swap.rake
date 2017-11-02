atlas_recipe :enable_swap do
  during :provision, "configure"
end

namespace :atlas do
  namespace :enable_swap do

    desc "Configure swap file"
    task :configure do
      rules = fetch(:atlas_ufw_rules, {})

      on release_roles(:all) do
        execute "sudo fallocate -l 4G /swapfile"
        execute "sudo chmod 600 /swapfile"
        execute "sudo mkswap /swapfile"
        execute "sudo swapon /swapfile"
        execute "sudo echo \"/swapfile   none    swap    sw    0   0\" > /etc/fstab"
        execute "sudo sysctl vm.swappiness=10"
        execute "sudo echo \"vm.swappiness=10\" > /etc/sysctl.conf"
        execute "sudo sysctl vm.vfs_cache_pressure=50"
        execute "sudo echo \"vm.vfs_cache_pressure = 50\" > /etc/sysctl.conf"
      end
    end

  end
end
