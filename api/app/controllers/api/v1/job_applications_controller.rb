module Api
  module V1
    class JobApplicationsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_job_application, only: %i[show update destroy]

      # GET /job_applications
      def index
        @job_applications = current_user.job_applications
        apply_filters

        options = {}
        options[:include] = %i[candidate job]

        render json: JobApplicationSerializer.new(@job_applications, options).serializable_hash
      end

      # GET /job_applications/1
      def show
        options = {}
        options[:include] = %i[candidate job]

        render json: JobApplicationSerializer.new(@job_application, options).serializable_hash
      end

      # POST /job_applications
      def create
        @job_application = current_user.job_applications.new(job_application_params)

        if @job_application.save
          options = {}
          options[:include] = %i[candidate job]

          render json: JobApplicationSerializer.new(@job_application, options).serializable_hash, status: :created
        else
          render json: { errors: @job_application.errors }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /job_applications/1
      def update
        if @job_application.update(job_application_params)
          options = {}
          options[:include] = %i[candidate job]

          render json: JobApplicationSerializer.new(@job_application, options).serializable_hash
        else
          render json: { errors: @job_application.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /job_applications/1
      def destroy
        @job_application.destroy
        head :no_content
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_job_application
        @job_application = JobApplication.by_user(current_user).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Job application not found' }, status: :not_found
      end

      # Only allow a list of trusted parameters through.
      def job_application_params
        params.require(:job_application).permit(:candidate_id, :job_id, :status, :notes)
      end

      def apply_filters
        @job_applications = @job_applications.where(status: params[:status]) if params[:status].present?
        @job_applications = @job_applications.where(job_id: params[:job_id]) if params[:job_id].present?
        @job_applications = @job_applications.where(candidate_id: params[:candidate_id]) if params[:candidate_id].present?
      end
    end
  end
end
