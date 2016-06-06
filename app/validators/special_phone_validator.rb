class SpecialPhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank? || value.to_s.match /^[89]0[1-9]{7}$/
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.special_phone'))
    end
  end
end
