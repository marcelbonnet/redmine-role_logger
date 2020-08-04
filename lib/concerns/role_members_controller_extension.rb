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



			_project_id = Setting.find_by("name = ?", "plugin_role_logger").value["project_id"]
			_tracker_id = Setting.find_by("name = ?", "plugin_role_logger").value["tracker_id"]
			_issue_description = "Mudanças verificadas no evento:"
			
			if p.length > 1
				role_ids=p.take(p.length-1)
				role_names=[]
				roles=Role.find(role_ids).each{|r| role_names.push(r.name) }
				
				isAdmin = false;
				if @member.principal.attributes.key?("admin")
					isAdmin = @member.principal.admin
				end

				_issue_description << "\n\nMudanças monitoradas no _params_:"
				_issue_description << "\nproject_id: #{@member.project.id}"
				_issue_description << "\nmember_id: #{@member.id}"
				_issue_description << "\nprincipal_type: #{@member.principal.type}"
				_issue_description << "\nprincipal_id: #{@member.principal.id}"
				_issue_description << "\nprincipal_name: #{memberLoginGroupName}"
				_issue_description << "\nadmin: #{isAdmin}"

				# log = RoleLog.create(user_id: u.id, project_id: @member.project.id, member_id: @member.id, principal_type: @member.principal.type, principal_id: @member.principal.id ,principal_name: memberLoginGroupName, admin: isAdmin )
				for i in 0..role_ids.length-1
					# RoleDetail.create(role_log_id: log.id, role_id: role_ids[i], role_name: role_names[i])
					_issue_description << "\nrole_id: #{role_ids[i]}, role_name: #{role_names[i]}"
				end

				Issue.create(tracker_id: _tracker_id, project_id: _project_id, subject: "[Log] #{memberLoginGroupName}", description: _issue_description, priority_id: 2, author_id: u.id)
			end

			if tipo == "User"
				# log = RoleLog.create(user_id: u.id, project_id: @member.project.id, member_id: @member.id, principal_type: @member.principal.type, principal_id: @member.principal.id ,principal_name: memberLoginGroupName, admin: @member.principal.admin )

				_issue_description << "\n\nMudanças monitoradas na instância de _@member_:"
				_issue_description << "\nproject_id: #{@member.project.id}"
				_issue_description << "\nmember_id: #{@member.id}"
				_issue_description << "\nprincipal_type: #{@member.principal.type}"
				_issue_description << "\nprincipal_id: #{@member.principal.id}"
				_issue_description << "\nprincipal_name: #{memberLoginGroupName}"
				_issue_description << "\nadmin: #{@member.principal.admin}"


				@member.principal.groups.each{|g|
					# RoleDetail.create(role_log_id: log.id, role_id: g.id, role_name: g)
					_issue_description << "\nrole_id: #{g.id}, role_name: #{g}"
				}

				# Esse controller é invocado duas vezes seguidas quando o usuário
				# é alterado a partir da aba Configurações de dentro de um Projeto
				_last_issue = Issue.find_by("subject = ? and created_on > ?", "[Log] #{memberLoginGroupName}", 1.minute.ago )

				if _last_issue.nil?
					Issue.create(tracker_id: _tracker_id, project_id: _project_id, subject: "[Log] #{memberLoginGroupName}", description: _issue_description, priority_id: 2, author_id: u.id)
				else
					_last_issue.description << "\n\n*Redmine/Fiscaliza fez uma segunda invocação do controller de membros:*\n\n" << _issue_description
					_last_issue.save
				end
			end


  		end #def


  	end	#included


end