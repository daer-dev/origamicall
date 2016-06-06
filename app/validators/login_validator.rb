class LoginValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank? || value.to_s.match /^[a-z0-9_-]{1,16}$/
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.login'))
    end
  end
end
