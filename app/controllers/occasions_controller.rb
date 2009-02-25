class OccasionsController < ApplicationController
   before_filter :login_required

   skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_occasion_location_id, :auto_complete_for_occasion_occasion_type_id]   
#   skip_before_filter :verify_authenticity_token
   
  # GET /occasions
  # GET /occasions.xml
  def index
   redirect_to :action => 'list'
#    if params[:view].to_s == "calendar"
#      redirect_to :action => 'calendar'          
#    else
#      redirect_to :action => 'list'
#    end
  end

  def list
   @occasion = Occasion.new
  
   select_month

   locations_and_occasion_types
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @occasions }
    end    
  end
  
  # GET /occasions/1
  # GET /occasions/1.xml
  def show
    @occasion = Occasion.find(params[:id])

    # Varautuminen siihen, että paikkaa ja tapahtumatyyppiä ei ole annettu (eivät pakollisia)
    locations_and_occasion_types

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @occasion }
    end
  end

  # GET /occasions/new
  # GET /occasions/new.xml
  def new
    @occasion = Occasion.new

    locations_and_occasion_types

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @occasion }
    end
  end

  # GET /occasions/1/edit
  def edit
    @occasion = Occasion.find(params[:id])

    # Varautuminen siihen, että paikkaa ja tapahtumatyyppiä ei ole annettu (eivät pakollisia)
    locations_and_occasion_types
  end

  # POST /occasions
  # POST /occasions.xml
  def create
    @occasion = Occasion.new(params[:occasion])
     
    find_or_create_locations_and_occasion_types
    
    respond_to do |format|
      if @occasion.save
        @occasion.update_attribute(:customer_id,current_user.customer_id)   

        select_month
        
        flash[:notice] = 'Tapahtuma tallennettu.'
#        format.html { redirect_to(occasion_url(:id => @occasion)) }
        format.html { redirect_to(occasions_url)}
        format.xml  { render :xml => @occasion, :status => :created, :location => @occasion }
        format.js
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @occasion.errors, :status => :unprocessable_entity }
       format.js        
      end
    end
  end

  # PUT /occasions/1
  # PUT /occasions/1.xml
  def update
    @occasion = Occasion.find(params[:id])
    find_or_create_locations_and_occasion_types

    respond_to do |format|
      if @occasion.update_attributes(params[:occasion])
        flash[:notice] = 'Tapahtuman tiedot päivitetty.'
        format.html { redirect_to(occasion_url) }         
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @occasion.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /occasions/1
  # DELETE /occasions/1.xml
  def destroy
    @occasion = Occasion.find(params[:id])
    @occasion.destroy

    respond_to do |format|
      format.html { redirect_to(occasions_url) }
      format.xml  { head :ok }
    end
  end  

  # Autocomplete fields
  def auto_complete_for_occasion_location_id
          @locations = Location.find( :all, :conditions => [ "name LIKE ?", "%#{params[:occasion][:location_id]}%" ] )
          render :partial => 'locations'
  end   

  def auto_complete_for_occasion_occasion_type_id
          @occasion_types = OccasionType.find( :all, :conditions => [ "name LIKE ?", "%#{params[:occasion][:occasion_type_id]}%" ] )
          render :partial => 'occasion_types'
  end   
  
###########
  private
###########  

  def locations_and_occasion_types
    @occasion_types = OccasionType.find(:all)
    @occasion.occasion_type = OccasionType.new unless @occasion.occasion_type
    @occasion_type = @occasion.occasion_type
    @occasion.location = Location.new unless @occasion.location
    @locations = Location.find(:all)
    @location = @occasion.location
  end
  
  def find_or_create_locations_and_occasion_types
    occasion_name = params[:occasion][:location_id]
    @occasion.location = Location.find_or_create_by_name(:name => occasion_name, :customer_id => current_user.customer_id)
    params[:occasion][:location_id] = @occasion.location.id
    
    occasion_type_name = params[:occasion][:occasion_type_id]
    @occasion.occasion_type = OccasionType.find_or_create_by_name(:name => occasion_type_name, :customer_id => current_user.customer_id)
    params[:occasion][:occasion_type_id] = @occasion.occasion_type.id
  end
  
  def select_month
     if params[:year]
        new_date = Date.new(params[:year].to_i,params[:month].to_i)

        if params[:direction] =='back'
          new_date = new_date.advance(:months => -1)
        elsif params[:direction] == 'forward'
          new_date = new_date.advance(:months => 1)
        end

      @occasions = Occasion.find(:all, :conditions => ["start_time > ? AND start_time < ?", new_date.beginning_of_month.to_date, new_date.end_of_month.to_date],:order => "start_time ASC")
      @date = new_date
      
       #tämä pitäs saada toimimaan niin, että näkyvillä oleva kuukausi vaihtuu jos syöttää tapahtumia muuhun ajankohtaan          
#       @occasions = Occasion.find(:all)
#       @date = DateTime.now
     else
       @occasions = Occasion.find(:all, :conditions => ["start_time > ? AND start_time < ?", DateTime.now.beginning_of_month.to_date, DateTime.now.end_of_month.to_date],:order => "start_time ASC")
       @date = DateTime.now
    end
  end
end