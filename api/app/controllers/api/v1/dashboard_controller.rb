module Api
  module V1
    class DashboardController < ApplicationController
      before_action :authenticate_user!

      # GET /api/v1/dashboard
      def index
        render json: {
          stats: {
            jobs_opened: current_user.jobs.where(status: 'open').count,
            applications: current_user.job_applications.count,
            jobs_with_offers: current_user.jobs.where(status: 'offer_extended').count
          },
          recent_activity: {
            new_jobs: recent_jobs,
            new_candidates: recent_candidates,
            new_applications: recent_applications
          }
        }
      end

      private

      def recent_jobs
        current_user.jobs.order(created_at: :desc).limit(5).map do |job|
          {
            id: job.id,
            title: job.title,
            company_name: job.company.name,
            created_at: job.created_at
          }
        end
      end

      def recent_candidates
        current_user.candidates.order(created_at: :desc).limit(5).map do |candidate|
          {
            id: candidate.id,
            name: candidate.name,
            created_at: candidate.created_at
          }
        end
      end

      def recent_applications
        current_user.job_applications.includes(:job, :candidate).order(created_at: :desc).limit(5).map do |application|
          {
            id: application.id,
            candidate_name: application.candidate.name,
            job_title: application.job.title,
            company_name: application.job.company.name,
            status: application.status,
            created_at: application.created_at
          }
        end
      end
    end
  end
end
