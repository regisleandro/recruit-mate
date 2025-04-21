module Api
  module V1
    class CandidatesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_candidate, only: %i[show update destroy]

      # GET /candidates
      def index
        @candidates = Candidate.all

        render json: CandidateSerializer.new(@candidates).serializable_hash
      end

      # GET /candidates/1
      def show
        render json: CandidateSerializer.new(@candidate).serializable_hash
      end

      # POST /candidates
      def create
        @candidate = Candidate.new(candidate_params)

        if @candidate.save
          render json: CandidateSerializer.new(@candidate).serializable_hash, status: :created
        else
          render json: { errors: @candidate.errors }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /candidates/1
      def update
        if @candidate.update(candidate_params)
          render json: CandidateSerializer.new(@candidate).serializable_hash
        else
          render json: { errors: @candidate.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /candidates/1
      def destroy
        @candidate.destroy
        head :no_content
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_candidate
        @candidate = Candidate.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Candidate not found' }, status: :not_found
      end

      # Only allow a list of trusted parameters through.
      def candidate_params
        params.require(:candidate).permit(:name, :curriculum, :curriculum_summary, :cellphone_number, :cpf, :user_id)
      end
    end
  end
end
