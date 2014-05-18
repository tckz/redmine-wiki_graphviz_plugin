require 'redmine'


Rails.logger.info 'Starting wiki_graphviz_plugin for Redmine'

Redmine::Plugin.register :wiki_graphviz_plugin do |plugin|
  name 'Graphviz Wiki-macro Plugin'
  author 'tckz'
  url "http://passing.breeze.cc/mt/" if respond_to?(:url)
  description 'Render graph image from the wiki contents by Graphviz(http://www.graphviz.org/)'
  version '0.5.0'
	settings :default => {'cache_seconds' => '0'}, :partial => 'wiki_graphviz/settings'
	requires_redmine :version_or_higher => '2.2.2'

	Redmine::WikiFormatting::Macros.register do

		desc <<'EOF'
Render graph image from the wiki page which is specified by macro-args.

<pre>
{{graphviz(Foo)}}
{{graphviz(option=value...,Foo)}}
</pre>

* options are:
** format={png|jpg}
** layout={dot|neato|fdp|twopi|circo}
** target={_blank|any}
** with_source
** no_map
** wiki=page(which link to)
** link_to_image
** align=value(e.g. {right|left})
** width=value(e.g. 100px, 200%)
** height=value(e.g. 100px, 200%)
EOF

		plugin_directory = File.basename(File.dirname(__FILE__))

		check_plugin_directory = lambda {
			if plugin_directory != plugin.id.to_s
				raise "*** Plugin directory name of 'Graphviz Wiki-macro Plugin' is must be '#{plugin.id}', but '#{plugin_directory}'"
			end
		}

		macro :graphviz do |wiki_content_obj, args|
			check_plugin_directory.call
			m = WikiGraphvizHelper::Macro.new(self, wiki_content_obj)
			m.graphviz(args).html_safe
		end

		desc <<'EOF'
Render graph image from the current wiki page.

<pre>
// {{graphviz_me}}
// {{graphviz_me(option=value...)}}
</pre>

* options: see graphviz macro.
EOF
		macro	:graphviz_me do |wiki_content_obj, args|
			check_plugin_directory.call
			m = WikiGraphvizHelper::Macro.new(self, wiki_content_obj)
			m.graphviz_me(args, params[:id]).html_safe
		end


		desc <<'EOF'
Render graph image from text within the macro command.

<pre>
{{graphviz_link()
  graphviz commands
}}
{{graphviz_link(option=value...,foo)
  graphviz commands
}}
</pre>

* options: see graphviz macro.
EOF
		macro	:graphviz_link do |wiki_content_obj, args, dottext |
			check_plugin_directory.call
			m = WikiGraphvizHelper::Macro.new(self, wiki_content_obj)
			m.graphviz_link(args, params[:id], dottext).html_safe
		end

	end
end


      
# vim: set ts=2 sw=2 sts=2:
