class PublicController < ApplicationController
  layout 'public'

  before_filter :set_layout
  before_filter :generate_menu

  def index
  end


  def page
    @page = Page.find(params[:id])
    if @page.nil? or @page.public == 0 or @page.state != 2
      render :text => 'Virheellinen sivu'
      return
    end
    @layout = @page.layout
  end

  private
  def set_layout
    @layout = Layout.find(:first)
  end

  def generate_menu
    @mainmenu = Page.find(:all, :conditions => {:public => 1, :state => 2})
  end
  


end
