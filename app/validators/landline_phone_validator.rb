class LandlinePhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank? || value.to_s.match /^([89][1-9][0-9]{7})$/
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.landline_phone'))
    end
  end
end
