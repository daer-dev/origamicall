module Company
  class ContactMailer < ActionMailer::Base
    def email(text)
      @text = text

      mail({
        template_path: 'company/contact',
        from: 'contacto@origamicall.com',
        to: 'info@origamicall.com',
        subject: I18n.t('company.contact.title')
      })
    end
  end
end