# Add a before_filter to set the locale based on the params or the default locale
module MnoEnterprise::Concerns::Controllers::I18n
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
  end

  def set_locale
    I18n.locale =  if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym) &&MnoEnterprise.i18n_enabled
      params[:locale]
    else
      I18n.default_locale
    end
  end
end
