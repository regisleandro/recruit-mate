class JobsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job, only: %i[show update destroy]
  before_action :set_company, only: %i[index]

  # GET /jobs or GET /companies/:company_id/jobs
  def index
    @jobs = if params[:company_id]
              @company.jobs
            else
              Job.includes(:company).all
            end

    render json: JobSerializer.new(@jobs, include: [:company]).serializable_hash
  end

  # GET /jobs/1
  def show
    render json: JobSerializer.new(@job, include: [:company]).serializable_hash
  end

  # POST /jobs
  def create
    @job = Job.new(job_params)

    if @job.save
      render json: JobSerializer.new(@job).serializable_hash, status: :created
    else
      render json: { errors: @job.errors }, status: :unprocessable_content
    end
  end

  # PATCH/PUT /jobs/1
  def update
    if @job.update(job_params)
      render json: JobSerializer.new(@job).serializable_hash
    else
      render json: { errors: @job.errors }, status: :unprocessable_content
    end
  end

  # DELETE /jobs/1
  def destroy
    @job.destroy
    head :no_content
  end

  private

  def set_job
    @job = Job.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Job not found' }, status: :not_found
  end

  def set_company
    @company = Company.find(params[:company_id]) if params[:company_id]
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Company not found' }, status: :not_found
  end

  def job_params
    params.require(:job).permit(
      :description, :benefits, :keywords, :start_time,
      :end_time, :interval_time, :status, :prompt, :company_id
    )
  end
end
