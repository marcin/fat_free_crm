set :application, "fatfreecrm"
set :repository,  "git@github.com:marcin/fat_free_crm.git"
set :scm, "git"
set :branch, "master"
set :deploy_via, :remote_cache


set :use_sudo, false
set :user, "app"

set :deploy_to, "/app/fatfreecrm"
set :shared_to, "/app/fatfreecrm/shared"
role :app, "siteor.com"
role :web, "siteor.com"
role :db,  "siteor.com", :primary => true

#egipt = false
# task :egipt do
#   egipt = true
#   set :deploy_to, "/app/lavina"
#   set :shared_to, "/mnt/shared/lavina"
#   role :app, "egipt.lavinaplatform.com"
#   role :web, "egipt.lavinaplatform.com"
#   role :db,  "egipt.lavinaplatform.com", :primary => true
# end


# task :urpl do
#   urpl = true
#   set :deploy_to, "/app/urpl"  
#   set :shared_to, "/mnt/shared/urpl"
#   role :app, "195.66.86.100"
#   role :web, "195.66.86.100"
#   role :db,  "195.66.86.100", :primary => true
# end


namespace :deploy do
  # before 'deploy', "wenus_default"
  # before 'deploy:upload', "wenus_default"
  # before 'deploy:restart', "wenus_default"
  # before 'deploy:migrate', "wenus_default"
  # before 'deploy:migrations', "wenus_default"
  
  task :restart, :roles => [:web, :app] do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end
end

# task :before_deploy, :roles => [:web, :app] do
#   Rake::Task["wenus22"].execute
# end

task :after_deploy, :roles => [:web, :app] do
  #run "cd #{release_path} && whenever --update-crontab #{application}"

  # if urpl #or egipt
  #   run "rm #{deploy_to}/current/config/environments/production.rb"        
  #   run "rm #{deploy_to}/current/config/environments/development.rb"        
  #   run "rm #{deploy_to}/current/config/environments/test.rb"        
  #   run "rm #{deploy_to}/current/config/database.yml" 
  #   run "rm #{deploy_to}/current/config/s3.siteor.yml" 
  #   run "rm #{deploy_to}/current/config/newrelic.yml" 
  #   run "rm #{deploy_to}/current/config/*.conf" 
  #   run "rm -R #{deploy_to}/current/app/views/system/*"
  #   
  # 
  #   run "mv #{deploy_to}/current/config/environments/production.javatech #{deploy_to}/current/config/environments/production.rb"
  #   run "mv #{deploy_to}/current/config/database.javatech #{deploy_to}/current/config/database.yml"
  # end
    
  run "rm #{deploy_to}/current/config/deploy.rb"
  run "rm #{deploy_to}/current/README.rdoc"


  # run "cd #{deploy_to}/current; RAILS_ENV=production script/delayed_job stop"   
  # run "cd #{deploy_to}/current; RAILS_ENV=production script/delayed_job start"

  # puts "błąd all.css - czekamy 3 min i usuniemy all css"
  #  sleep(60*3)
  #  run "rm  #{deploy_to}/current/public/javascripts/all*.js"
  #  run "rm  #{deploy_to}/current/public/stylesheets/all*.css"
 

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
