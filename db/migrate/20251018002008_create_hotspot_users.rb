class CreateHotspotUsers < ActiveRecord::Migration[8.0]
  def change
      create_table :hotspot_users do |t|
        t.references :router, null: false, foreign_key: true
        t.string :username, null: false
        t.string :password, null: false
        t.string :profile, default: 'default'
        t.string :limit_uptime # e.g., '1h', '24h', '7d'
        t.string :limit_bytes_in
        t.string :limit_bytes_out
        t.string :limit_bytes_total
        t.boolean :disabled, default: false
        t.boolean :created_via_api, default: false
        t.datetime :expires_at
        t.datetime :first_login_at
        t.datetime :last_login_at
        t.integer :total_bytes_in, limit: 8, default: 0
        t.integer :total_bytes_out, limit: 8, default: 0
        t.string :mac_address
        t.string :comment
        t.decimal :price_paid, precision: 8, scale: 2
        t.string :payment_reference
        t.string :created_by # 'system', 'admin', 'payment'
        
        t.timestamps
      end
      
      # Indexes for performance
      add_index :hotspot_users, [:router_id, :username], unique: true
      add_index :hotspot_users, :username
      add_index :hotspot_users, :expires_at
      add_index :hotspot_users, :created_at
      add_index :hotspot_users, [:router_id, :disabled]
      add_index :hotspot_users, :payment_reference
  end
end
