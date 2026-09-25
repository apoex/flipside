# frozen_string_literal: true

require "tmpdir"

module Flipside
  RSpec.describe Flippable, type: :model do
    let(:feature) { Feature.create!(name: "some_feature") }

    before do
      ActiveRecord::Base.connection.create_table :users, force: true do |t|
        t.string(:name)
      end
    end

    after do
      ActiveRecord::Base.connection.drop_table(:users, if_exists: true)
      Flipside.flippables = []
      Flipside.send(:registered_entities).clear
      Flipside.send(:registered_roles).clear
    end

    def define_user(&block)
      stub_const("User", Class.new(ActiveRecord::Base))
      User.include(Flippable)
      User.class_eval(&block) if block
      User
    end

    describe ".flipside_entity" do
      it "registers the class as an entity" do
        Flipside.flippables = ["User"]
        define_user { flipside_entity(display_as: :name) }

        expect(Flipside.entity_classes).to eq(["User"])
        expect(Flipside.display_entity(User.new(name: "John Doe"))).to eq("John Doe")
      end

      it "removes the entities of a destroyed record" do
        Flipside.flippables = ["User"]
        define_user { flipside_entity }
        user = User.create!(name: "John Doe")
        other_user = User.create!(name: "Jane Doe")
        Entity.create!(feature:, flippable: user)
        other_entity = Entity.create!(feature:, flippable: other_user)

        user.destroy

        expect(Entity.all).to eq([other_entity])
      end

      it "raises when the class is not listed in Flipside.flippables" do
        expect { define_user { flipside_entity } }
          .to raise_error(Flipside::Error, "User must be listed in Flipside.flippables")
      end
    end

    describe ".flipside_role" do
      it "registers the role" do
        Flipside.flippables = ["User"]
        define_user { flipside_role(:admin?, display_as: "Admin") }

        expect(Flipside.role_classes).to eq(["User"])
        expect(Flipside.search_role(class_name: "User", query: "adm").map(&:display_as))
          .to eq(["Admin"])
      end
    end

    it "registers without deprecation warnings" do
      expect(Flipside.deprecator).not_to receive(:warn)
      Flipside.flippables = ["User"]

      define_user do
        flipside_entity
        flipside_role(:admin?)
      end
    end

    describe "loading listed classes" do
      around do |example|
        Dir.mktmpdir do |dir|
          path = File.join(dir, "widget.rb")
          File.write(path, <<~RUBY)
            class Widget < ActiveRecord::Base
              self.table_name = "users"
              include Flipside::Flippable
              flipside_entity display_as: :name
            end
          RUBY
          Object.autoload(:Widget, path)
          example.run
        ensure
          Object.send(:remove_const, :Widget) if Object.const_defined?(:Widget, false)
        end
      end

      it "loads a listed class that has not been loaded yet" do
        Flipside.flippables = ["Widget"]

        expect(Object.autoload?(:Widget)).not_to be_nil
        expect(Flipside.entity_classes).to eq(["Widget"])
      end

      it "raises when a listed class registers nothing" do
        Flipside.flippables = ["User"]
        define_user

        expect { Flipside.entity_classes }.to raise_error(Flipside::Error, /calls neither/)
      end
    end
  end
end
