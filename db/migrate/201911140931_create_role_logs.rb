class CreateRoleLogs < ActiveRecord::Migration
	def self.up
	    create_table "role_logs" do |t|
	    	t.column	"user_id", :integer, :null => false		# quem fez a mudança
	    	t.column	"project_id", :integer, :null => true	# caso o usuário vire admin e não pertença a nenhum projeto
	    	t.column	"member_id", :integer, :null => true	# caso o usuário vire admin e não pertença a nenhum projeto
	    	t.column	"admin", :boolean, :null => false
	    	t.column	"principal_id", :integer, :null => false
	    	t.column	"principal_type", :string, :null => false
	    	#principal_name: Principal.login if type User or Principal.lastname if type Group
	    	t.column	"principal_name", :string, :null => false
			t.column 	"created_on", :timestamp
	    end	

	    create_table "role_details" do |t|
	    	t.column	"role_id", :integer, :null => true
	    	t.column	"role_name", :string, :null => true
	    	t.column	"group_id", :integer, :null => true
	    	t.column	"group_name", :string, :null => true
	    	# t.column	"role_permissions", :string, :limit => 1000, :null => false
	    end

	    # https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference
	    # add_reference(:table_name, :reference_name) , reference_name is singular, not plural
		add_reference :role_details, :role_log, index: true, foreign_key: true, null:false
		# add_index(table_name, column_names, options)
		add_index :role_details, :role_log_id, name: 'index_role_details_on_role_logs'

		# copiar para o log os papéis e grupos de cada usuário:

	end

	def self.down
		# drop tables in order, observing relations:
		drop_table "role_details"
		drop_table "role_logs"
	end
end
