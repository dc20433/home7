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
    
    if @regi.charts.exists?(t_date: chart_params[:t_date])
      flash.now[:alert] = "A chart already exists for this date. Please choose a different date, or cancel the Save."
      render :new, status: :unprocessable_entity
    elsif @chart.save
      redirect_to regi_charts_path(@regi), notice: "Chart created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PUT regis/1/charts/1
  def update
    # Check if another record (not this one) has the new date
    collision = @regi.charts.where(t_date: chart_params[:t_date])
                            .where.not(id: @chart.id)
                            .exists?
  
    if collision
      flash.now[:alert] = "A chart already exists for this date. Please save it under a different date, or cancel the Save."
      render :edit, status: :unprocessable_entity
    elsif @chart.update(chart_params)
      redirect_to regi_charts_path(@regi), notice: "Chart updated successfully."
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

    def check_for_collision
      # Find if ANY OTHER record has this date for this patient
      @collision = @regi.charts.where(t_date: chart_params[:t_date])
                               .where.not(id: @chart.id)
                               .first
    end   

    # Only allow a trusted parameter "white list" through.
    def chart_params
      params.require(:chart).permit(:name, :t_date, :subj, :obj, :assess, :plan, :regi_id)
    end
end
