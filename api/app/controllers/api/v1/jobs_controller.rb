module Api
  module V1
    class JobsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_job, only: %i[show update destroy]

      # GET /jobs
      def index
        @jobs = if params[:company_id]
                  Job.where(company_id: params[:company_id])
                else
                  Job.all
                end

        render json: JobSerializer.new(@jobs).serializable_hash
      end

      # GET /jobs/1
      def show
        render json: JobSerializer.new(@job).serializable_hash
      end

      # POST /jobs
      def create
        @job = Job.new(job_params)

        if @job.save
          render json: JobSerializer.new(@job).serializable_hash, status: :created
        else
          render json: { errors: @job.errors }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /jobs/1
      def update
        if @job.update(job_params)
          render json: JobSerializer.new(@job).serializable_hash
        else
          render json: { errors: @job.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /jobs/1
      def destroy
        @job.destroy
        head :no_content
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_job
        @job = Job.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Job not found' }, status: :not_found
      end

      # Only allow a list of trusted parameters through.
      def job_params
        params.require(:job).permit(:title, :description, :company_id, :benefits, :keywords, :start_time, :end_time,
                                    :interval_time, :status, :prompt)
      end
    end
  end
end
