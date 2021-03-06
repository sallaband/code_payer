class Users::PasswordsController < Devise::PasswordsController
  layout "before_login"
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      if Devise.sign_in_after_reset_password
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message!(:notice, flash_message)
        sign_in(resource_name, resource)
      else
        set_flash_message!(:notice, :updated_not_active)  
      end
      respond_with resource, location: after_resetting_password_path_for(resource)
    else
      flash[:errors] = resource.errors.full_messages
      redirect_to edit_password_url(resource, reset_password_token: params[:user][:reset_password_token])
    end
  end

  # protected

  def after_resetting_password_path_for(resource)
    root_path
  end

  # The path used after sending reset password instructions
  def after_sending_reset_password_instructions_path_for(resource_name)
    flash[:alert] = "Mail has been successfully sent..."
    new_user_session_path
  end
end
