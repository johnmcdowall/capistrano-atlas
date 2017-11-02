atlas_recipe :ssl do
  during :provision, "generate_dh"
  during :provision, "configure_lets_encrypt"
end

namespace :atlas do
  namespace :ssl do
    desc "Setup Let's Encrypt and get a free certificate"
    task :configure_lets_encrypt do
      privileged_on roles(:web) do
        unless test("sudo [ -f /etc/ssl/#{application_basename}.crt ]")
          execute :sudo, "mkdir -p /opt/certbot"
          execute :sudo, "cd /opt/certbot/; wget https://dl.eff.org/certbot-auto; chmod a+x certbot-auto;"
          execute :sudo, "/opt/certbot/certbot-auto certonly --agree-tos "\
                         "--email #{letsencrypt_email} --webroot "\
                         "-w #{current_path}/public "\
                         "-d #{fetch(:atlas_lets_encrypt_domain_name)}"
        end
      end
    end

    desc "Generate unique DH group"
    task :generate_dh do
      privileged_on roles(:web) do
        unless test("sudo [ -f /etc/ssl/dhparams.pem ]")
          execute :sudo, "openssl dhparam -out /etc/ssl/dhparams.pem 2048 > /dev/null 2>&1"
          execute :sudo, "chmod 600 /etc/ssl/dhparams.pem"
        end
      end
    end
  end
end
