require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting wiki_graphviz_plugin for Redmine'

Redmine::Plugin.register :wiki_graphviz_plugin do
  name 'Graphviz Wiki-macro Plugin'
  author 'tckz'
  url "http://passing.breeze.cc/mt/" if respond_to?(:url)
  description 'Render graph image from the wiki contents by Graphviz(http://www.graphviz.org/)'
  version '0.2.2'
	settings :default => {'cache_seconds' => '0'}, :partial => 'wiki_graphviz/settings'
	requires_redmine :version_or_higher => '1.3.0'

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
			m.graphviz(args, params[:project_id])
		end

		desc <<'EOF'
Render graph image from the current wiki page.

  // !{{graphviz_me}}
  // !{{graphviz_me(option=value...)}}

* options: see graphviz macro.
EOF
		macro	:graphviz_me do |wiki_content_obj, args|
			m = WikiGraphvizHelper::Macro.new(self, wiki_content_obj)
			m.graphviz_me(args, params[:project_id], params[:id])
		end
	end
end



# vim: set ts=2 sw=2 sts=2:
