# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json

    # Custom create action to handle the user creation and return appropriate response
    def create
      build_resource(sign_up_params)
      
      resource.save
      yield resource if block_given?
      
      if resource.persisted?
        if resource.active_for_authentication?
          # User was not required to confirm email
          sign_up(resource_name, resource)
          respond_with resource
        else
          # User needs to confirm email
          expire_data_after_sign_in!
          render json: {
            status: { 
              code: 200, 
              message: 'Registration successful! Please check your email to confirm your account.' 
            },
            data: UserSerializer.new(resource).serializable_hash[:data][:attributes].merge(
              confirmation_required: true
            )
          }
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    end
    
    # Endpoint to confirm user's email
    def confirm_email
      token = params[:confirmation_token]
      user = User.find_by(confirmation_token: token)
      
      if user.present? && !user.confirmed?
        user.confirm
        render json: {
          status: { code: 200, message: 'Email confirmed successfully! You can now log in.' }
        }
      elsif user.present? && user.confirmed?
        render json: {
          status: { code: 200, message: 'Email already confirmed. You can log in.' }
        }
      else
        render json: {
          status: { message: 'Invalid confirmation token.' }
        }, status: :unprocessable_entity
      end
    end

    private

    def respond_with(current_user, _opts = {})
      if resource.persisted?
        render json: {
          status: { code: 200, message: 'Signed up successfully.' },
          data: UserSerializer.new(current_user).serializable_hash[:data][:attributes]
        }
      else
        render json: {
          status: { message: "User couldn't be created successfully. #{current_user.errors.full_messages.to_sentence}" }
        }, status: :unprocessable_entity
      end
    end
    # before_action :configure_sign_up_params, only: [:create]
    # before_action :configure_account_update_params, only: [:update]

    # GET /resource/sign_up
    # def new
    #   super
    # end

    # POST /resource
    # def create
    #   super
    # end

    # GET /resource/edit
    # def edit
    #   super
    # end

    # PUT /resource
    # def update
    #   super
    # end

    # DELETE /resource
    # def destroy
    #   super
    # end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    # def cancel
    #   super
    # end

    # protected

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_sign_up_params
    #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
    # end

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_account_update_params
    #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
    # end

    # The path used after sign up.
    # def after_sign_up_path_for(resource)
    #   super(resource)
    # end

    # The path used after sign up for inactive accounts.
    # def after_inactive_sign_up_path_for(resource)
    #   super(resource)
    # end
  end
end
