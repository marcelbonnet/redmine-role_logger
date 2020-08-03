module RoleLogsHelper

	def role_list_assigned_roles(logId)
		str=""
		RoleDetail.where(["role_log_id = ?", logId]).each{ |d|
			str << ", " unless str.empty?
			str << d.role_name if d.role_id != nil
			str << d.group_name if d.group_id !=  nil
		}
		str = l(:role_nao_modificado) if str.empty?
		str
	end

	def role_list_assigned_roles_ids(logId)
		str=""
		RoleDetail.where(["role_log_id = ?", logId]).each{ |d|
			str << ", " unless str.empty?
			str << d.role_id.to_s if d.role_id !=  nil
			str << d.group_id.to_s if d.group_id !=  nil
		}
		str
	end

	def role_is_admin(b)
		str = l(:role_nao)
		str = l(:role_sim) if b
		str
	end
	
end