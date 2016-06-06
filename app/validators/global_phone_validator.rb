class GlobalPhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank? || value.to_s.match /^([67][0-9]{8}|[89][0-9]{8}|00[0-9]+)$/
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.global_phone'))
    end
  end
end
