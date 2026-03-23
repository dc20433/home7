class RegisController < ApplicationController
  before_action :set_regi, only: %i[ show edit update destroy ]

  # GET /regis or /regis.json
  def index
    @regis = Regi.all
  end

  # GET /regis/1 or /regis/1.json
  def show
  end

  # GET /regis/new
  def new
    @regi = Regi.new
  end

  # GET /regis/1/edit
  def edit
  end

  # POST /regis or /regis.json
  def create
    @regi = Regi.new(regi_params)

    respond_to do |format|
      if @regi.save
        format.html { redirect_to @regi, notice: "Regi was successfully created." }
        format.json { render :show, status: :created, location: @regi }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @regi.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /regis/1 or /regis/1.json
  def update
    respond_to do |format|
      if @regi.update(regi_params)
        format.html { redirect_to @regi, notice: "Regi was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @regi }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @regi.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /regis/1 or /regis/1.json
  def destroy
    @regi.destroy!

    respond_to do |format|
      format.html { redirect_to regis_path, notice: "Regi was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_regi
      @regi = Regi.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def regi_params
      params.expect(regi: [ :last_name, :first_name, :init, :gender, :dob ])
    end
end
