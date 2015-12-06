class Api::V1::SkillsController < ApplicationController
  before_action :set_skill, only: [:show, :edit, :update, :destroy]

  api :GET, '/skills', 'List skills'
  description 'Returns a list of skills.'
  formats ['json']
  def index
    @skills = Skill.all
    render json: @skills
  end

  api :GET, '/skills/:id', 'Show skill'
  description 'Returns skill.'
  formats ['json']
  def show
    render json: @skill
  end

  api :POST, '/skills/', 'Create new skill'
  description 'Creates and returns the new skill.'
  formats ['json']
  param :skill, Hash, desc: 'Skill attributes', required: true do
    param :name, String, desc: 'Name', required: true
  end
  def create
    @skill = Skill.new(skill_params)

    if @skill.save
      render json: @skill, status: :created
    else
      render json: @skill.errors, status: :unprocessable_entity
    end
  end

  api :PATCH, '/skills/:id', 'Update skill'
  description 'Updates and returns the updated skill.'
  formats ['json']
  param :skill, Hash, desc: 'Skill attributes', required: true do
    param :name, String, desc: 'Name'
  end
  def update
    if @skill.update(skill_params)
      render json: @skill, status: :ok
    else
      render json: @skill.errors, status: :unprocessable_entity
    end
  end

  api :DELETE, '/skills/:id', 'Delete skill'
  description 'Deletes skill.'
  formats ['json']
  def destroy
    @skill.destroy
    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_skill
      @skill = Skill.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def skill_params
      params.require(:skill).permit(:name)
    end
end