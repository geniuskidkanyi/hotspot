class HotspotUser < ApplicationRecord
  belongs_to :router
  has_one :user, through: :router
  
  validates :username, presence: true, uniqueness: { scope: :router_id }
  validates :password, presence: true
  validates :profile, presence: true
  
  encrypts :password
  
  scope :active, -> { where(disabled: false) }
  scope :expired, -> { where('expires_at < ?', Time.current) }
  scope :not_expired, -> { where('expires_at > ? OR expires_at IS NULL', Time.current) }
  scope :recent, -> { order(created_at: :desc) }
  scope :paid, -> { where.not(payment_reference: nil) }
  
  before_create :set_expiry_time
  before_save :format_limits
  
  def active?
    !disabled && (expires_at.nil? || expires_at > Time.current)
  end
  
  def expired?
    expires_at.present? && expires_at <= Time.current
  end
  
  def time_remaining
    return nil unless expires_at
    return 0 if expired?
    
    expires_at - Time.current
  end
  
  def formatted_time_remaining
    return 'Unlimited' unless expires_at
    return 'Expired' if expired?
    
    remaining = time_remaining
    hours = (remaining / 3600).to_i
    minutes = ((remaining % 3600) / 60).to_i
    
    if hours > 24
      days = (hours / 24).to_i
      "#{days}d #{hours % 24}h #{minutes}m"
    elsif hours > 0
      "#{hours}h #{minutes}m"
    else
      "#{minutes}m"
    end
  end
  
  def total_data_usage
    total_bytes_in + total_bytes_out
  end
  
  def formatted_data_usage
    bytes = total_data_usage
    return '0 B' if bytes == 0
    
    units = %w[B KB MB GB TB]
    base = 1024
    exp = (Math.log(bytes) / Math.log(base)).to_i
    exp = [exp, units.length - 1].min
    
    "%.2f %s" % [bytes.to_f / base**exp, units[exp]]
  end
  
  private
  
  def set_expiry_time
    return unless limit_uptime.present?
    
    case limit_uptime.downcase
    when /(\d+)h/
      self.expires_at = Time.current + $1.to_i.hours
    when /(\d+)d/
      self.expires_at = Time.current + $1.to_i.days
    when /(\d+)w/
      self.expires_at = Time.current + $1.to_i.weeks
    when /(\d+)m$/
      self.expires_at = Time.current + $1.to_i.minutes
    end
  end
  
  def format_limits
    # Ensure limits are in correct MikroTik format
    self.limit_bytes_in = format_bytes_limit(limit_bytes_in) if limit_bytes_in.present?
    self.limit_bytes_out = format_bytes_limit(limit_bytes_out) if limit_bytes_out.present?
    self.limit_bytes_total = format_bytes_limit(limit_bytes_total) if limit_bytes_total.present?
  end
  
  def format_bytes_limit(limit)
    return limit if limit.match?(/^\d+[KMGT]?$/)
    limit
  end
end
