module Api
  module V1
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
        @recruiter = Recruiter.new(recruiter_params)
        @recruiter.user = current_user

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

      # Use callbacks to share common setup or constraints between actions.
      def set_recruiter
        @recruiter = Recruiter.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Recruiter not found' }, status: :not_found
      end

      # Only allow a list of trusted parameters through.
      def recruiter_params
        params.require(:recruiter).permit(:name, :prompt, :telegram_token, :openai_key, :user_id)
      end
    end
  end
end
