class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :reset_password_token, default: nil
      t.date :reset_password_token_expires_at, default: nil

      t.timestamps
    end
  end
end
