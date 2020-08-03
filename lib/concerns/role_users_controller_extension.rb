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

						log = RoleLog.create(user_id: u.id, project_id: mod.project.id, member_id: member.id, principal_type: "User", principal_id: @user.id ,principal_name: @user.login, admin: @user.admin )
						for i in 0..group_ids.length-1
							RoleDetail.create(role_log_id: log.id, group_id: group_ids[i], group_name: group_names[i])
						end
					}
				else
					# usuário foi modificado como admin e não pertence a nenhum projeto com Role habilitado como módulo
					RoleLog.create(user_id: u.id, project_id: nil, member_id: nil, principal_type: "User", principal_id: @user.id ,principal_name: @user.login, admin: @user.admin )
				end

			end

  		end #def


  	end	#included


end
