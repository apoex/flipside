# Flipside

**Flipside** is a gem for managing feature flags in your Rails applications.

---

## Features

- enable or disable features globally
- enable features for specific records (e.g. users, organizations)
- enabled features for objects responding `true` to a certain method
- Setting a start and end time for when the feature is active

---

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add flipside

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install flipside

Then run 

    $ rails generate flipside:install

This will create a migration file. Run the migration, to add the flipside tables

    $ rails db:migrate

## Usage

1. Defining Features

Features are created by running this (in a console or from code):
```ruby
Flipside::Feature.create(
  name: "MyFeature",
  description: "Some optional description about what this feature do"
)
```

By default features are turned off. If you would like it turned on from the beginning you could pass in `enabled: true`.
```ruby
Flipside::Feature.create(name: "MyFeature", enabled: true)
```

Features can be active during a given period. Set `activated_at` and/or `deactivated_at` to define this period.
Note: A feature is always disabled outside of the active period.
```ruby
Flipside::Feature.create(
  name: "MyFeature",
  activated_at: 1.week.from_now,
  deactivated_at: 2.weeks.from_now
)
```

Features can be enabled for a certain record, typically a certain record or organization. This records are called entities. To enable a feature for a given record use.
```ruby
user = User.first
Flipside.enabled? user # => false
Flipside.add_entity(name: "MyFeature", user)
Flipside.enabled? user # => true
```

Features can be enabled for records responding true to a certain method. This is called a "role". Given that User records have an admin? method. A feature can then be enabled
for all users how are admins.
```ruby
user1 = User.new(admin: false)
user2 = User.new(admin: true)
Flipside.add_role(
  name: "MyFeature",
  class_name: "User",
  method_name: :admin?
)
Flipside.enabled? user1 # => false
Flipside.enabled? user2 # => true
```


2. Checking Feature Status

#### Globally

Check if a feature is enabled globally:

```ruby
Flipside.enabled? "MyFeature"
```

#### For a Specific Record

Check if a feature is enabled for a specific record (e.g. a user):

```ruby
Flipside.enabled? "MyFeature", user
```

## UI
Flipside comes with a sinatra web ui to mange feature flags. To mount this sinatra app in Rails add the following to your routes.rb file.
```ruby
mount Flipside::Web, at: '/flipside'
```

Note: you also probably want to wrap this inside a constraints block to provide some authentication.



### Configuration

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[sammyhenningsson]/flipside.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
