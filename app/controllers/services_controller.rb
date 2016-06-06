class ServicesController < ApplicationController
  include ServicesHelper
  layout false

  def api_new
    save_external_service params, true
  end

  def api_delete
    if params.include? :id
      service = Service.where(id: params[:id]).first

      if service.blank?
        render text: 404
      else
        if service.destroy
          render text: 200
        else
          render text: 500
        end
      end
    else
      render text: 400
    end
  end
end