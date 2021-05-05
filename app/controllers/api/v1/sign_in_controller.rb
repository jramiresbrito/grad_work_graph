module Api::V1
  class SignInController < ApiController
    skip_before_action :authorized, only: :create

    def create
      email = sign_in_params[:email]
      password = sign_in_params[:password]

      @user = User.find_by(email: email)
      if @user&.authenticate(password)

        token = encode_token(@user)
        render json: { token: token }, status: :ok
      else
        render_user_error(:credentials, 'are invalid', :unauthorized)
      end
    rescue StandardError
      raise InvalidCredentialsError
    end

    private

    def sign_in_params
      params.require(:sign_in).permit(:email, :password)
    end

    def set_user_error(field, message)
      @user.errors.add(field, message)
    end

    def render_user_error(field, message, status)
      set_user_error(field, message)

      render_error(fields: @user.errors.messages, status: status)
    end
  end
end
