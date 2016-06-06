class GlobalNoSpecialPhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank? || value.to_s.match /^([67][0-9]{8}|[89][1-9][0-9]{7}|00[0-9]+)$/
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.global_no_special_phone'))
    end
  end
end
