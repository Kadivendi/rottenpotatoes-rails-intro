class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # CLear the session
    if request.env['PATH_INFO'] == '/'
      session.clear
    end
    # Getting the URL params
    r_clicked = params[:r_clicked]
    sort_values = params[:sort_values]
    @total_ratings = Movie.get_ratings
    newRatings = {}
    @total_ratings.each{ |rating| newRatings[rating] = 1 }
    ratings = {}
    if(sort_values)
      session[:sort_values] = sort_values
    elsif session[:sort_values]
      sort_values = session[:sort_values]
    end
 
    if(r_clicked)
      if(params[:ratings])
        ratings = params[:ratings]
        session[:ratings] = ratings
      else
        ratings = newRatings
        session[:ratings] = nil
      end
    elsif(session[:ratings])
      ratings = session[:ratings]
    elsif(params[:ratings]) 
      ratings = params[:ratings]
      session[:ratings] = ratings
    else
      ratings = newRatings
      session[:ratings] = nil
    end
    
    # Sorting 
    case sort_values
      when "release_date"
        @movie_titles = Movie.order(:release_date)
        @sort_values = "release_date"
      when "movies_title"
        @movie_titles = Movie.order(:title)
        @sort_values = "movies_title"
      else
        @movie_titles = Movie.all
        @sort_values = ''
    end
    
    #get movies with ratings
    @movie_titles = @movie_titles.with_ratings(ratings.keys)
    @ratings_to_show = ratings == newRatings ? newRatings.keys : ratings.keys
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

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end