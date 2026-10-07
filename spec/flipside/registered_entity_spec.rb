# frozen_string_literal: true

require "flipside"

module Flipside
  RSpec.describe RegisteredEntity do
    let(:user_class) do
      Class.new(ActiveRecord::Base) do
      end
    end

    before do
      stub_const("User", user_class)
      ActiveRecord::Base.connection.create_table :users, force: true do |t|
        t.string(:name)
        t.string(:email)
      end
      ActiveRecord::Base.connection.clear_cache!
    end

    after do
      ActiveRecord::Base.connection.drop_table(:users, if_exists: true)
    end

    before do
      User.create(name: "foo", email: "foo@example.com")
      User.create(name: "bar", email: "bar@example.com")
    end

    it "can search and show an entity by method name" do
      User.scope(:by_email, ->(str) { where(email: str) })
      registered_entity = RegisteredEntity.new(
        class_name: "User",
        search_by: :by_email,
        display_as: :email,
        identified_by: :email
      )

      result = registered_entity.search("bar@example.com")

      expect(result.first.identifier).to eq("bar@example.com")
      expect(result.first.display_as).to eq("bar@example.com")
    end

    it "runs a search block in the context of the class" do
      registered_entity = RegisteredEntity.new(
        class_name: "User",
        search_by: ->(str) { where(name: str) }
      )

      expect(registered_entity.search("foo").map(&:object)).to eq(User.where(name: "foo").to_a)
    end

    it "searches by identified_by by default" do
      registered_entity = RegisteredEntity.new(class_name: "User", identified_by: :email)

      expect(registered_entity.search("foo@example.com").map(&:display_as)).to eq(["foo@example.com"])
    end

    it "turns a column name into a search block for the deprecated options" do
      registered_entity = RegisteredEntity.new(
        class_name: "User",
        search_by: RegisteredEntity.column_search(:email)
      )

      expect(registered_entity.search("bar@example.com").map(&:object).map(&:name)).to eq(["bar"])
    end

    it "can search an entity by proc" do
      registered_entity = RegisteredEntity.new(
        class_name: "User",
        search_by: ->(str) { User.where(name: str) },
        identified_by: :email,
        display_as: ->(user) { "#{user.name} (#{user.email})" }
      )

      result = registered_entity.search("bar")

      expect(result.first.display_as).to eq("bar (bar@example.com)")
      expect(result.first.identifier).to eq("bar@example.com")
    end

    it "can find an entity by identifier" do
      user = User.create(name: "baz", email: "baz@example.com")

      registered_entity = RegisteredEntity.new(
        class_name: "User",
        identified_by: :id
      )

      result = registered_entity.find(user.id)

      expect(result.id).to eq(user.id)
      expect(result.email).to eq("baz@example.com")
    end
  end
end
