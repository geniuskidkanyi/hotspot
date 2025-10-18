class RouterMonitorJob < ApplicationJob
  queue_as :default

  def perform(*args)
   Router.active.find_each do |router|
      RouterService.new(router).check_router_status
    end
  end
end
