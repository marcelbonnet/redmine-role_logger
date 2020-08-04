class Config < ActiveRecord::Migration
	def self.up
		# ############################################
		# mover esse migrate para dentro do fiscaliza
		# ############################################
		say("Criando projeto, tracker e logger defaults para Role Logger plugin")

		project = Project.create(name:"Log de Permissões de Usuários", description: "Logs da mudanças em roles/papéis dos Usuários nos Redmine/Fiscaliza.", is_public: false, identifier: "role_logger" )
		
		tracker = Tracker.create(name:"Log de Papéis", default_status_id: 18)
		tracker.core_fields = []
		tracker.save

		tracker.projects << project 	# persiste automaticamente

		role = Role.create(name:"RoleLogger", permissions: [:view_issues], users_visibility: "members_of_visible_projects", assignable: false)

		# adiciona os membros ao projeto:
		lista = Group.where("lastname like ?", "%-Fiscal%").each{ |g| 
		    member = Member.create_principal_memberships( g, {project_ids: [project.id], role_ids: [role.id]  } )
		}

		say("#{lista.count} grupos adicionados ao projeto")

		Setting.create name: 'plugin_role_logger', value: {"project_id" => project.id, "tracker_id" => tracker.id, "role_id" => role.id }

		say("Ativando o plugin nos projetos das Unidades Descentralizadas")
		Project.find(24).children.each{|project|
			EnabledModule.create(project_id: project.id, name:"role_logger" )
		}

	end

	def self.down
		Setting.find_by("name = ?", "plugin_role_logger").delete

		#  apenas para testes:
		Project.find_by("identifier = ?", "role_logger").delete
		Tracker.find_by("name = ?", "Log de Papéis").delete
		Role.find_by("name = ? ", "RoleLogger").delete
		EnabledModule.where("name = ?", "role_logger").delete_all
	end
end