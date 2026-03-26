class ChartsController < ApplicationController
  #before_action :authenticate_user!
  before_action :set_regi
  before_action :set_chart, only: [:show, :edit, :update, :destroy]

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
      @chart = @regi.charts.order('t_date ASC').last.dup
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
      redirect_to regi_charts_path(@regi,@chart), notice: 'Patient Chart created...'
    else
      render action: 'new'
    end
  end

  # PUT regis/1/charts/1
  def update
    if @chart.update(chart_params)
      redirect_to regi_charts_path(@regi,@chart), notice: 'Patient Chart updated...'
    else
      render action: 'edit'
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
