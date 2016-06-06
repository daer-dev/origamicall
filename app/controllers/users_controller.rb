class UsersController < ApplicationController
  layout false

  def api_new
    save_external_user params
  end

  def api_login
    if params.include? :id
      if login_user params[:id]
        render text: 200
      else
        render text: 500
      end
    else
      render text: 400
    end
  end

  def api_delete
    if params.include? :id
      user = User.where(id: params[:id]).first

      if user.blank?
        render text: 404
      else
        if user.destroy
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