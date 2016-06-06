class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank? || value.to_s.match /^[a-zA-Z\-_.0-9]+\@[a-zA-Z\-_.0-9]+\.[a-z]{2,4}$/
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.email'))
    end
  end
end
