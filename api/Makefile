.PHONY: lint lint-fix test

lint:
	bundle exec rubocop

lint-fix:
	bundle exec rubocop -A

tests:
	RAILS_ENV=test bundle exec rspec
