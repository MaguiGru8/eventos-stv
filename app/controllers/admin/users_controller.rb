class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin_permissions
  before_action :set_user, only: [:edit, :update, :destroy]

  def index
    @users = User.all
  end

  def new
    @user = User.new
    @user_roles = UserRole.all
    @kommunities = Kommunity.all
  end

  def create
    @user = User.find_or_create(
      params[:user][:email],
      params[:user][:name],
      nil,
      params[:user][:password]
    )

    if @user.persisted?
      # Assign roles
      if params[:user][:role_ids].present?
        params[:user][:role_ids].each do |role_id|
          kommunity_id = params[:user][:kommunity_id] if params[:user][:kommunity_id].present?
          UserRolesUser.create(user_id: @user.id, user_role_id: role_id, kommunity_id: kommunity_id)
        end
      end

      redirect_to admin_users_path, notice: 'User was successfully created.'
    else
      @user_roles = UserRole.all
      @kommunities = Kommunity.all
      render :new
    end
  end

  def edit
    @user_roles = UserRole.all
    @kommunities = Kommunity.all
    @current_roles = @user.user_roles_users
  end

  def update
    if params[:user][:password].blank?
      params[:user].delete(:password)
    end

    if @user.update(user_params)
      # Update roles if provided
      if params[:user][:role_ids].present?
        # Remove existing roles
        @user.user_roles_users.destroy_all
        
        # Add new roles
        params[:user][:role_ids].each do |role_id|
          kommunity_id = params[:user][:kommunity_id] if params[:user][:kommunity_id].present?
          UserRolesUser.create(user_id: @user.id, user_role_id: role_id, kommunity_id: kommunity_id)
        end
      end

      redirect_to admin_users_path, notice: 'User was successfully updated.'
    else
      @user_roles = UserRole.all
      @kommunities = Kommunity.all
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: 'User was successfully deleted.'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end

  def check_admin_permissions
    unless current_user.role?(:system_administrator, nil)
      redirect_to root_path, alert: 'You do not have permission to access this page.'
    end
  end
end