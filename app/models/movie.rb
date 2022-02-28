class Movie < ActiveRecord::Base 
    def self.get_ratings
        # get all ratings 
        select(:rating).map(&:rating).uniq
    end
    
    def self.with_ratings(ratings_list)
        # rating list is true return that or else return all
        if(ratings_list && ratings_list.length)
            where(rating: ratings_list)
        else 
            all
        end
    end
end
