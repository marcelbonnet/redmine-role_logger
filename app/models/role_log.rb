class RoleLog < ActiveRecord::Base
	# https://guides.rubyonrails.org/active_record_migrations.html#foreign-keys
	has_many :role_detail
	belongs_to :user, :class_name => "Principal"
	belongs_to :project, :class_name => "Project"
  	belongs_to :member
end
