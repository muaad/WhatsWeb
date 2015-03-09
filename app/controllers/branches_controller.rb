class BranchesController < ApplicationController
  before_action :set_branch, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token

  respond_to :html

  def index
    @branches = Branch.all
    respond_with(@branches)
  end

  def show
    respond_with(@branch)
  end

  def new
    @branch = Branch.new
    respond_with(@branch)
  end

  def edit
  end

  def create
    @branch = Branch.new(branch_params)
    @branch.save
    respond_with(@branch)
  end

  def update
    @branch.update(branch_params)
    respond_with(@branch)
  end

  def destroy
    @branch.destroy
    respond_with(@branch)
  end

  def send_location
    branch = Branch.find_nearest params[:latitude], params[:longitude]
    HTTParty.post("http://app.ongair.im/api/v1/base/send?token=#{ENV['ONGAIR_API_KEY']}", body: {phone_number: params[:phone_number], text: branch.address, thread: true})
    render json: {success: true}
  end

  private
    def set_branch
      @branch = Branch.find(params[:id])
    end

    def branch_params
      params.require(:branch).permit(:address, :latitude, :longitude)
    end
end
