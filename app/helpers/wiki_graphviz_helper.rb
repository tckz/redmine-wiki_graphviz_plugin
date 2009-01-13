require 'digest/sha2'
require	'tempfile'

module WikiGraphvizHelper

	ALLOWED_LAYOUT = {
		"circo" => 1, 
		"dot" => 1, 
		"fdp" => 1, 
		"neato" => 1, 
		"twopi" => 1,
	}.freeze

	ALLOWED_FORMAT = {
		"png" => { :type => "png", :ext => ".png", :content_type => "image/png" },
		"jpg" => { :type => "jpg", :ext => ".jpg", :content_type => "image/jpeg" },
	}

	def	render_graph(params, dot_text, options = {})
		layout = decide_layout(params[:layout])
		fmt = decide_format(params[:format])

		name = Digest::SHA256.hexdigest( {
			:layout => params[:layout],
			:format => params[:format],
			:dot_text => dot_text,
		}.to_s)
		cache_seconds = Setting.plugin_wiki_graphviz_plugin['cache_seconds'].to_i
		resule = nil
		if cache_seconds > 0
			# expect ActiveSupport::Cache::MemCacheStore
			result = read_fragment name , :raw => false
		end

		if !result
			result = self.render_graph_exactly(layout, fmt, dot_text, options)
			# expect ActiveSupport::Cache::MemCacheStore
			if cache_seconds > 0
				write_fragment name, result, :expires_in => cache_seconds, :raw => false
				RAILS_DEFAULT_LOGGER.debug "cache saved: #{name}"
			end
		else
			RAILS_DEFAULT_LOGGER.debug "from cache: #{name}"
		end

		return result
	end

	def	render_graph_exactly(layout, fmt, dot_text, options = {})

		dir = File.join([RAILS_ROOT, 'tmp', 'wiki_graphviz_plugin'])
		begin
			Dir.mkdir(dir)
		rescue
		end
		temp_img = Tempfile.open("graph", dir)
		temp_img.close
		fn_img = temp_img.path
		temp_map = Tempfile.open("map", dir)
		temp_map.close
		fn_map = temp_map.path

		result = {}

		pipe = IO.pipe
		pid = fork {
			# child

			# Gv reports errors to stderr immediately.
			# so, get the message from pipe
			STDERR.reopen(pipe[1])

			require 'gv'

			g = nil
			ec = 0
			begin
				g = Gv.readstring(dot_text)
				if g.nil?
					ec = 1
					raise	"readstring"
				end
				r = Gv.layout(g, layout)
				if !r
					ec = 2
					raise	"layout"
				end
				r = Gv.render(g, fmt[:type], fn_img)
				if !r
					ec = 3
					raise	"render"
				end
				r = Gv.render(g, "imap", fn_map)
				if !r
					ec = 4
					raise	"render imap"
				end
			rescue
			ensure
				if g
					Gv.rm(g)
				end
			end
			exit! ec
		}

		# parent
		pipe[1].close
		ec = nil
		begin
			Process.waitpid pid
			ec = $?.exitstatus
			RAILS_DEFAULT_LOGGER.info("child status: sig=#{$?.termsig}, exit=#{ec}")
		rescue
		end
		result[:message] = pipe[0].read.to_s.strip
		pipe[0].close

		img = nil
		maps = []
		begin
			if !ec.nil? && ec == 0
				temp_img.open
				img = temp_img.read

				temp_map.open
				temp_map.each {|t|
					cols = t.split(/ /)
					if cols[0] == "base"
						next
					end

					shape = cols.shift
					url = cols.shift
					maps.push(:shape => shape, :url => url, :positions => cols)
				}
			end
		rescue
		ensure
			temp_img.close(true)
			temp_map.close(true)
		end

		result[:image] = img
		result[:maps] = maps
		result[:format] = fmt
		result
	end


	def	make_macro_output_by_title(macro_params, wiki_id)
		page = @wiki.find_page(macro_params[:title], :project => @project)
		if page.nil? || 
			!User.current.allowed_to?(:view_wiki_pages, page.wiki.project)
			raise "Page(#{macro_params[:title]}) not found" 
		end

		if	macro_params[:version] && !User.current.allowed_to?(:view_wiki_edits, @project)
			macro_params[:version] = nil
		end

		content = page.content_for_version(macro_params[:version])
		self.make_macro_output_by_text(content.text, macro_params, wiki_id)
	end

	def	make_macro_output_by_text(dottext, macro_params, wiki_id)
		graph = self.render_graph(macro_params, dottext)
		if !graph[:image]
			raise "page=#{macro_params[:title]}, error=#{graph[:message]}"
		end

		macro = {
			:wiki_id => wiki_id,
			:params => macro_params,
			:graph => graph,
			:dottext => dottext,
			:map_index => @index_macro,
		}

    render_to_string :template => 'wiki_graphviz/macro', :layout => false, :locals => {:macro => macro}
	end

	def	countup_macro_index
		if @index_macro
			@index_macro = @index_macro + 1
		else
			@index_macro = 0
		end
		@index_macro
	end

private 
	def	decide_format(fmt)
		fmt = ALLOWED_FORMAT[fmt.to_s.downcase]
		fmt ||= ALLOWED_FORMAT["png"]

		fmt
	end

	def	decide_layout(layout)
		layout = layout.to_s.downcase
		if !ALLOWED_LAYOUT[layout]
			layout = "dot"
		end

		layout
	end


	class Macro
		def	initialize(view, wiki_content)
			@content = wiki_content

			@view = view
			@view.controller.extend(WikiGraphvizHelper)
		end

		def	graphviz(args, wiki_id)
			begin
				title = args.pop.to_s
				if title == ""
					raise "With no argument, this macro needs wiki page name"
				end

				set_macro_params(args)
				macro_params = @macro_params.clone
				macro_params[:title] = title
				@view.controller.countup_macro_index()
				@view.controller.make_macro_output_by_title(macro_params, wiki_id)
			rescue => e
				# formatter.rb catch exception and write e.to_s as HTML. so escape message.
				ex = RuntimeError.new(@view.html_escape e.message)
				ex.set_backtrace(e.backtrace)
				raise ex
			end
		end

		def	graphviz_me(args, wiki_id, title)
			begin
				if @content.nil?
					return	""
				end

				set_macro_params(args)
				macro_params = @macro_params.clone
				macro_params[:title] = title
				@view.controller.countup_macro_index()
				@view.controller.make_macro_output_by_text(@content.text, macro_params, wiki_id)
			rescue => e
				# formatter.rb catch exception and write e.to_s as HTML. so escape message.
				ex = RuntimeError.new(@view.html_escape e.message)
				ex.set_backtrace(e.backtrace)
				raise ex
			end
		end

private
		def	set_macro_params(args)
			@macro_params = {
				:format => "png",
				:layout => "dot",
			}

			need_value = {
				:format => true, 
				:lauout => true,
				:target => true,
				:href => true,
				:wiki => true,
				:align => true,
				:width => true,
				:height => true,
			}

			args.each {|a|
				k, v = a.split(/=/, 2).map { |e| e.to_s.strip }
				if k.nil? || k == ""
					next
				end

				sym = k.intern
				if need_value[sym] && (v.nil? || v.to_s == "")
					raise "macro parameter:#{k} needs value"
				end
				@macro_params[sym] = v.nil? ? true : v.to_s
			}
		end
	end
end

# vim: set ts=2 sw=2 sts=2:

