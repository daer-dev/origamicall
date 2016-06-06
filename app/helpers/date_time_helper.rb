module DateTimeHelper
  def format_timestamp(timestamp, mask = I18n.t('datetime.formats.default'), time_zone = nil)
    unless timestamp.blank? || mask.blank?
      if time_zone == false
        timestamp = timestamp.getgm
      else
        time_zone = Time.zone if time_zone.blank?
        begin
          timestamp = timestamp.in_time_zone(time_zone) unless time_zone.blank?
        rescue
        end
      end
      timestamp.strftime(mask)
    end
  end
end
