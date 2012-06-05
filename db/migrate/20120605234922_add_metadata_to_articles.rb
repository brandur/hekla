class AddMetadataToArticles < ActiveRecord::Migration
  def up
    execute "CREATE EXTENSION hstore"
    add_column :articles, :metadata, :hstore
  end

  def down
    remove_column :articles, :metadata
    execute "DROP EXTENSION hstore"
  end
end
