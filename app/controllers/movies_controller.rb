class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # @all_ratings = Movie.uniq.pluck(:rating).sort_by!{ |e| e.downcase }
    @all_ratings = Movie.possible_ratings #get the possible ratings from Movie model
    # @selected_ratings and params[:selected_ratings] represent array of selected ratings
    # params[:ratings] is a dict of the selected ratings with value set to 1
    if params[:selected_ratings] != nil #if ratings are selected
      @selected_ratings = params[:selected_ratings]
    elsif session[:selected_ratings] == nil and params[:ratings] == nil #if no ratings selected
      @selected_ratings = @all_ratings #select all ratings by default
    elsif params[:ratings] == nil #if just param ratings is nil but session selected ratings exists
      @selected_ratings = session[:selected_ratings]
    else
      @selected_ratings = params[:ratings].keys
      params[:selected_ratings] = @selected_ratings
    end

    if params[:sort_by] == nil
      sort_by = session[:sort_by]
    else
      sort_by = params[:sort_by]
    end

    if session[:selected_ratings] != params[:selected_ratings] or session[:sort_by] != params[:sort_by]
       session[:selected_ratings] =  @selected_ratings
       session[:sort_by] = sort_by
       flash.keep
       redirect_to selected_ratings: @selected_ratings, sort_by: sort_by
    end

    @movies = Movie.with_ratings(@selected_ratings).order(sort_by)
    if sort_by == 'title'
      @title_header_style = 'bg-warning hilite'
    elsif sort_by == 'release_date'
      @release_date_header_style = 'bg-warning hilite'
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
