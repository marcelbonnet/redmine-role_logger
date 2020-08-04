module RoleUsersControllerExtension
  extend ActiveSupport::Concern

  	included do
  		after_action	:after_persist	, :only => [ :update ]


  		def after_persist

			p=params[:user]['group_ids']
			u=User.current

			group_ids=[]
			logarAdmin=false
			# na tentativa de tornar um usuário Administrador:
			if p.nil? && params[:user].key?("admin")
				logarAdmin = true
			end

			_project_id = Setting.find_by("name = ?", "plugin_role_logger").value["project_id"]
			_tracker_id = Setting.find_by("name = ?", "plugin_role_logger").value["tracker_id"]
			_issue_description = "Mudanças verificadas no evento:"

			if ( !p.nil? && p.length > 1) || logarAdmin
				group_ids=p.take(p.length-1) if not p.nil?
				group_names=[]
				groups = Group.find(group_ids).each{ |g| group_names.push(g.lastname)} ;
				
				# o plugin é ativado por projeto (módulo Role deve estar marcado)
				# Quando um admin alterar um usuário, isso deve ser logado para todos
				# os projetos do usuário, desde que este projeto tenha o módulo Role
				# habilitado.
				userProjs = @user.projects.ids
				modules = EnabledModule.joins(:project).where(["enabled_modules.name = ?", "role_logger" ]).where(project_id: userProjs )

				if modules.size > 0
					modules.each{ |mod|
						member = Member.find_by("user_id = ? and project_id = ?", @user.id, mod.project.id)

						_issue_description << "\n\nMudanças monitoradas na interface Administrativa:"
						_issue_description << "\nproject_id: #{mod.project.id}"
						_issue_description << "\nmember_id: #{member.id}"
						_issue_description << "\nprincipal_type: User"
						_issue_description << "\nprincipal_id: #{@user.id}"
						_issue_description << "\nprincipal_name: #{@user.login}"
						_issue_description << "\nadmin: #{@user.admin}"

						# log = RoleLog.create(user_id: u.id, project_id: mod.project.id, member_id: member.id, principal_type: "User", principal_id: @user.id ,principal_name: @user.login, admin: @user.admin )
						for i in 0..group_ids.length-1
							# RoleDetail.create(role_log_id: log.id, group_id: group_ids[i], group_name: group_names[i])
							_issue_description << "\ngroup_id: #{group_ids[i]}, group_name: #{group_names[i]}"
						end

						issue = Issue.create(tracker_id: _tracker_id, project_id: _project_id, subject: "[Log] #{@user.login}", description: _issue_description, priority_id: 3, author_id: u.id)
					}
				else
					# usuário foi modificado como admin e não pertence a nenhum projeto com Role habilitado como módulo
					# RoleLog.create(user_id: u.id, project_id: nil, member_id: nil, principal_type: "User", principal_id: @user.id ,principal_name: @user.login, admin: @user.admin )

					_issue_description << "\n\nMudanças monitoradas na interface Administrativa, sem um projeto associado:"
					_issue_description << "\nproject_id: nil"
					_issue_description << "\nmember_id: nil"
					_issue_description << "\nprincipal_type: User"
					_issue_description << "\nprincipal_id: #{@user.id}"
					_issue_description << "\nprincipal_name: #{@user.login}"
					_issue_description << "\nadmin: #{@user.admin}"
					
					issue = Issue.create(tracker_id: _tracker_id, project_id: _project_id, subject: "[Log] #{@user.login}", description: _issue_description, priority_id: 4, author_id: u.id)

				end

			end

  		end #def


  	end	#included


end
