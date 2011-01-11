ActionController::Routing::Routes.draw do |map|
	map.connect 'projects/:project_id/wiki/:id/graphviz', :controller => 'wiki_graphviz', :action => 'graphviz'
end

# vim: set ts=2 sw=2 sts=2:

