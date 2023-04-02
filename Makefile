install:
	bundle install
	
run:
	ruby main.rb < inputs/valid_000

test:
	bundle exec rake spec