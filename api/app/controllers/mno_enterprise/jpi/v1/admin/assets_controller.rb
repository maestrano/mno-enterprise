module MnoEnterprise
  class Jpi::V1::Admin::AssetsController < Jpi::V1::Admin::BaseResourceController

    DEPENDENCIES = [:product]
    DEFAULT_FIELD_NAME = 'screenshots'

    # GET /mnoe/jpi/v1/admin/assets
    # GET /mnoe/jpi/v1/admin/products/:product_id/assets
    def index
      product_id = params.delete(:product_id)
      query = MnoEnterprise::Asset.apply_query_params(params).includes(DEPENDENCIES)
      query = query.where('product.id' => product_id) if product_id

      assets = query.to_a
      response.headers['X-Total-Count'] = query.meta.record_count

      # Render assets
      render json: assets.map { |e| { id: e.id, url: e.url, field_name: e.field_name } }
    end

    # GET /mnoe/jpi/v1/admin/assets/1
    def show
      asset = MnoEnterprise::Asset.find_one(params[:id], DEPENDENCIES)
      return render_not_found('asset') unless asset

      render json: { id: asset.id, url: asset.url, field_name: asset.field_name }
    end

    # POST /mnoe/jpi/v1/admin/assets
    # POST /mnoe/jpi/v1/admin/products/:product_id/assets
    def create
      product_id = params[:product_id] || params.dig(:asset,:product_id)

      # Retrieve the file temp path
      content = params.dig(:asset,:content)
      image_temp_path = content.tempfile.path

      # Read the file and encode content using base64
      content_encoded = Base64.encode64(IO.binread(image_temp_path))

      # Initialize asset
      asset = MnoEnterprise::Asset.new({
        field_name: params.dig(:asset,:field_name) || DEFAULT_FIELD_NAME,
        data_base64: content_encoded,
        data_file_name: content.original_filename,
        data_content_type: content.content_type
      })

      # Add product relationship data
      asset.relationships.attributes = { product: { data: { type: 'products', id: product_id } } }

      if asset.save
        head :created
      else
        render json: asset.errors, status: :bad_request
      end
    end

    # DELETE /mnoe/jpi/v1/admin/products/1
    def destroy
      asset = MnoEnterprise::Asset.find_one(params[:id])
      return render_not_found('asset') unless asset

      asset.destroy
      head :no_content
    end
  end
end
