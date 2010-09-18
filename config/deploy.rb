set :application, "fat_free_crm"
set :repository,  "git@github.com:marcin/fat_free_crm.git"
set :scm, "git"
set :branch, "master"
set :deploy_via, :remote_cache


set :use_sudo, false
set :user, "app"

set :deploy_to, "/app/fat_free_crm"
set :shared_to, "/app/fat_free_crm/shared"
role :app, "siteor.com"
role :web, "siteor.com"
role :db,  "siteor.com", :primary => true


namespace :deploy do
  task :restart, :roles => [:web, :app] do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end
end


task :after_deploy, :roles => [:web, :app] do

  run "cp #{deploy_to}/shared/database.yml #{deploy_to}/current/config/database.yml"

  run "rm #{deploy_to}/current/config/deploy.rb"
  run "rm #{deploy_to}/current/README.rdoc"


end

task :after_setup, :roles => [:web, :app] do
  run "mkdir #{shared_to}"
  run "mv -f #{deploy_to}/shared/* #{shared_to}"
  run "rm -R -f #{deploy_to}/shared"
  run "ln -s #{shared_to} #{deploy_to}/shared"
end

task :log, :roles => :app do
  run "tail -f #{deploy_to}/current/log/production.log"
end


namespace :jt do
  

  desc "Sciaganie bazy danych z produkcji"
  task :backup, :roles => :app do
    run "cd #{deploy_to}/current; mkdir db/backup; rake jt:backup RAILS_ENV=production"
    download("#{deploy_to}/current/db/backup/*-production.sql.gz", "./db/backup", :via=> :scp, :recursive => true)
    puts "Czy zastapic lokalna baze baza z produkcji? (t/N)"
    c = STDIN.getc
    if c == 't'[0] or c == 'T'[0]
      puts "wywoluje: rake jt:replace_dev ...."
      puts `rake jt:replace_dev`
    end
    #puts "lub nadpisz lavine: gzip -d db/backup/lavina-production.sql.gz; mysql lavina_software -h lavina.javatech.com.pl -u root -p < db/backup/lavina-production.sql"
  end

  # desc "Sciaganie plików produkcji"
  # task :prod_files, :roles => :app do
  #   download("#{deploy_to}/current/public/system", "./public", :via=> :scp, :recursive => true)
  # end

  desc "Kasowanie css"
  task :css do
    run "rm  #{deploy_to}/current/public/stylesheets/all*.css"
  end

  desc "Kasowanie js"
  task :js do
    run "rm  #{deploy_to}/current/public/javascripts/all*.js"
  end

  desc "Kasowanie all"
  task :all do
    run "rm  #{deploy_to}/current/public/javascripts/all*.js"
    run "rm  #{deploy_to}/current/public/stylesheets/all*.css"
  end
  
  task :update_layouts do
    run "cd #{deploy_to}/current; rake jt:update_layouts RAILS_ENV=production"
  end
  task :newsletter do
    run "cd #{deploy_to}/current; rake lavina:newsletter RAILS_ENV=production"
  end
  
  task :delayed_job do
#    run "cd #{deploy_to}/current; RAILS_ENV=production script/delayed_job stop"   
    run "cd #{deploy_to}/current; RAILS_ENV=production script/delayed_job start"
  end 
  

end
