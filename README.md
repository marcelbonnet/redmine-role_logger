# Role Logger (Log de Papéis)

Auditoria: Log de membros e papéis de um projeto

Auditing: logs project's members and roles

# Instalando

- Baixar a versão estável mais recente em Tags do repositório
- Copiar o plugin para /usr/share/redmine/plugins
- Usando o terminal, instalar o plugin (migrate):
- cd /usr/share/redmine
- renomear o diretório do plugin para : /usr/share/redmine/plugins/role_logger . Faça isso no terminal com `mv` : ` mv /usr/share/redmine/plugins/redmine-plugin-role_logger-0.1 /usr/share/redmine/plugins/role_logger`
- bin/rake redmine:plugins:migrate NAME=role_logger
- /etc/init.d/apache2 restart

O plugin deve ser ativado por Projeto:

- faça login como admin para ter permissões de alterar projetos
- Ative o Módulo "Role Logger" nos projetos de interesse. Para ativar em "gr03", por exemplo: http://[seu servidor]/projects/gr03/settings/modules e clicar na checkbox Role Logger.

# Desinstalando

Primeiro, remove ele do Redmine (do banco de dados):

- bin/rake redmine:plugins:migrate NAME=role_logger VERSION=0
- apagar o diretório do plugin
- /etc/init.d/apache2 restart
