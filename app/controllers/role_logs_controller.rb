class RoleLogsController < ApplicationController

	before_filter :find_project_by_project_id, :authorize
	
	def index
		@logs = RoleLog.where(["project_id = ? and user_id = ?", @project.id, User.current.id ])
	end

end
