set :user, 'cvhu'
set :domain, 'ta2ed.cvhu.org'
set :application, "ta2ed"

set :shared_assets, %w{public/systems}
set :repository,  "git@github.com:cvhu/ta2ed.git"
set :deploy_to, "/home/#{user}/#{domain}"

role :web, domain
role :app, domain
role :db, domain, :primary => true


set :scm, 'git'
set :branch, 'master'
set :scm_verbose, true
set :use_sudo, false

set :stage, "production"


default_run_options[:pty] = true

# default_environment['PATH']="/home/cvhu/.rvm/gems/ruby-1.9.2-p290@dediced/bin:/home/cvhu/.rvm/gems/ruby-1.9.2-p290@global/bin:/home/cvhu/.rvm/rubies/ruby-1.9.2-p290/bin:/home/cvhu/.rvm/bin:/home/cvhu/.gems/bin:/usr/local/bin:/usr/bin:/bin:/usr/bin/X11:/usr/games"
# default_environment['GEM_PATH']="/home/cvhu/.rvm/gems/ruby-1.9.2-p290@dediced:/home/cvhu/.rvm/gems/ruby-1.9.2-p290@global"

namespace :deploy do
  desc "cause Passenger to initiate a restart"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  # desc "reload the database with seed data"
  # task :seed do
  #   run "cd #{current_path}; rake db:seed RAILS_ENV=production"
  # end
  # 
  # desc "Symlink shared configs and folders on each release."
  # task :symlink_shared do
  #   run "ln -nfs #{deploy_to}/shared/system/uploads #{release_path}/public/uploads"
  # end
end

# desc "Link the file"
# task :link_file do
#   run "ln -nfs #{deploy_to}/shared/system/uploads #{release_path}/public/uploads"
# end



# after "deploy", :link_file