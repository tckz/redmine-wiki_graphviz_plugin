require 'redmine'

if File.basename(File.dirname(__FILE__)) != 'wiki_graphviz_plugin'
	raise "*** Plugin directory name of 'Graphviz Wiki-macro Plugin' is must be 'wiki_graphviz_plugin'"
end

Rails.logger.info 'Starting wiki_graphviz_plugin for Redmine'

Redmine::Plugin.register :wiki_graphviz_plugin do
  name 'Graphviz Wiki-macro Plugin'
  author 'tckz'
  url "http://passing.breeze.cc/mt/" if respond_to?(:url)
  description 'Render graph image from the wiki contents by Graphviz(http://www.graphviz.org/)'
  version '0.4.1'
	settings :default => {'cache_seconds' => '0'}, :partial => 'wiki_graphviz/settings'
	requires_redmine :version_or_higher => '2.1.0'

	Redmine::WikiFormatting::Macros.register do

		desc <<'EOF'
Render graph image from the wiki page which is specified by macro-args.

  !{{graphviz(Foo)}}
  !{{graphviz(option=value...,Foo)}}

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
		macro :graphviz do |wiki_content_obj, args|
			m = WikiGraphvizHelper::Macro.new(self, wiki_content_obj)
			m.graphviz(args).html_safe
		end

		desc <<'EOF'
Render graph image from the current wiki page.

  // !{{graphviz_me}}
  // !{{graphviz_me(option=value...)}}

* options: see graphviz macro.
EOF
		macro	:graphviz_me do |wiki_content_obj, args|
			m = WikiGraphvizHelper::Macro.new(self, wiki_content_obj)
			m.graphviz_me(args, params[:id]).html_safe
		end
	end
end



# vim: set ts=2 sw=2 sts=2:
