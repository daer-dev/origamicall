class ErrorsController < ActionController::Base
  include ApplicationHelper

  def render_message
    @exception = env['action_dispatch.exception'].to_s
    @response  = ActionDispatch::ExceptionWrapper.rescue_responses[@exception.class.name]
    status     = ActionDispatch::ExceptionWrapper.new(env, @exception).status_code

    Rails.logger.error "#{@response} (#{status}) | #{@exception}"

    render_error status, (Rails.env == 'production')
  end
end
