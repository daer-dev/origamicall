class InternationalPhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank? || value.to_s.match /^00(([1-24-9][0-9])|(3[0-35-9]))[0-9]+$/
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.international_phone'))
    end
  end
end
