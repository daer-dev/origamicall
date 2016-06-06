class NationalPhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank? || value.to_s.match /^([67][0-9]{8}|[89][1-9][0-9]{7}|900[0-9]{6})$/
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.national_phone'))
    end
  end
end
