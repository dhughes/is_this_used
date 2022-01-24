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
- `updated_at` - The last time this record was updated.

Looking at this, we can see that the `some_old_method` method has never been invoked. This is nice because it means that
you can track uses of methods without changing their behavior. A similar record is created for every method you annotate
with `is_this_used?`.

Assuming your production application eagerly loads classes, you should always have records for potentially crufty
methods, even if the class itself is never explicitly used.

So, having annotate the method, you can check this table after a while. If you see that there have been zero invocations
you have a reasonably good hint that the method may not actually be used. Of course, you should consider that there are
some processes that are not run frequently at all, so this gem isn't a panacea. Think before you delete!

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
  method invocation. You can potentially use this to figure out what other methods and blocks involved in calling the
  not-actually-crufty method.
- `occurrences` - This is the number of times the method has been invoked with exactly the same stack.
- `created_at` - The date/time we first saw this stack.
- `updated_at` - The last time this saw this stack.

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

The `IsThisUsed::PotentialCruftStack` model is handy for accessing this data.

### `IsThisUsed::PotentialCruft`

This is a model representing the potential cruft. You can use its `potential_cruft_stacks` to get a list of all of the
invocations of the method, if any.

### `IsThisUsed::PotentialCruftStack`

This is a model representing potential cruft stacks. Its `potential_cruft` method provides an association back to the
owning potentially-crufty method.

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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dhughes/is_this_used.

## Inspirations

Large quantities of the approach taken to testing and general setup were gratuitously "borrowed"
from [PaperTrail](https://github.com/paper-trail-gem/paper_trail). Thank you!

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
