# Todo
* History View
* Table Searching (Quick Search)
* Year View
* Most Popular Categories
* Most Popular Places to Buy From
* Money Spent Per Place

# Procfile
web:        bundle exec rackup -p $PORT -E $ENVIRONMENT
worker:     bundle exec rake resque:work QUEUE=*
scheduler:  bundle exec rake resque:scheduler