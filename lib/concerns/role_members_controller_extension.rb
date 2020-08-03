module RoleMembersControllerExtension
  extend ActiveSupport::Concern

  	included do
  		after_action	:after_persist	, :only => [ :update ]


  		def after_persist

			# se receber uma lista com as checkboxes marcadas:
			p=params[:membership]['role_ids']
			u=User.current

			# MemberController possui @member
			if @member == nil #PrincipalMembershipsController#find_membership possui @membership
				@member = @membership
			end
			
			tipo=@member.principal.type 
			
			memberLoginGroupName=@member.principal.login if tipo == "User"
			memberLoginGroupName=@member.principal.lastname if tipo == "Group"
			
			if p.length > 1
				role_ids=p.take(p.length-1)
				role_names=[]
				roles=Role.find(role_ids).each{|r| role_names.push(r.name) }
				
				isAdmin = false;
				if @member.principal.attributes.key?("admin")
					isAdmin = @member.principal.admin
				end

				log = RoleLog.create(user_id: u.id, project_id: @member.project.id, member_id: @member.id, principal_type: @member.principal.type, principal_id: @member.principal.id ,principal_name: memberLoginGroupName, admin: isAdmin )
				for i in 0..role_ids.length-1
					RoleDetail.create(role_log_id: log.id, role_id: role_ids[i], role_name: role_names[i])
				end
			end

			if tipo == "User"
				log = RoleLog.create(user_id: u.id, project_id: @member.project.id, member_id: @member.id, principal_type: @member.principal.type, principal_id: @member.principal.id ,principal_name: memberLoginGroupName, admin: @member.principal.admin )
				@member.principal.groups.each{|g|
					RoleDetail.create(role_log_id: log.id, role_id: g.id, role_name: g)
				}
			end


  		end #def


  	end	#included


end