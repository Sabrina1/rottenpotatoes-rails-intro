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
    # @all_ratings = Movie.uniq.pluck(:rating).sort_by!{ |e| e.downcase } #get the possible ratings from Movie model
    @all_ratings = Movie.possible_ratings #get the possible ratings from Movie model
    #how to figure out which boxes the user checked and
    #how to restrict the database query based on that result.

    if params[:selected_ratings] != nil
      @selected_ratings = params[:selected_ratings]
    elsif params[:ratings] == nil
      @selected_ratings = @all_ratings
    else
      @selected_ratings = params[:ratings].keys
    end
    puts @selected_ratings
    sort_by = params[:sort_by]

    @movies = Movie.with_ratings(@selected_ratings).order(sort_by)
    if sort_by == 'title'
      @title_header = 'bg-warning hilite'
    elsif sort_by == 'release_date'
      @release_date_header = 'bg-warning hilite'
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
