# app/controllers/routers_controller.rb
class RoutersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_router, only: [:show, :edit, :update, :destroy, :check_status]

  def index
    @routers = current_user.routers.includes(:ip_history_logs)
    @online_count = @routers.online.count
    @offline_count = @routers.offline.count
  end

  def show
    @router_service = RouterService.new(@router)
    @current_ip = @router_service.resolve_current_ip
    @recent_ip_changes = @router.ip_history_logs.order(detected_at: :desc).limit(10)
    @hotspot_users = @router.hotspot_users.order(created_at: :desc).limit(20)
  end

  def new
    @router = current_user.routers.build
  end

  def create
    @router = current_user.routers.build(router_params)
    
    if @router.save
      # Test connection
      RouterService.new(@router).check_router_status
      redirect_to @router, notice: 'Router was successfully added.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @router.update(router_params)
      redirect_to @router, notice: 'Router was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @router.destroy
    redirect_to routers_url, notice: 'Router was successfully removed.'
  end

  def check_status
    status = RouterService.new(@router).check_router_status
    
    respond_to do |format|
      format.json { 
        render json: { 
          status: status ? 'online' : 'offline',
          current_ip: @router.current_ip,
          last_seen: @router.last_seen_at
        }
      }
    end
  end

  private

  def set_router
    @router = current_user.routers.find(params[:id])
  end

  def router_params
    params.require(:router).permit(:name, :location, :ddns_hostname, :api_username, :api_password, :api_port)
  end
end