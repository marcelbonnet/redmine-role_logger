require 'redmine'

# Injeção de dependências
ActionDispatch::Reloader.to_prepare do
  require 'concerns/role_members_controller_extension'
  MembersController.send :include, RoleMembersControllerExtension
  PrincipalMembershipsController.send :include, RoleMembersControllerExtension
  PrincipalMembershipsController.send :include, RoleMembersControllerExtension
require 'concerns/role_users_controller_extension'
  UsersController.send :include, RoleUsersControllerExtension
  require 'concerns/role_member_extension'
  Member.send :include, RoleMembersExtension
end

Redmine::Plugin.register :role_logger do
  name 'Role Logger'
  author 'Marcel Bonnet'
  description 'Log de mudanças em papéis/role de usários'
  version '0.2'
  url 'https://github.com/marcelbonnet/redmine-plugin-role-logger'
  author_url 'https://github.com/marcelbonnet/'

  requires_redmine :version_or_higher => '3.0.0'


	project_module :role_logger do
		permission :role_logger_read, { 
			:role_logs => [:index]
		}
	end

  settings :default => {'empty' => true}, :partial => 'settings/plugin_settings'

  # when enabled as project_module, this route will raise 404
  # menu :top_menu, :role, "/role_logs", :caption => :role_menu_title
  # menu :project_menu, :plugin_example, { :controller => 'example', :action => 'say_hello' }, :caption => 'Sample'
	# menu :project_menu, :role_logger, { :controller => 'role_logs', :action => 'index' } , :caption => :role_menu_title, :after => :activity, :param => :project_id
end
