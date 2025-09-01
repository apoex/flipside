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

### Defining Features

Features are created by running this (in a console or from code):
```ruby
Flipside.create(
  name: "MyFeature",
  description: "Some optional description about what this feature do"
)
```

By default features are turned off. If we would like it turned on from the get go we could pass in `enabled: true`.
```ruby
Flipside.create(name: "MyFeature", enabled: true)
```

Features can be active during a given period. Set `activated_at` and/or `deactivated_at` to define this period.
Note: A feature is always disabled outside of the active period.
Note: A nil value means that its active. I.e. `activated_at = nil` means active from the start, `deactivated_at = nil` means never deactivates.
```ruby
Flipside.create(
  name: "MyFeature",
  activated_at: 1.week.from_now,
  deactivated_at: 2.weeks.from_now
)
```

### Checking Feature Status

#### Globally

Check if a feature is enabled globally:

```ruby
Flipside.enabled? "MyFeature"
```

We can also check if a feature is disabled:
```ruby
Flipside.disabled? "MyFeature"
```

#### For a Specific Record

Check if a feature is enabled for a specific record (e.g. a user):

```ruby
Flipside.enabled? "MyFeature", user
```

We can also check multiple records. `.enabled?` will return `true` if any of them have the feature enabled:
```ruby
Flipside.enabled? "MyFeature", user, company, location
```

### Enabling features for specific records

Features can be enabled for a certain record, typically a certain user or organization. These records are called entities. To enable a feature for a given record use `.add_entity`:
```ruby
user = User.first
Flipside.enabled? "MyFeature", user # => false
Flipside.add_entity(name: "MyFeature", entity: user)
Flipside.enabled? "MyFeature", user # => true
```

Features can be enabled for records responding true to a certain method. This is called a "role". Given that User records have an admin? method. A feature can then be enabled
for all users who are admins, using the `.add_role` method:
```ruby
user1 = User.new(admin: false)
user2 = User.new(admin: true)
Flipside.add_role(
  name: "MyFeature",
  class_name: "User",
  method_name: :admin?
)
Flipside.enabled? "MyFeature", user1 # => false
Flipside.enabled? "MyFeature", user2 # => true
Flipside.enabled? "MyFeature", user1, user2 # => true, enabled for at least one.
```


## UI
Flipside comes with a Roda web ui to mange feature flags. To mount this roda app in Rails add the following to your routes.rb file.
```ruby
mount Flipside::Web, at: '/flipside'
```
Note: you probably want to wrap this inside a constraints block to provide some authentication.

![UI](/features.png)


### Configuration

Flipside can be configured by calling some class methods on `Flipside` (see below).

`ui_back_path` is used to set a path to return to from the Flipside UI. If this is set, then the UI shows a "Back" button,
targeting this path/url. By default no back button is shown.


If `create_missing_features` is set to true, then features will automatically be created, whenever a check for an unknown feature is done.
This can be a convenient way of makes features "show up" in the Flipside UI. However, the description will not reveal much about what this features does.
(it will simply point to the place in the code where this check was done). So these features should be manually updated with a better description.
By default, features are not added and code like `Flipside.enabled? "Some unknown feature"` will simply return `false`.

`default_object` can be used to avoid the need to always pass in a record when checking if a feature is enabled. For example, say that we
always want to check if a feature is enabled for the currently logged in user (`Current.user`). Then we might add this configuration:
```ruby
Flipside.default_object = -> { Current.user }
```
Now we can check if a feature is enabled without needing to pass in `Current.user`:
```ruby
# With `default_object` set then all we need is this
Flipside.enabled? :some_feature

# Which will be the same as
Flipside.enabled? :some_feature, Current.user

# Note: if we do pass in an argument, then `default_object ` will not be used:
Flipside.enabled? :some_feature, Current.company # check current company instead of user.
```


Typically this configuration should be declared in an initializer file.

```ruby
# config/initializers/flipside.rb
require 'flipside'

Flipside.ui_back_path = "/"
Flipside.create_missing_features = true
Flipside.default_object = -> { Current.user }
```

#### Entities

Entities can be added to a feature by searching for records.

![Add an entity](/add_entity.png)

To make this work, some configuration is required. Use the class method `Flipside.register_entity` for this.
```ruby
Flipside.register_entity(
  class_name: "User",
  search_by: :name,
  display_as: :name,
  identified_by: :id
)
```

The `.register_entity` method should be called once for each class that may be used as a feature enabler.
The `search_by` keyword argument, which may be a `Symbol` or a `Proc`, dictates how records are found from searching in the ui.
When a `Symbol` is given, e.g. `:name`, then entities with an exact match on the corresponding attribute are returned. I.e. `User.where(name: query)`.
When a `Proc` is given, then this `Proc` is called with the search string and is expected to return an object responding to `to_a` (e.g. an AR collection).
This gives us the flexibility to decide how to search for entities. For example, to search for users with matching first name or last name or an email
starting with _query_, something like this could be used.
```ruby
Flipside.register_entity(
  class_name: "User",
  search_by: ->(str) { User.where("lower(first_name) = :name OR lower(last_name) = :name or email LIKE :str", name: str.downcase, str: "#{str}%") },
)

```

The `identified_by` keyword argument, sets the column used as primary key for the corresponding table. This defaults to `:id` and typically does need to be change.
Currently composite keys are not supported.

The `display_as` keyword argument, is used to configure how these entities show up in the combobox. When set to a `Symbol`, then this value is sent to the corresponding entity.
For example, given the following setup. Users will be displayed with first name and last name:
```ruby
class User < ApplicationRecord
  def name
    [first_name, last_name].compact.map(&:capitalize).join(" ")
  end
end

Flipside.register_entity(
  class_name: "User",
  display_as: :name,
)
```

When a `Proc` is given, then it is expected to take an entity as input and return a string used for displaying the entity. The config above could then instead be done using:
```ruby
Flipside.register_entity(
  class_name: "User",
  display_as: ->(user) { [user.first_name, user.last_name].compact.map(&:capitalize).join(" ") }
)
```

#### Roles

Features can be enabled for certain roles, by searching for roles (by method name).

![Add a role](/add_role.png)

This is configured by calling the class method `Flipside.register_role` for each role to be added.
Note a role consists of a class and a corresponding instance method.
```ruby
Flipside.register_role(class_name: "User", method_name: :admin?)
Flipside.register_role(class_name: "User", method_name: :awesome?)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/apoex/flipside.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
