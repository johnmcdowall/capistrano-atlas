atlas_recipe :ssl do
  prior_to "atlas:nginx:configure", "atlas:ssl:generate_dh"
  prior_to "atlas:nginx:configure", "atlas:ssl:configure_lets_encrypt"
end

namespace :atlas do
  namespace :ssl do
    desc "Setup Let's Encrypt and get a free certificate"
    task :configure_lets_encrypt do
      privileged_on roles(:web) do
        unless test("sudo [ -f /etc/ssl/#{application_basename}.crt ]")
          execute :sudo, "mkdir -p /opt/certbot"
          execute :sudo, "wget https://dl.eff.org/certbot-auto -O /opt/certbot/certbot-auto && chmod a+x /opt/certbot/certbot-auto"
          execute :sudo, "/opt/certbot/certbot-auto certonly --agree-tos "\
                         "--email #{fetch(:atlas_lets_encrypt_email)} "\
                         "--webroot -w /var/www/html "\
                         "-d #{fetch(:atlas_lets_encrypt_domain_name)}"

          execute :sudo, "ln -s /etc/letsencrypt/live/#{fetch(:atlas_lets_encrypt_domain_name)}/fullchain.pem /etc/ssl/#{application_basename}.crt"
          execute :sudo, "ln -s /etc/letsencrypt/live/#{fetch(:atlas_lets_encrypt_domain_name)}/privkey.pem /etc/ssl/#{application_basename}.key"                         
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