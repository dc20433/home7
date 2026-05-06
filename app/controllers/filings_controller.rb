class FilingsController < ApplicationController
  # before_action :authenticate_user!
  before_action :set_regi
  before_action :set_filing, only: [ :show, :edit, :update, :destroy ]

  # GET regis/1/filings
  def index
    # If @regi was not found by before_action, try to find it from the first filing
    @filings = @regi ? @regi.filings : Filing.all

    if @regi.nil? && @filings.any?
      @regi = @filings.first.regi
    end
  end

  # GET regis/1/filings/1
  def show
  end

# GET regis/1/filings/new
# app/controllers/filings_controller.rb
def new
  @regi = Regi.find(params[:regi_id])
  @filing = @regi.filings.build # This ensures @filing.regi is NOT nil
end

  # GET regis/1/filings/1/edit
  def edit
  end

  # POST regis/1/filings
  def create
    @filing = @regi.filings.build(filing_params)
    
    # Check for existing filing on this date
    collision = @regi.filings.find_by(f_date: filing_params[:f_date])
  
    if collision && params[:overwrite] != "true"
      @show_overwrite_warning = true
      # THIS STATUS CODE IS THE KEY
      render :new, status: :unprocessable_entity and return
    end
  
    if @filing.save
      redirect_to regi_filings_path(@regi), status: :see_other, notice: "File saved."
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  # PUT regis/1/filings/1
  def update
    # Use the correct Filing column: f_date
    target_date = filing_params[:f_date]
  
    # Find ANY record for this patient with this filing date
    collision = @regi.filings.find_by(f_date: target_date)
  
    if collision && params[:overwrite] != "true"
      @show_overwrite_warning = true
      @filing.assign_attributes(filing_params)
      render :edit, status: :unprocessable_entity and return
    end
  
    if @filing.update(filing_params)
      redirect_to regi_filings_path(@regi), status: :see_other, notice: "Filing updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE regis/1/filings/1
  def destroy
    @filing.destroy

    redirect_to regi_filings_url(@regi)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_regi
      @regi = Regi.find(params[:regi_id])
    end

    def set_filing
      @filing = @regi.filings.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def filing_params
      params.require(:filing).permit(:title, :describe, :regi_id, :image, :f_date)
    end
end
