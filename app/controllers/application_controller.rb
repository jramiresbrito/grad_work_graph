class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include Pundit
  include SimpleErrorRenderable
  self.simple_error_partial = "shared/simple_error"

  rescue_from Pundit::NotAuthorizedError, with: :not_authorized
  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  rescue_from ResetPasswordError, with: :not_authorized
  rescue_from InvalidCredentialsError, with: :user_not_found
  LEEWAY = 300 # 5 minutes
  EXPIRATION_TIME = 7.days

  before_action :authorized
  API_SECRET = Rails.application.secrets.secret_key_base

  def encode_token(payload)
    JWT.encode(token_payload(payload), API_SECRET)
  end

  def auth_header
    request.headers['Authorization']
  end

  def token_present?
    auth_header.present?
  end

  def decoded_token
    if auth_header
      token = auth_header.split(' ')[1]
      begin
        options = { exp_leeway: LEEWAY,
                    iss: ENV['JWT_ISS'],
                    verify_iss: true,
                    algorithm: 'HS256' }
        JWT.decode token, API_SECRET, true, options
      rescue JWT::DecodeError
        nil
      rescue JWT::InvalidIssuerError
        nil
      rescue JWT::ExpiredSignature
        nil
      end
    end
  end

  def logged_in_user
    if decoded_token
      user_id = decoded_token.first['user_id']
      @current_user = User.find(user_id)
    end
  end

  def logged_in?
    !!logged_in_user
  end

  def authorized
    return render json: { 'errors': [{ token: 'not found' }] }, status: :unauthorized unless token_present?

    not_authorized unless logged_in?
  end

  def set_user
    logged_in_user
  end

  def pundit_user
    set_user
  end

  private

  def token_payload(user)
    iss = ENV['JWT_ISS']
    exp = (Time.now + EXPIRATION_TIME).to_i
    iat = Time.now.to_i
    { user_id: user.id.to_s, exp: exp, iat: iat, iss: iss }
  end

  def user_not_found
    render json: { 'errors': [{ crendentials: 'are invalid' }] }, status: :bad_request
  end

  def not_authorized
    render json: { 'errors': [{ token: 'is either invalid or expired' }] }, status: :unauthorized
  end

  # Adopt the white list approach, but for sake of "exercise", skip any
  def skip_pundit?
    routes = []
    Rails.application.routes.routes.each do |route|
      next unless route.defaults[:controller]&.include? "api/v1"

      routes << route.defaults[:controller]
    end

    routes.include? params[:controller]
  end
end
