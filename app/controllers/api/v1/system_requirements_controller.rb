module Api::V1
  class SystemRequirementsController < ApiController
    before_action :set_system_requirement, only: %i[show update destroy]
    skip_before_action :authorized

    def index
      @loading_service = ModelLoadingService.new(SystemRequirement.all, searchable_params)
      @loading_service.call
    end

    def create
      @system_requirement = SystemRequirement.new(system_requirement_params)
      save_system_requirement!
    end

    def show; end

    def update
      @system_requirement.attributes = system_requirement_params
      save_system_requirement!
    end

    def destroy
      @system_requirement.destroy!
    rescue StandardError
      render_error(fields: @system_requirement.errors.messages)
    end

    private

    def set_system_requirement
      @system_requirement = SystemRequirement.find(params[:id])
    end

    def system_requirement_params
      return {} unless params.key?(:system_requirement)

      params.require(:system_requirement).permit(:name, :operational_system, :storage,
                                                 :processor, :memory, :video_board)
    end

    def save_system_requirement!
      @system_requirement.save!
      render :show
    rescue StandardError
      render_error(fields: @system_requirement.errors.messages)
    end

    def searchable_params
      params.permit({ search: {} }, { order: {} }, :page, :length)
    end
  end
end
