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
      Flipside.send(:registered_flippables).clear
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
        define_user do
          flipside_entity
          flipside_display_as :name
        end

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

      it "raises on use when the class is not listed in Flipside.flippables" do
        define_user { flipside_entity }

        expect { Flipside.entity_classes }
          .to raise_error(Flipside::Error, "User must be listed in Flipside.flippables")
      end

      it "can be called before Flipside.flippables is set" do
        define_user { flipside_entity }
        Flipside.flippables = ["User"]

        expect(Flipside.entity_classes).to eq(["User"])
      end
    end

    describe ".flipside_search_by" do
      before { Flipside.flippables = ["User"] }

      let!(:john) { define_user { flipside_entity }.create!(name: "John Doe") }
      let!(:jane) { User.create!(name: "Jane Doe") }

      def search(query)
        Flipside.search_entity(class_name: "User", query:).map(&:object)
      end

      it "searches by id by default" do
        expect(search(jane.id)).to eq([jane])
      end

      it "searches with a block" do
        User.flipside_search_by { |str| where("name LIKE ?", "#{str}%") }

        expect(search("Ja")).to eq([jane])
      end

      it "searches with a class method" do
        User.class_eval do
          scope :named, ->(str) { where(name: str) }
          flipside_search_by :named
        end

        expect(search("John Doe")).to eq([john])
      end

      it "registers the class as an entity without flipside_entity" do
        define_user { flipside_search_by { |str| where(name: str) } }
        jim = User.create!(name: "Jim Doe")
        Entity.create!(feature:, flippable: jim)

        expect(Flipside.entity_classes).to eq(["User"])
        expect(search("Jim Doe")).to eq([jim])
        expect { jim.destroy }.to change(Entity, :count).by(-1)
      end

      it "keeps identified_by, whichever order the macros are called in" do
        define_user do
          flipside_search_by { |str| where(name: str) }
          flipside_identified_by :name
          flipside_display_as :name
          flipside_entity
        end
        User.create!(name: "Jim Doe")

        expect(Flipside.search_entity(class_name: "User", query: "Jim Doe").map(&:identifier))
          .to eq(["Jim Doe"])
      end

      it "requires either a method name or a block" do
        expect { User.flipside_search_by }.to raise_error(ArgumentError)
        expect { User.flipside_search_by(:named) { nil } }.to raise_error(ArgumentError)
      end
    end

    describe ".flipside_identified_by" do
      before { Flipside.flippables = ["User"] }

      it "identifies entities by the column" do
        define_user { flipside_identified_by :name }
        john = User.create!(name: "John Doe")

        expect(Flipside.entity_classes).to eq(["User"])
        expect(Flipside.search_entity(class_name: "User", query: "John Doe").map(&:identifier))
          .to eq(["John Doe"])
        expect(Flipside.find_entity(class_name: "User", identifier: "John Doe")).to eq(john)
        expect(Flipside.display_entity(john)).to eq("John Doe")
      end
    end

    describe ".flipside_display_as" do
      before { Flipside.flippables = ["User"] }

      def display(user)
        Flipside.display_entity(user)
      end

      it "displays the id by default" do
        define_user { flipside_entity }

        expect(display(User.new(id: 5, name: "John Doe"))).to eq(5)
      end

      it "displays with a block" do
        define_user { flipside_display_as { |user| "#{user.name} (#{user.id})" } }

        expect(display(User.new(id: 5, name: "John Doe"))).to eq("John Doe (5)")
      end

      it "displays with an instance method" do
        define_user { flipside_display_as :name }

        expect(display(User.new(name: "John Doe"))).to eq("John Doe")
      end

      it "is inherited by STI subclasses" do
        define_user { flipside_display_as :name }
        stub_const("Admin", Class.new(User))

        expect(display(Admin.new(name: "John Doe"))).to eq("John Doe")
      end

      it "registers an STI subclass of its own" do
        Flipside.flippables = ["User", "Admin"]
        define_user { flipside_display_as :name }
        stub_const("Admin", Class.new(User))
        Admin.flipside_display_as { |user| "Admin #{user.name}" }

        expect(Flipside.entity_classes).to eq(["User", "Admin"])
        expect(display(User.new(name: "John Doe"))).to eq("John Doe")
        expect(display(Admin.new(name: "John Doe"))).to eq("Admin John Doe")
      end
    end

    describe "registration" do
      before { Flipside.flippables = ["User", "Admin"] }

      it "starts over when the class is reloaded" do
        define_user do
          flipside_display_as :name
          flipside_identified_by :name
        end
        define_user { flipside_entity }

        expect(Flipside.display_entity(User.new(id: 5, name: "John Doe"))).to eq(5)
      end

      it "copies the inherited settings to an STI subclass calling a macro" do
        define_user do
          flipside_search_by { |str| where(name: str) }
          flipside_display_as :name
        end
        stub_const("Admin", Class.new(User))
        Admin.flipside_identified_by :name
        Admin.create!(name: "John Doe")

        results = Flipside.search_entity(class_name: "Admin", query: "John Doe")

        expect(results.map { [_1.display_as, _1.identifier] }).to eq([["John Doe", "John Doe"]])
        expect(Flipside.search_entity(class_name: "User", query: "John Doe").map(&:identifier))
          .to eq([User.first.id])
      end
    end

    describe "deprecated flipside_entity options" do
      before { Flipside.flippables = ["User"] }

      it "warns and still applies them" do
        expect(Flipside.deprecator).to receive(:warn).with(/flipside_identified_by/)
        define_user do
          flipside_entity search_by: :name, display_as: ->(user) { user.name.upcase }, identified_by: :name
        end
        john = User.create!(name: "John Doe")

        results = Flipside.search_entity(class_name: "User", query: "John Doe")

        expect(results.map(&:object)).to eq([john])
        expect(results.map(&:display_as)).to eq(["JOHN DOE"])
        expect(results.map(&:identifier)).to eq(["John Doe"])
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

    describe "Flipside.verify_flippables!" do
      it "passes when the list matches the classes using the macros" do
        Flipside.flippables = ["User"]
        define_user { flipside_role(:admin?) }

        expect { Flipside.verify_flippables! }.not_to raise_error
      end

      it "raises for a class using the macros that is not listed" do
        define_user { flipside_role(:admin?) }

        expect { Flipside.verify_flippables! }
          .to raise_error(Flipside::Error, "User must be listed in Flipside.flippables")
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
              flipside_entity
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
