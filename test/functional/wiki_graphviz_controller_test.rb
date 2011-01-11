require File.dirname(__FILE__) + '/../test_helper'

class WikiGraphvizControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def test_routing
   	assert_recognizes( 
		{
			:controller => 'wiki_graphviz', 
			:action => 'graphviz',
			:project_id => 'sample',
			:id => 'WikiPage'
		},
		'projects/sample/wiki/WikiPage/graphviz'
	)
   	assert_routing( 
		'projects/sample/wiki/WikiPage/graphviz',
		:controller => 'wiki_graphviz', 
		:action => 'graphviz',
		:project_id => 'sample',
		:id => 'WikiPage'
	)
  end
end
