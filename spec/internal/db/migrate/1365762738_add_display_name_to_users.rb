Sequel.migration do
  change do
    alter_table :users do
      add_column :display_name, String, :text => true
    end
  end
end
