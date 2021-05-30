module Api::V1
  class UsersController < ApiController
    skip_before_action :authorized, only: %i[create show]
    before_action :set_user, only: %i[show update destroy]

    def index
      # scope_without_current_user = User.where.not(id: @current_user.id)
      @loading_service = ModelLoadingService.new(User.all, searchable_params)
      @loading_service.call
    end

    def create
      user = User.create(user_params)

      if user.valid?
        token = encode_token(user)
        UserMailer.welcome(user).deliver_now
        render json: { token: token }, status: :created
      else
        render_error(fields: user.errors.messages)
      end
    end

    def update
      @user.attributes = user_params
      save_user!
    end

    def show; end

    def destroy
      @user.destroy!
    rescue StandardError
      render_error(fields: @user.errors.messages)
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      return {} unless params.key?(:user)

      params.permit(:name, :email, :password, :password_confirmation)
    end

    def save_user!
      @user.save!
      render :show
    rescue StandardError
      render_error(fields: @user.errors.messages)
    end

    def searchable_params
      params.permit({ search: {} }, { order: {} }, :page, :length)
    end
  end
end
