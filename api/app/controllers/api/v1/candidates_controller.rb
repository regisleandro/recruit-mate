module Api
  module V1
    class CandidatesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_candidate, only: %i[show update destroy]

      # GET /candidates
      def index
        @candidates = current_user.candidates

        render json: CandidateSerializer.new(@candidates).serializable_hash
      end

      # GET /candidates/1
      def show
        render json: CandidateSerializer.new(@candidate).serializable_hash
      end

      # POST /candidates
      def create
        @candidate = current_user.candidates.new(candidate_params)

        if @candidate.save
          # Process file upload if a curriculum file was provided
          process_curriculum_file if params[:curriculum_file].present?
          # Reload to get updated attributes
          @candidate.reload

          render json: CandidateSerializer.new(@candidate).serializable_hash, status: :created
        else
          render json: { errors: @candidate.errors }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /candidates/1
      def update
        if @candidate.update(candidate_params)
          # Process file upload if a curriculum file was provided
          process_curriculum_file if params[:curriculum_file].present?
          # Reload to get updated attributes
          @candidate.reload

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
        @candidate = current_user.candidates.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Candidate not found' }, status: :not_found
      end

      # Only allow a list of trusted parameters through.
      def candidate_params
        candidate_params = params.require(:candidate).permit(:name, :curriculum, :curriculum_summary,
                                                             :cellphone_number, :cpf, :user_id)
        candidate_params[:user_id] = current_user.id
        candidate_params
      end

      # Process curriculum file upload
      def process_curriculum_file
        curriculum_file = params[:curriculum_file]
        return unless curriculum_file && curriculum_file[:filename].present? && curriculum_file[:data].present?

        # Extract the file data from the base64 encoded string
        # The data comes in format "data:application/pdf;base64,ACTUAL_DATA"
        file_data = curriculum_file[:data]

        # Remove the data URL prefix if present
        file_data = file_data.split('base64,').last if file_data.include?('base64,')

        # Decode the base64 data
        decoded_file_data = Base64.decode64(file_data)

        # Save the file using the curriculum service
        CurriculumService.save_curriculum_file(@candidate, decoded_file_data, curriculum_file[:filename])

        # Save the candidate again to update the curriculum field
        @candidate.save
      end
    end
  end
end
