
class WikiGraphvizController < ApplicationController
	unloadable
  before_filter :find_wiki, :wiki_authorize

	include	WikiGraphvizHelper

  def graphviz
    @page = @wiki.find_page(params[:id], :project => @project)
    if @page.nil?
      render_404
			return
		end

    if params[:version] && !User.current.allowed_to?(:view_wiki_edits, @project)
      # Redirects user to the current version if he's not allowed to view previous versions
			h = params.clone
			h[:version] = nil
      redirect_to h
      return
    end

    @content = @page.content_for_version(params[:version])

		dottext = params[:dottext]

		if dottext.nil?
			dottext = @content.text
		end


		graph = self.render_graph(params, dottext)
		if graph[:image]
			render :text => graph[:image], :layout => false, :content_type => graph[:format][:content_type]
		else
			if graph[:message]
				logger.error("graphviz: '#{graph[:message]}'")
			end
			self.render_error("*** failed to render the graph")
		end
  end

private 

  def wiki_authorize
  	self.authorize("wiki", "index")
  end

  def find_wiki
    @project = Project.find(params[:project_id])
    @wiki = @project.wiki
    render_404 unless @wiki
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end



# vim: set ts=2 sw=2 sts=2:

