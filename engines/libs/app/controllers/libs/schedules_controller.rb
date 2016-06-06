module Libs
  class SchedulesController < LibsController
    before_action :add_find, :except => %w(index new create)
    before_action :add_extra_info, :except => %w(delete destroy)

    def index
      @schedules = Libs::Schedule.where(@global_conditions).order('id DESC').to_a
    end

    def show
    end

    def new
      @schedule = Libs::Schedule.new
      reset_cookies :schedules
    end

    def edit
      reset_cookies :schedules
    end

    def create
      @schedule = Libs::Schedule.new allowed_params
      reset_cookies :schedules

      if add_data && @schedule.save
        flash.now[:notice] = I18n.t('messages.success.create')
        redirect_lib
      else
        render :action => :new
      end
    end

    def update
      reset_cookies :schedules

      if @schedule.update_attributes allowed_params
        flash.now[:notice] = I18n.t('messages.success.update')
        redirect_lib
      else
        render :action => :edit
      end
    end

    def delete
    end

    def destroy
      if @schedule.destroy
        flash.now[:notice] = I18n.t('messages.success.destroy')
      else
        flash.now[:error] = I18n.t('messages.error.server')
      end

      js_redirect_to schedules_path
    end

    private

      def add_find
        @schedule = Libs::Schedule.where(id: params[:id]).first
        js_redirect_to schedule_path(params[:id]) if @schedule.users_id.blank? && params[:action] != 'show' && not WEBO_CONFIG['users']['administrators'].include? session[:user]['data']['id']
        render_error 403 if session[:user]['data']['id'] != @schedule.users_id || (external_engine && @schedule.product != external_engine)
      end

      def add_extra_info
        @products = @products.delete_if{ |x| not LIBS_CONFIG['products_libs'][x[:value]].include? 'schedules' } unless external_engine
      end

      def add_data
        @schedule.product = external_engine if external_engine
        @schedule.users_id = session[:user]['data']['id']
      end

      def redirect_lib
        redirect :schedules, @schedule.id, @schedule.name, schedules_path
      end

      def allowed_params
        permit_fields = [
          :name,
          :d1_1_1,
          :d1_1_2,
          :d1_2_1,
          :d1_2_2,
          :d1_3_1,
          :d1_3_2,
          :d2_1_1,
          :d2_1_2,
          :d2_2_1,
          :d2_2_2,
          :d2_3_1,
          :d2_3_2,
          :d3_1_1,
          :d3_1_2,
          :d3_2_1,
          :d3_2_2,
          :d3_3_1,
          :d3_3_2,
          :d4_1_1,
          :d4_1_2,
          :d4_2_1,
          :d4_2_2,
          :d4_3_1,
          :d4_3_2,
          :d5_1_1,
          :d5_1_2,
          :d5_2_1,
          :d5_2_2,
          :d5_3_1,
          :d5_3_2,
          :d6_1_1,
          :d6_1_2,
          :d6_2_1,
          :d6_2_2,
          :d6_3_1,
          :d6_3_2,
          :d7_1_1,
          :d7_1_2,
          :d7_2_1,
          :d7_2_2,
          :d7_3_1,
          :d7_3_2,
          :holidays_list
        ]
        permit_fields.push :product unless external_engine
        params.require(:schedule).permit permit_fields
      end
  end
end
