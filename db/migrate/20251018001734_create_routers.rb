class CreateRouters < ActiveRecord::Migration[8.0]
  def change
    create_table :routers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :location
      t.string :ddns_hostname, null: false
      t.string :current_ip
      t.string :api_username, null: false
      t.string :api_password, null: false
      t.integer :api_port, default: 8728
      t.boolean :ddns_enabled, default: true
      t.datetime :last_seen_at
      t.string :router_identity
      t.string :ros_version
      t.boolean :active, default: true
      t.timestamps
    end
    add_index :routers, :ddns_hostname, unique: true
    add_index :routers, [:user_id, :active]
  end
end
