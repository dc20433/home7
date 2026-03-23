class ChartsController < ApplicationController
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
    @chart = @regi.charts.build
  end

  # GET regis/1/charts/1/edit
  def edit
  end

  # POST regis/1/charts
  def create
    @chart = @regi.charts.build(chart_params)

    if @chart.save
      redirect_to([@chart.regi, @chart], notice: 'Chart was successfully created.')
    else
      render action: 'new'
    end
  end

  # PUT regis/1/charts/1
  def update
    if @chart.update(chart_params)
      redirect_to([@chart.regi, @chart], notice: 'Chart was successfully updated.')
    else
      render action: 'edit'
    end
  end

  # DELETE regis/1/charts/1
  def destroy
    @chart.destroy

    redirect_to regi_charts_url(@regi)
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
      params.require(:chart).permit(:t_date, :subj, :obj, :assess, :plan)
    end
end
