# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

match 'role_logs' => 'role_logs#index', via: 'get'
# mapeia verbos HTTP para actions do controller: (new, edit, show, ...)
resources :role_logs