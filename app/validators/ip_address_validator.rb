class IpAddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank? || value.to_s.match /^[0-9]{1,3}(\.[0-9]{1,3}){3}(\/[0-9]{1,2}([0-9](\.[0-9]{1,3}){3})?)?$/
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.ip_address'))
    end
  end
end
