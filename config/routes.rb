RedmineApp::Application.routes.draw do
	match 'projects/:project_id/wiki/:id/graphviz', :to => 'wiki_graphviz#graphviz'
	match 'projects/:project_id/graphviz', :to => 'wiki_graphviz#graphviz'
end

# vim: set ts=2 sw=2 sts=2:

