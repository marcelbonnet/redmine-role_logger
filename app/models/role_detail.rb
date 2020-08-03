class RoleDetail < ActiveRecord::Base
	# https://guides.rubyonrails.org/active_record_migrations.html#foreign-keys
	belongs_to :role_log
	belongs_to :role, :class_name => "Role"
  	# belongs_to :group
end
