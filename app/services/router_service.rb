# app/services/router_service.rb
require 'resolv'
require 'net/http'
require 'timeout'

class RouterService
  def initialize(router)
    @router = router
  end

  def resolve_current_ip
    return @router.current_ip if @router.ddns_hostname.blank?
    
    begin
      Timeout::timeout(5) do
        ip = Resolv.getaddress(@router.ddns_hostname)
        update_ip_if_changed(ip)
        ip
      end
    rescue Resolv::ResolvError, Timeout::Error => e
      Rails.logger.error "Failed to resolve #{@router.ddns_hostname}: #{e.message}"
      @router.current_ip # Return last known IP
    end
  end

  def check_router_status
    current_ip = resolve_current_ip
    return false unless current_ip

    begin
      # Try to connect to MikroTik API
      api = MikrotikApi.new(current_ip, @router.api_username, @router.api_password, @router.api_port)
      
      if api.connect
        @router.update!(
          current_ip: current_ip,
          last_seen_at: Time.current,
          active: true
        )
        
        # Get router identity and version
        identity = api.execute('/system/identity/print').first
        version = api.execute('/system/resource/print').first
        
        @router.update!(
          router_identity: identity&.dig('name'),
          ros_version: version&.dig('version')
        )
        
        api.disconnect
        true
      else
        @router.update!(active: false)
        false
      end
    rescue => e
      Rails.logger.error "Router #{@router.name} connection failed: #{e.message}"
      @router.update!(active: false)
      false
    end
  end

  def create_hotspot_user(username, password, profile, time_limit = nil)
    current_ip = resolve_current_ip
    return false unless current_ip && @router.active?

    begin
      api = MikrotikApi.new(current_ip, @router.api_username, @router.api_password, @router.api_port)
      
      if api.connect
        params = {
          'name' => username,
          'password' => password,
          'profile' => profile
        }
        params['limit-uptime'] = time_limit if time_limit
        
        result = api.execute('/ip/hotspot/user/add', params)
        api.disconnect
        
        # Store in local database
        @router.hotspot_users.create!(
          username: username,
          password: password,
          profile: profile,
          limit_uptime: time_limit,
          created_via_api: true
        )
        
        result
      end
    rescue => e
      Rails.logger.error "Failed to create hotspot user: #{e.message}"
      false
    end
  end

  private

  def update_ip_if_changed(new_ip)
    if @router.current_ip != new_ip
      @router.ip_history_logs.create!(
        ip_address: new_ip,
        detected_at: Time.current
      )
      @router.update!(current_ip: new_ip)
    end
  end
end