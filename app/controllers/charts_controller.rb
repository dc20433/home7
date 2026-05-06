class ChartsController < ApplicationController
  # before_action :authenticate_user!
  before_action :set_regi
  before_action :set_chart, only: [ :show, :edit, :update, :destroy ]
  before_action :ensure_staff_only

  # GET regis/1/charts
  def index
    @charts = @regi.charts
  end

  # GET regis/1/charts/1
  def show
  end

  # GET regis/1/charts/new
  def new
    if defined?(Chart.where(regi_id: params[:regi_id]).last.id)
      @chart = @regi.charts.order("t_date ASC").last.dup
    else
      @chart = @regi.charts.build
    end
  end

  # GET regis/1/charts/1/edit
  def edit
  end

  # POST regis/1/charts
  def create
    @chart = @regi.charts.build(chart_params)

    if @chart.save
      redirect_to regi_charts_path(@regi, @chart), notice: "Patient Chart created..."
    else
      render action: "new"
    end
  end

  # PUT regis/1/charts/1
  def update
    # 1. Look for ANY record (including this one) with the same date
    collision = @regi.charts.find_by(t_date: chart_params[:t_date])
  
    # 2. TRIGGER: If a collision exists and 'overwrite' hasn't been confirmed
    if collision && params[:overwrite] != "true"
      @show_overwrite_warning = true
      @chart.assign_attributes(chart_params)
      
      # Exit here so the "Final Save" logic below is not reached
      render :edit, status: :unprocessable_entity and return
    end
  
    # 3. Final Save: Only reached if no collision OR overwrite == "true"
    if @chart.update(chart_params)
      redirect_to regi_charts_path(@regi), status: :see_other, notice: "Patient Chart updated..."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE regis/1/charts/1
  def destroy
    @chart.destroy
    redirect_to regi_charts_path(@regi), notice: "Chart deleted..."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_regi
      @regi = Regi.find(params[:regi_id])
    end

    def set_chart
      @chart = @regi.charts.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def chart_params
      params.require(:chart).permit(:name, :t_date, :subj, :obj, :assess, :plan, :regi_id)
    end
end
