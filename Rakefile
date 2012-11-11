require "bundler/setup"
Bundler.require

require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs.push "lib", "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

task :environment do
  require_relative "./lib/hekla"
  DB = Sequel.connect(Hekla::Config.database_url)
end

task :lorem => :environment do
  create_lorem_ipsum_article title: "Lorem ipsum dolor sit amet",                     slug: "lorem"
  create_lorem_ipsum_article title: "Consectetur adipisicing elit",                   slug: "consectetur"
  create_lorem_ipsum_article title: "Ea maxime temporibus itaque tempora",            slug: "ea"
  create_lorem_ipsum_article title: "Iure saepe modi mollitia nostrum",               slug: "iure"
  create_lorem_ipsum_article title: "Incididunt deleniti et molestiae exercitation ", slug: "incididunt"
end

def create_lorem_ipsum_article(attributes = {})
  content = Hekla::LoremIpsum.run
  attributes = 
    { summary: content[0..160],
      content: content,
      published_at: Time.now }.merge!(attributes)
  Article.create(attributes)
end
