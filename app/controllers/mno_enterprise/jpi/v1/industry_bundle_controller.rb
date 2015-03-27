class Jpi::V1::IndustryBundleController < ApplicationController

  # GET /jpi/v1/industry_bundles/app_descriptions/pr.json
  def app_descriptions
    @bundle = IndustryBundle.find_by_name(params[:bundle_name])
    if @bundle
      app_descriptions_array = @bundle.apps.map do |app|
        [app.name, { 'pictures' => app.pictures.map { |picture| {'thumb' => picture.thumb.to_s, 'url' => picture.url.to_s } } }.merge(
        @bundle.app_descriptions[app.name]) ]
      end
      @app_descriptions = Hash[*(app_descriptions_array.flatten)]
      @bundle_description = { appNames: @bundle.apps.map { |app| app.name }, appDescriptions: @app_descriptions }
      respond_to do |format|
        format.json { render json: @bundle_description, status: :ok }
      end
    else
      respond_to do |format|
        format.json { render json: "That bundle does not exist", status: :bad_request }
      end
    end
  end

end

