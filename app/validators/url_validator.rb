class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank? || value.to_s.match /^(http|https):\/\/[a-zA-Z0-9]+/
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.url'))
    end
  end
end
