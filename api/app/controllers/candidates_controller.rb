class CandidatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_candidate, only: %i[show update destroy]

  # GET /candidates
  def index
    @candidates = Candidate.where(user_id: current_user.id)
    render json: CandidateSerializer.new(@candidates).serializable_hash
  end

  # GET /candidates/1
  def show
    render json: CandidateSerializer.new(@candidate).serializable_hash
  end

  # POST /candidates
  def create
    @candidate = Candidate.new(candidate_params)
    @candidate.user = current_user

    if params[:curriculum_file].present?
      create_with_curriculum_file
    else
      create_without_curriculum_file
    end
  end

  # PATCH/PUT /candidates/1
  def update
    if params[:curriculum_file].present?
      update_with_curriculum_file
    else
      update_without_curriculum_file
    end
  end

  # DELETE /candidates/1
  def destroy
    CurriculumService.delete_curriculum_file(@candidate)
    @candidate.destroy
    head :no_content
  end

  private

  def set_candidate
    @candidate = Candidate.find_by(id: params[:id], user_id: current_user.id)
    render json: { error: 'Candidate not found' }, status: :not_found unless @candidate
  end

  def candidate_params
    params.require(:candidate).permit(:name, :curriculum_summary, :cellphone_number, :cpf)
  end

  def create_with_curriculum_file
    # Save the candidate first to get the ID for the file path
    if @candidate.save
      process_curriculum_file(params[:curriculum_file][:data], params[:curriculum_file][:filename])
    else
      render_unprocessable_entity(@candidate.errors)
    end
  end

  def create_without_curriculum_file
    if @candidate.save
      render json: CandidateSerializer.new(@candidate).serializable_hash, status: :created
    else
      render_unprocessable_entity(@candidate.errors)
    end
  end

  def update_with_curriculum_file
    file_data = Base64.decode64(params[:curriculum_file][:data])
    file_name = params[:curriculum_file][:filename]

    if CurriculumService.save_curriculum_file(@candidate, file_data, file_name)
      update_candidate_attributes
    else
      render_unprocessable_entity({ curriculum: ['Failed to save curriculum file'] })
    end
  end

  def update_without_curriculum_file
    update_candidate_attributes
  end

  def update_candidate_attributes
    if @candidate.update(candidate_params)
      render json: CandidateSerializer.new(@candidate).serializable_hash
    else
      render_unprocessable_entity(@candidate.errors)
    end
  end

  def process_curriculum_file(encoded_data, filename)
    file_data = Base64.decode64(encoded_data)

    if CurriculumService.save_curriculum_file(@candidate, file_data, filename)
      @candidate.save
      render json: CandidateSerializer.new(@candidate).serializable_hash, status: :created
    else
      @candidate.destroy # If file saving fails, delete the candidate
      render_unprocessable_entity({ curriculum: ['Failed to save curriculum file'] })
    end
  end

  def render_unprocessable_entity(errors)
    render json: { errors: errors }, status: :unprocessable_entity
  end
end
