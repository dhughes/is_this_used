Have you ever asked yourself, "Is this method even being used?!" Does your application use ActiveRecord? If the answers
to these two questions are yes, this gem may be of use to you!

Large applications can accrue cruft; old methods that might once have been important, but are now unused. Unfortunately,
software is _complex_ and sometimes it's unclear if a given method is still being used at all. This adds maintenance
burdens, headaches, and uncertainty.

This gem aims to give you a couple tools to make it easier to know whether specific methods are being used, or not.

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
bundle exec rails generate is_this_used:migration
bundle exec rails db:migrate
```

This will create two tables, `potential_crufts`, which is used to collect information on the methods you're
investigating, and `potential_cruft_stacks` which contains unique stack traces for when invocations of that method
actually occur.

## Usage

is_this_used is pretty simple. Let's say you have a class (or module) like this...

```ruby

class SomeOldClass
  def some_old_method
    # do things
  end
end
```

You're unsure if the `some_old_method` method is actually being used. You only need to do two things:

1. include the `IsThisUsed::CruftTracker` module
2. use the `is_this_used?` method and name the method in question

Here's an example:

```ruby
class SomeOldClass
  include IsThisUsed::CruftTracker

  def some_old_method
    # do things
  end

  is_this_used? :some_old_method
end
```

What do you get out of this? Well, as soon as Ruby loads the `SomeOldClass` class, is_this_used will create a new record
in the `potential_crufts` table that looks like this:

| id  | owner_name   | method_name     | method_type     | invocations | created_at          | updated_at          |
| --- | ------------ | --------------- | --------------- | ----------- | ------------------- | ------------------- |
| 1   | SomeOldClass | some_old_method | instance_method | 0           | 2022-01-21 14:07:48 | 2022-01-21 14:07:48 |

This is easily accessed using the `IsThisUsed::PotentialCruft` model class.

The fields are:

- `id` - Shockingly, this is the primary key.
- `owner_name` - This is the name of the Ruby class or module that owns the method.
- `method_name` - This is the name of the method.
- `method_type` - This is either "instance_method" or "class_method", which are the values of the corresponding
  constants, `IsThisUsed::CruftTracker::INSTANCE_METHOD` and `IsThisUsed::CruftTracker::CLASS_METHOD`.
- `invocations` - The number of times the method has been invoked.
- `created_at` - The date/time we started tracking the method.
- `updated_at` - The last time this record was updated. IE: the last time the tracked method was invoked.

Looking at this, we can see that the `some_old_method` method has never been invoked. This is nice because it means that
you can track uses of methods without changing their behavior. A similar record is created for every method you annotate
with `is_this_used?`.

Assuming your production application eagerly loads classes, you should always have records for potentially crufty
methods, even if the class itself is never explicitly used.

So, having annotated the method, you can check this table after a while. If you see that there have been zero invocations,
you have a reasonably good hint that the method may not actually be used. Of course, you should consider that there are
some processes that are not run frequently at all, so this gem isn't a panacea. Think before you delete!

### Tracking Stacks

In the case that a method _is_ actually invoked, the `invocations` value is incremented and a record is created in
the `potential_cruft_stacks` table for each unique invocation stacktrace. This can be used to determine which methods
and blocks are responsible for calling the method and are themselves being used. This is the structure of
the `potential_cruft_stacks` table:

- `id` - You might be surprised to learn this is the primary key.
- `potential_cruft_id` - A reference to the `potential_crufts` record for the not-actually-crufty method that was
  invoked.
- `stack_hash` - This is an MD5 hash of the stack trace for the method's invocation. This is indexed for speedy lookups
  of stacks.
- `stack` - This is a JSON field that stores an array of hashes (more on this in a sec) that is the stack trace for the
  method invocation. You can potentially use this to figure out what other methods and blocks are involved in calling the
  not-actually-crufty method.
- `occurrences` - This is the number of times the method has been invoked with exactly the same stack.
- `created_at` - The date/time we first saw this stack.
- `updated_at` - The last time we saw this stack.

As a note, if any of the files referenced in the stack are edited sufficiently to change line numbers, the stack will be
different and a new record will be created.

The `stack` data looks like this:

```javascript
[
  {
    path: "/app/path/to/some_file.rb",
    label: "some_method",
    lineno: 2056,
    base_label: "some_method",
  },
  {
    path: "/app/another/path/to/a_file.rb",
    label: "do_it",
    lineno: 2125,
    base_label: "do_it",
  },
  // ...
]
```

The `label` and `base_label` fields come from Ruby's `Thread::Backtrace::Location`. I'm not actually sure what the
difference is, as the docs simply say this about `base_label`: "Usually same as label, without decoration". 🤷 Anyhow,
it's there if you need it.

### Tracking Arguments

In addition to tracking stacks, you can track details about arguments provided to tracked methods. For example, let's say you have the following method:

```ruby
def some_old_method(arg1, arg2)
  # do things
