module Ivr
  module TreeHelper
    def spacetree_preferences
      @spacetree_preferences = IVR_CONFIG['spacetree'].rclone
      @spacetree_preferences['log'].each{ |k,v| @spacetree_preferences['log'][k] = I18n.t(v) }
      %w(alignment orientation).each{ |a| @spacetree_preferences[a].map!{ |x| { 'name' => I18n.t(x['name']), 'id' => x['id'] } } }
      @spacetree_preferences[:view] = (params[:action] == 'show') ? 'full' : 'simple'
    end
  end
end