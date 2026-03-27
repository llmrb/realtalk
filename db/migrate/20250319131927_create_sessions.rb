Sequel.migration do
  change do
    create_table(:sessions) do
      primary_key :id
      foreign_key :user_id, :users, null: false, on_delete: :cascade
      String :model, null: false
      String :provider, null: false
      Integer :input_tokens, default: 0
      Integer :output_tokens, default: 0
      Integer :total_tokens, default: 0
      column :session_data, :jsonb, null: false, default: Sequel.pg_jsonb({})

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index :user_id
      index :created_at
    end
  end
end