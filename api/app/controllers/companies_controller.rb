class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company, only: %i[show update destroy]

  # GET /companies
  def index
    @companies = Company.all
    render json: CompanySerializer.new(@companies).serializable_hash
  end

  # GET /companies/1
  def show
    render json: CompanySerializer.new(@company).serializable_hash
  end

  # POST /companies
  def create
    params[:company][:user_id] = current_user.id
    @company = Company.new(company_params)

    if @company.save
      render json: CompanySerializer.new(@company).serializable_hash, status: :created
    else
      render json: { errors: @company.errors }, status: :unprocessable_content
    end
  end

  # PATCH/PUT /companies/1
  def update
    if @company.update(company_params)
      render json: CompanySerializer.new(@company).serializable_hash
    else
      render json: { errors: @company.errors }, status: :unprocessable_content
    end
  end

  # DELETE /companies/1
  def destroy
    @company.destroy
    head :no_content
  end

  private

  def set_company
    @company = Company.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Company not found' }, status: :not_found
  end

  def company_params
    params.require(:company).permit(:name, :user_id)
  end
end
