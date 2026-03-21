Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :name, null: false
      String :email, null: false
      String :password_digest, null: false

      index :email, unique: true
    end
  end
end
