module ApplicationHelper
  def asset_data_base64(path)
    asset = Rails.application.assets.find_asset(path)
    throw "Could not find asset '#{path}'" if asset.nil?
    base64 = Base64.encode64(asset.to_s).gsub(/\s+/, "")
    "data:#{asset.content_type};base64,#{Rack::Utils.escape(base64)}"
  end

  def title(page_title)
	  content_for :title, page_title.to_s
  end

  def tour_display?
    # if sign_in_count == 1
       if session[:tour_displayed].present?
          true
       else
          session[:tour_displayed] = true
          false
       end 
    # end  
  end
  
end