end
```

Let's say that, for some reason you want to know what arguments are provided to this method. You could add `track_arguments: true` to your `is_this_used?` invocation like so:

```ruby
is_this_used? :some_old_method, track_arguments: true
```

Now, as `some_old_method` is invoked, a record will be created in `potential_cruft_arguments` for each unique set of arguments. Similar to `potential_cruft_stacks`, the record contains a hash of the JSON-serialized arguments, the JSON-serialized arguments, and the number of occurrences of the particular combination of arguments.

Tracking all arguments might be a really bad idea. Let's say your method actually gets invoked a lot and receives lots of different combinations of arguments, you could be writing a lot of potentially useless information into the `potential_cruft_arguments` table. For this reason arguments are not tracked by default.

Instead of tracking all arguments, you can also provide a lambda to `track_arguments` to track only specific details about arguments. The lambda will receive an array of arguments that were provided to the tracked method. Whatever is returned from the lambda is what is tracked in the `potential_cruft_arguments` table. This might be useful in a situation where you have a method that receives an options hash. Maybe you want to know what keys are in that options hash. You could track the unique combination of keys like this:

```ruby
def ye_olde_method(some_argument, options_hash)
  # do things
end

is_this_used? :some_old_method, track_arguments: ->(args) { args.last.keys.sort }
```

As `ye_olde_method` is invoked is_this_used will track the unique combination of keys in the `options_hash`. Let's say it's invoked as follows:


```ruby
ye_olde_method("Fred", favorite_color: "blue", locality: 'Antartica')
ye_olde_method("Zelda", locality: 'Hyrule', favorite_color: "green")
ye_olde_method("Korg", color: 'Rebecca Purple', locality: 'Sakaar')
ye_olde_method("Liz", status: :favorite_person)
```

The above would result in the following records in `potential_cruft_arguments` (ignoring the id, potential cruft reference, and timestamps):

| arguments_hash                   | arguments                      | occurrences |
| -------------------------------- | ------------------------------ | ----------- |
| d5d98f761a14b1845a74ce3f1a298c98 | ["favorite_color", "locality"] | 2           |
| 1619ec6af47253461e87ebf1923a8a83 | ["color", "locality"]          | 1           |
| 88c8205498de97d4ef06b249006bb68b | ["status"]                     | 1           |




## Models

### `IsThisUsed::PotentialCruft`

This is a model representing the potential cruft. You can use its `potential_cruft_stacks` to get a list of all of the
invocations of the method, if any.

### `IsThisUsed::PotentialCruftStack`

This is a model representing potential cruft stacks. Its `potential_cruft` method provides an association back to the
owning potentially-crufty method.

### `IsThisUsed::PotentialCruftArgument`

This model represents information about arguments provided to a specific `potential_cruft` method. It is conditionally populated when the `track_arguments` method is provided with either true or a lambda.

## Dependencies

* ActiveRecord - ActiveRecord is used to persist information about potentially crufty methods. This gem should happily
  work with AR 5.2, 6, and 6.1.
* MySQL - As of now, only MySQL is supported. PRs are welcome to add support for Postgres, etc.

## Development

This gem is _highly_ inspired by [PaperTrail](https://github.com/paper-trail-gem/paper_trail). What this means is that
the entire approach to development and a lot of testing setup and support code is essentially copy and pasted from
PaperTrail. A huge debt of gratitude is owed to the maintainers of PaperTrail. Thus, if anything below is too vague,
it'd probably be helpful to
see [what PaperTrail has to say about developing their gem](https://github.com/paper-trail-gem/paper_trail/blob/master/.github/CONTRIBUTING.md)
.

Anyhow, to get started:

```bash
gem install bundler
bundle
bundle exec appraisal install
bundle exec appraisal update # occasionally
```

Development may be a bit awkward because the test suite supports a few versions of Rails (5.2, 6, and 6.1) and contains
a dummy application that depends on MySQL.

Before running the tests you'll want to make sure you have a database.yml file:

```bash
cd spec/dummy_app
cp config/database.mysql.yml config/database.yml
```

Edit the database.yml as needed and fire up your MySQL server.

You can now run the test suite:

### Rails 5.2

bundle exec appraisal rails-5.2 rake

### Rails 6.0

bundle exec appraisal rails-6.0 rake

### Rails 6.1

bundle exec appraisal rails-6.1 rake

## Developing with Docker

A Docker / docker-compose environment is available to simplify development. Assuming you already have Docker installed, you can spin up a MySQL and open a bash console on a container with Ruby installed like this:

```bash
docker-compose run --rm ruby bash
```

The MySQL server has its port exposed as 13306. Note that the first time you spin up these containers it may take a moment for mysql to successfully spin up.

The gem's source is mapped to `/app`, which is also the working directory.

Once you have a bash console open, you can install dependencies with:

```bash
bundle install
bundle exec appraisal install
```

You can copy the provided MySQL DB config file to be the one to use in the test app:

```bash
cp spec/dummy_app/config/database.mysql.yml spec/dummy_app/config/database.yml
```

And now you should be able to run tests against whichever version of Rails you wish, like so:

```bash
bundle exec appraisal rails-6.1 rake
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dhughes/is_this_used.

## Inspirations

Large quantities of the approach taken to testing and general setup were gratuitously "borrowed"
from [PaperTrail](https://github.com/paper-trail-gem/paper_trail). Thank you!

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
