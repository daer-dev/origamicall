class MobilePhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank? || value.to_s.match /^([67][0-9]{8})$/
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.mobile_phone'))
    end
  end
end
