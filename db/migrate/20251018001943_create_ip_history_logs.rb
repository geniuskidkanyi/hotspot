class CreateIpHistoryLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :ip_history_logs do |t|
      t.references :router, null: false, foreign_key: true
      t.string :ip_address, null: false
      t.datetime :detected_at, null: false
      t.timestamps
    end
  end
end
