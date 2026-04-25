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

    if @filing.save
      redirect_to regi_filings_path(@regi, @filing), notice: "Patient File created..."
    else
      render action: "new"
    end
  end

  # PUT regis/1/filings/1
  def update
    if @filing.update(filing_params)
      redirect_to regi_filings_path(@regi, @filing), notice: "Patient File changed..."
    else
      render action: "edit"
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
      # We list all possible params
      list = [ :title, :describe, :regi_id, :image ]

      # Only add :f_date to the permit list if the column actually exists
      list << :f_date if Filing.column_names.include?("f_date")

      params.require(:filing).permit(list)
    end
end
