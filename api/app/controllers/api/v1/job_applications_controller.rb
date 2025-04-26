module Api
  module V1
    class JobApplicationsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_job_application, only: %i[show update destroy]

      # GET /job_applications
      def index
        @job_applications = JobApplication.all
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
        @job_application = JobApplication.new(job_application_params)

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
        @job_application = JobApplication.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Job application not found' }, status: :not_found
      end

      # Only allow a list of trusted parameters through.
      def job_application_params
        params.require(:job_application).permit(:candidate_id, :job_id, :status, :notes)
      end

      # Filter methods
      def apply_filters
        apply_basic_filters
        apply_date_filters
      end

      def apply_basic_filters
        @job_applications = @job_applications.where(job_id: params[:job_id]) if params[:job_id].present?
        if params[:candidate_id].present?
          @job_applications = @job_applications.where(candidate_id: params[:candidate_id])
        end
        @job_applications = @job_applications.where(status: params[:status]) if params[:status].present?
      end

      def apply_date_filters
        if params[:start_date].present?
          start_date = Date.parse(params[:start_date])
          @job_applications = @job_applications.where(created_at: start_date.beginning_of_day..)
        end

        return if params[:end_date].blank?

        end_date = Date.parse(params[:end_date])
        @job_applications = @job_applications.where(created_at: ..end_date.end_of_day)
      end
    end
  end
end
