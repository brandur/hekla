require "active_record"
require "logger"
require "rake/testtask"

$: << "./lib"
require "hekla"

Rake::TestTask.new do |t|
  t.libs.push "lib", "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

task :environment do
  ActiveRecord::Base.logger = Logger.new($stdout)
  ActiveRecord::Base.establish_connection(Hekla::Config.database_url)
end

namespace :db do
  task :migrate => :environment do
    ActiveRecord::Migration.verbose = true
    if ENV["STEPS"]
      ActiveRecord::Migrator.forward("db/migrate", ENV["STEPS"].to_i)
    else
      ActiveRecord::Migrator.migrate("db/migrate", ENV["VERSION"])
    end
  end

  task :rollback => :environment do
    ActiveRecord::Migration.verbose = true
    if ENV["STEPS"]
      ActiveRecord::Migrator.rollback("db/migrate", ENV["STEPS"].to_i)
    else
      ActiveRecord::Migrator.down("db/migrate", ENV["VERSION"])
    end
  end
end
