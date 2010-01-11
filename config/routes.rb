ActionController::Routing::Routes.draw do |map|

	if (Redmine::VERSION.to_a <=> [0, 9, 0]) >= 0
		# 0.9.0 or higher
		map.connect 'projects/:id/wiki/:page/graphviz', :controller => 'wiki_graphviz', :action => 'graphviz'
	else
		map.connect 'wiki/:id/:page/graphviz', :controller => 'wiki_graphviz', :action => 'graphviz'
	end
end

# vim: set ts=2 sw=2 sts=2:

