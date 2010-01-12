require File.dirname(__FILE__) + '/../test_helper'

class WikiGraphvizControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def test_routing
	if (Redmine::VERSION.to_a <=> [0, 9, 0]) >= 0
    	assert_recognizes( 
			{
				:controller => 'wiki_graphviz', 
				:action => 'graphviz',
				:id => 'sample',
				:page => 'WikiPage'
			},
			'projects/sample/wiki/WikiPage/graphviz'
		)
    	assert_routing( 
			'projects/sample/wiki/WikiPage/graphviz',
			:controller => 'wiki_graphviz', 
			:action => 'graphviz',
			:id => 'sample',
			:page => 'WikiPage'
		)
	else
    	assert_recognizes( 
			{
				:controller => 'wiki_graphviz', 
				:action => 'graphviz',
				:id => 'sample',
				:page => 'WikiPage'
			},
			'wiki/sample/WikiPage/graphviz'
		)
    	assert_routing( 
			'wiki/sample/WikiPage/graphviz',
			:controller => 'wiki_graphviz', 
			:action => 'graphviz',
			:id => 'sample',
			:page => 'WikiPage'
		)
  	end
  end
end
