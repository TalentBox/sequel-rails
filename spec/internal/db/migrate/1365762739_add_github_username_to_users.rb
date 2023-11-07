Sequel.migration do
  change do
    alter_table :users do
      add_column :github_username, String, :text => true
    end
  end
end
