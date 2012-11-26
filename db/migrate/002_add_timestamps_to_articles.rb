Sequel.migration do
  up do
    add_column :articles, :created_at, DateTime
    add_column :articles, :updated_at, DateTime

    run "UPDATE articles SET created_at = published_at"
    run "UPDATE articles SET updated_at = published_at"

    run "ALTER TABLE articles ALTER COLUMN created_at SET NOT NULL"
    run "ALTER TABLE articles ALTER COLUMN updated_at SET NOT NULL"
  end

  down do
    drop_column :articles, :created_at
    drop_column :articles, :updated_at
  end
end
