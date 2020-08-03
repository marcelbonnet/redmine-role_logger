module RoleMembersExtension
  extend ActiveSupport::Concern

  	included do
  		has_many :roledetails
  		
  	end
  end
