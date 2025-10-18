class Router < ApplicationRecord
  belongs_to :user
  has_many :hotspot_users, dependent: :destroy
  has_many :ip_history_logs, dependent: :destroy
  
  validates :name, presence: true
  validates :ddns_hostname, presence: true, uniqueness: true
  validates :api_username, presence: true
  validates :api_password, presence: true
  
  encrypts :api_password
  
  scope :online, -> { where('last_seen_at > ?', 5.minutes.ago) }
  scope :offline, -> { where('last_seen_at <= ? OR last_seen_at IS NULL', 5.minutes.ago) }
end
