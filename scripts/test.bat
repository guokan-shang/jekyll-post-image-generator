docker run -v %cd%:/apps --rm alpine/bundle:2.7.0 ^
/bin/bash -c "gem install bundler:2.4.2 ^
&& bundle install ^
&& bundle exec rubocop ^
&& bundle exec rspec"