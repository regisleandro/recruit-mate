class RecruitersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recruiter, only: %i[show update destroy]

  # GET /recruiters
  def index
    @recruiters = Recruiter.all
    render json: RecruiterSerializer.new(@recruiters).serializable_hash
  end

  # GET /recruiters/1
  def show
    render json: RecruiterSerializer.new(@recruiter).serializable_hash
  end

  # POST /recruiters
  def create
    params[:recruiter][:user_id] = current_user.id
    @recruiter = Recruiter.new(recruiter_params)

    if @recruiter.save
      render json: RecruiterSerializer.new(@recruiter).serializable_hash, status: :created
    else
      render json: { errors: @recruiter.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /recruiters/1
  def update
    if @recruiter.update(recruiter_params)
      render json: RecruiterSerializer.new(@recruiter).serializable_hash
    else
      render json: { errors: @recruiter.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /recruiters/1
  def destroy
    @recruiter.destroy
    head :no_content
  end

  private

  def set_recruiter
    @recruiter = Recruiter.find(params[:id])
  end

  def recruiter_params
    params.require(:recruiter).permit(:name, :prompt, :telegram_token, :user_id)
  end
end
