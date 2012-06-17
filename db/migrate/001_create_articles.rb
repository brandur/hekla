Sequel.migration do
  up do
    create_table(:articles) do
      primary_key :id
      String   :title,        null: false
      String   :slug,         null: false
      String   :summary
      String   :content,      null: false
      DateTime :published_at, null: false
    end

    run "CREATE EXTENSION IF NOT EXISTS hstore"
    run "ALTER TABLE articles ADD COLUMN metadata hstore"
  end

  down do
    drop_table(:articles)
    run "DROP EXTENSION hstore"
  end
end
