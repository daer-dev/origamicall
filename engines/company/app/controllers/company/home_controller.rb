module Company
  class HomeController < CompanyController
    def index
      @num_quotes = 5

      if params.include? :contact
        if params[:contact].strip.blank?
          flash.now[:message] = I18n.t('company.contact.form.messages.validation')
        else
          if Company::ContactMailer.email(params[:contact]).deliver_now
            flash.now[:message] = I18n.t('company.contact.form.messages.success')
          else
            flash.now[:message] = I18n.t('company.contact.form.messages.server')
          end
        end
      end
    end
  end
end