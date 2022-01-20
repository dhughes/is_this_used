# IsThisUsed

Do you ever ask yourself, "Is this method even being used?!" Does your app use ActiveRecord? If so, this gem may be
useful to you!

Large applications can accrue cruft; old methods that might once have been important, but are now unused. The thing is,
software is _complex_. If the method in question was a part of a larger feature that has changed over time, or possibly
been removed or disabled, it can be really difficult to tell if it's being used at all. It can be even worse that than.
The method could be _tested_. 😨 That's bad because now you can tell if you break it and you'll need to maintain it, but
you have no idea if there's any value in the time and effort to do so.

The gem uses ActiveRecord to write to your database, so that's a dependency. Basically, this is really only useful for
Rails applications at this point. Also, as of now, only MySQL is supported. Other DBs could be added in the future.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'is_this_used'
```

And then execute:

```
bundle
```

Or install it yourself as:

```
gem install is_this_used
```

You'll need to generate and run the migrations to add the required tables to your database:

```bash
bundle exec rails generate is_this_used:migrations
bundle exec rails db:migrate 
```

This will create two tables, `potential_crufts`, which is used to collect information on the methods you're
investigating, and `potential_cruft_stacks` which contains unique stack traces for when invocations of that method
actually occur.

## Usage

TODO

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can
also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the
version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/is_this_used.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

# To run tests

## Rails 5.2

bundle exec appraisal rails-5.2 rake

## Rails 6.0

bundle exec appraisal rails-6.0 rake
