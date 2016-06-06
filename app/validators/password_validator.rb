class PasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank? || value.to_s.match /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?!.*\s).{6,32}$/
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.password'))
    end
  end
end
