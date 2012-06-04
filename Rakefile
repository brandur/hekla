require "active_record"
require "logger"
require "rake/testtask"

$: << "./lib"
require "hekla"

require_relative "models/article"

Rake::TestTask.new do |t|
  t.libs.push "lib", "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

task :environment do
  ActiveRecord::Base.logger = Logger.new($stdout)
  ActiveRecord::Base.establish_connection(Hekla::Config.database_url)
end

task :lorem => :environment do
  create_lorem_ipsum_article title: "Lorem ipsum dolor sit amet",                     slug: "lorem"
  create_lorem_ipsum_article title: "Consectetur adipisicing elit",                   slug: "consectetur"
  create_lorem_ipsum_article title: "Ea maxime temporibus itaque tempora",            slug: "ea"
  create_lorem_ipsum_article title: "Iure saepe modi mollitia nostrum",               slug: "iure"
  create_lorem_ipsum_article title: "Incididunt deleniti et molestiae exercitation ", slug: "incididunt"
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

def create_lorem_ipsum_article(attributes = {})
  content = Hekla::LoremIpsum.run
  attributes = 
    { summary: content[0..160],
      content: content,
      published_at: Time.now }.merge!(attributes)
  Article.create!(attributes)
end
