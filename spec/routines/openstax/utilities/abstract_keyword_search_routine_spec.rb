require 'rails_helper'

module OpenStax
  module Utilities
    describe AbstractKeywordSearchRoutine do

      let!(:john_doe) { FactoryGirl.create :user, name: "John Doe",
                                           username: "doejohn",
                                           email: "john@doe.com" }

      let!(:jane_doe) { FactoryGirl.create :user, name: "Jane Doe",
                                           username: "doejane",
                                           email: "jane@doe.com" }

      let!(:jack_doe) { FactoryGirl.create :user, name: "Jack Doe",
                                           username: "doejack",
                                           email: "jack@doe.com" }

      before(:each) do
        100.times do
          FactoryGirl.create(:user)
        end
      end

      it 'returns the searched class' do
        expect(SearchUsers.search_class).to eq User
      end

      it "filters results based on one field" do
        items = SearchUsers.call('last_name:dOe').outputs[:items]

        expect(items).to include(john_doe)
        expect(items).to include(jane_doe)
        expect(items).to include(jack_doe)
        items.each do |item|
          expect(item.name.downcase).to match(/\A[\w]* doe[\w]*\z/i)
        end
      end

      it "filters results based on multiple fields" do
        items = SearchUsers.call('first_name:jOhN last_name:DoE').outputs[:items]

        expect(items).to include(john_doe)
        expect(items).not_to include(jane_doe)
        expect(items).not_to include(jack_doe)
        items.each do |item|
          expect(item.name).to match(/\Ajohn[\w]* doe[\w]*\z/i)
        end
      end

      it "filters results based on multiple keywords per field" do
        items = SearchUsers.call('first_name:JoHn,JaNe last_name:dOe').outputs[:items]

        expect(items).to include(john_doe)
        expect(items).to include(jane_doe)
        expect(items).not_to include(jack_doe)
        items.each do |item|
          expect(item.name).to match(/\A[john|jane][\w]* doe[\w]*\z/i)
        end
      end

      it "orders results by multiple fields in different directions" do
        items = SearchUsers.call('username:DoE', order_by: 'cReAtEd_At AsC, iD')
                          .outputs[:items]
        expect(items).to include(john_doe)
        expect(items).to include(jane_doe)
        expect(items).to include(jack_doe)
        john_index = items.index(john_doe)
        jane_index = items.index(jane_doe)
        jack_index = items.index(jack_doe)
        expect(jane_index).to be > john_index
        expect(jack_index).to be > jane_index
        items.each do |item|
          expect(item.username).to match(/\Adoe[\w]*\z/i)
        end

        items = SearchUsers.call('username:dOe', order_by: 'CrEaTeD_aT dEsC, Id DeSc')
                          .outputs[:items]
        expect(items).to include(john_doe)
        expect(items).to include(jane_doe)
        expect(items).to include(jack_doe)
        john_index = items.index(john_doe)
        jane_index = items.index(jane_doe)
        jack_index = items.index(jack_doe)
        expect(jane_index).to be < john_index
        expect(jack_index).to be < jane_index
        items.each do |item|
          expect(item.username).to match(/\Adoe[\w]*\z/i)
        end
      end

      it "paginates results" do
        all_items = SearchUsers.call('').outputs[:items].to_a

        items = SearchUsers.call('', per_page: 20).outputs[:items]
        expect(items.limit(nil).offset(nil).count).to eq all_items.count
        expect(items.limit(nil).offset(nil).to_a).to eq all_items
        expect(items.count).to eq 20
        expect(items.to_a).to eq all_items[0..19]

        for page in 1..5
          items = SearchUsers.call('', page: page, per_page: 20).outputs[:items]
          expect(items.limit(nil).offset(nil).count).to eq all_items.count
          expect(items.limit(nil).offset(nil).to_a).to eq all_items
          expect(items.count).to eq 20
          expect(items.to_a).to eq all_items.slice(20*(page-1), 20)
        end

        items = SearchUsers.call('', page: 1000, per_page: 20).outputs[:items]
        expect(items.limit(nil).offset(nil).count).to eq all_items.count
        expect(items.limit(nil).offset(nil).to_a).to eq all_items
        expect(items.count).to eq 0
        expect(items.to_a).to be_empty
      end

    end
  end
end
