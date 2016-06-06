class DateListValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank? || value.to_s.match /^((3[01])|([0-2][0-9]))\/((1[0-2])|(0[0-9]))\/[0-9]{4}(,((3[01])|([0-2][0-9]))\/((1[0-2])|(0[0-9]))\/[0-9]{4})*$/
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.date_list'))
    end
  end
end
