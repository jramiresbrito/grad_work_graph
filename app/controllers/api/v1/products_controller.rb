module Api::V1
  class ProductsController < ApiController
    before_action :set_product, only: %i[show update destroy]
    skip_before_action :authorized

    def index
      @loading_service = ModelLoadingService.new(Product.all, searchable_params)
      @loading_service.call
    end

    def create
      run_service
    rescue ProductSavingService::NotSavedProductError
      render_error(fields: @saving_service.errors)
    end

    def show; end

    def update
      run_service
    rescue ProductSavingService::NotSavedProductError
      render_error(fields: @saving_service.errors)
    end

    def destroy
      @product.productable.destroy!
      @product.destroy!
    rescue ActiveRecord::RecordNotDestroyed
      render_error(fields: @product.errors.messages.merge(@product.productable.errors.messages))
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def searchable_params
      params.permit({ search: {} }, { order: {} }, :page, :length)
    end

    def run_service
      @saving_service = ProductSavingService.new(product_params.to_h, @product)
      @saving_service.call
      @product = @saving_service.product
      render :show
    end

    def product_params
      return {} unless params.key?(:product)

      permitted_params = params.require(:product).permit(:id, :name, :description,
                                                         :image, :price, :productable,
                                                         :status, :featured, :image_url,
                                                         category_ids: [])
      permitted_params.merge(productable_params)
    end

    def productable_params
      productable_type = params[:product][:productable] || @product&.productable_type&.underscore
      return unless productable_type.present?

      productable_attributes = send("#{productable_type}_params")
      { productable_attributes: productable_attributes }
    end

    def game_params
      params.require(:product).permit(:mode, :release_date, :developer, :system_requirement_id)
    end
  end
end
