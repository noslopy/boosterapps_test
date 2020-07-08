Sequel.migration do
  change do
    create_table(:browser_results) do
      primary_key :id
      column :data, :jsonb
    end
  end
end