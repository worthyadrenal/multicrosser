class CrosswordsController < ApplicationController
  def show
    redirect_to room_path(
      source: params[:source],
      series: params[:series],
      identifier: params[:identifier],
      room: SecureRandom.uuid
    )
  end
  def fetch
    crossword = Crossword.fetch_from_source(params[:source], params[:id])

    if crossword.title
      render json: crossword, status: :created
    else
      render json: { error: "Something went wrong" }, status: :unprocessable_entity
    end
  end

end
