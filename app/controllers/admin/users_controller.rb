class Admin::UsersController < Admin::ApplicationController
	before_action :set_user, only: [:show, :edit, :update, :destroy, :archive]
	before_action :set_projects, only: [:new, :create, :edit, :update]

	def index
		@users = User.excluding_archived.order(:email)
	end

	def new
		@user = User.new
	end

	def create
		@user = User.create(user_params)

		# ** managing roles
		build_roles_for(@user)

		if @user.save
			flash[:notice] = "User has been created."
			redirect_to admin_users_path
		else
			flash.now[:alert] = "User has not been created."
			render "new"
		end

	end

	def show 

	end

	def edit

	end

	def update

		# ** to prevent devise from taking action for an empty field
		# ** as passwords are always encrypted.
		if params[:user][:password].blank?
			params[:user].delete(:password)
		end

		# ** Roles managing
		User.transaction do
			@user.roles.clear
			build_roles_for(@user)
		end


		# ** The main Update action goes here.
		if @user.update(user_params)
			flash[:notice] = "User has been updated."
			redirect_to admin_users_path
		else
			flash.now[:alert] = "User has not been updated."
			render "edit"
			raise ActiveRecord::Rollback
		end
	end

	def archive
		if @user == current_user
			flash[:alert] = "You cannot archive yourself!"
		else
			@user.archive
			flash[:notice] = "User has been archived."
		end
		
		redirect_to admin_users_path
	end

private
	
	def user_params
		params.require(:user).permit(:email, :password, :admin)
	end

	def set_user
		@user = User.find(params[:id])
	end
	
	# ** created set_projects after setting a select box in the view
	def set_projects
		@projects = Project.order(:name)
	end

	def build_roles_for(user)
		role_data = params.fetch(:roles, [])
		role_data.each do |project_id, role_name|
			if role_name.present?
				user.roles.build(project_id: project_id, role: role_name)
			end
		end
	end

end
