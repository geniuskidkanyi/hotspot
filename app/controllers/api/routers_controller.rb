# app/controllers/api/routers_controller.rb
class Api::RoutersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_api_request

  def heartbeat
    router = Router.find_by(ddns_hostname: params[:ddns_name])
    
    if router
      router.update!(
        current_ip: extract_ip(params[:current_ip]),
        last_seen_at: Time.current,
        router_identity: params[:identity],
        active: true
      )
      
      render json: { status: 'success' }
    else
      render json: { error: 'Router not found' }, status: 404
    end
  end

  private

  def authenticate_api_request
    # Implement your API authentication logic
    # Could use API keys, JWT tokens, etc.
  end

  def extract_ip(ip_with_subnet)
    ip_with_subnet.to_s.split('/').first
  end
end