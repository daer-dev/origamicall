class TimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank? || value.to_s.match /^((2[0-3])|([0-1][0-9])):[0-5][0-9]$/
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.time'))
    end
  end
end
