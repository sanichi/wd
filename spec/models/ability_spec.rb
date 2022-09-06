require 'rails_helper'
require 'cancan/matchers'

describe Ability do
  subject(:ability) { Ability.new(user) }
  let(:user) { nil }

  context "blog" do
    let(:blogger) { create(:user, roles: ["blogger"]) }
    let(:finished) { create(:blog, user: [blogger, nil].sample, draft: false) }
    let(:draft) { create(:blog, user: [blogger, nil].sample, draft: true) }

    context "blogger" do
      let(:user) { create(:user, roles: ["blogger"]) }

      context "same user" do
        let(:his_blog) { create(:blog, user: user) }

        it { is_expected.to be_able_to(:read, his_blog) }
        it { is_expected.to be_able_to(:crud, his_blog) }
      end

      context "different or no user" do

        context "finished" do
          it { is_expected.to be_able_to(:read, finished) }
          it { is_expected.to_not be_able_to(:crud, finished) }
        end

        context "draft" do
          it { is_expected.to_not be_able_to(:read, draft) }
          it { is_expected.to_not be_able_to(:crud, draft) }
        end
      end
    end

    %w/librarian member guest/.each do |role|
      context role do
        let(:user) { role == "guest" ? Guest.new : create(:user, roles: [role]) }

        context "finished" do
          it { is_expected.to be_able_to(:read, finished) }
          it { is_expected.to_not be_able_to(:crud, finished) }
        end

        context "draft" do
          it { is_expected.to_not be_able_to(:read, draft) }
          it { is_expected.to_not be_able_to(:crud, draft) }
        end
      end
    end
  end

  context "game" do
    let(:blogger) { create(:user, roles: ["blogger"]) }
    let(:game) { create(:game, user: [blogger, nil].sample) }

    context "blogger" do
      let(:user) { create(:user, roles: ["blogger"]) }

      context "same user" do
        let(:his_game) { create(:game, user: user) }

        it { is_expected.to be_able_to(:read, his_game) }
        it { is_expected.to be_able_to(:crud, his_game) }
      end

      context "different or no user" do
        it { is_expected.to be_able_to(:read, game) }
        it { is_expected.to_not be_able_to(:crud, game) }
      end
    end

    %w/librarian member guest/.each do |role|
      context role do
        let(:user) { role == "guest" ? Guest.new : create(:user, roles: [role]) }

        it { is_expected.to be_able_to(:read, game) }
        it { is_expected.to_not be_able_to(:crud, game) }
      end
    end
  end

  context "book" do
    let(:book) { create(:book) }

    context "librarian" do
      let(:user) { create(:user, roles: ["librarian"]) }

      it { is_expected.to be_able_to(:read, book) }
      it { is_expected.to be_able_to(:crud, book) }
    end

    %w/blogger member guest/.each do |role|
      context role do
        let(:user) { role == "guest" ? Guest.new : create(:user, roles: [role]) }

        it { is_expected.to_not be_able_to(:read, book) }
        it { is_expected.to_not be_able_to(:crud, book) }
      end
    end
  end

  context "player" do

    %w/blogger librarian member guest/.each do |role|
      context role do
        let(:user) { role == "guest" ? Guest.new : create(:user, roles: [role]) }

        it { is_expected.to_not be_able_to(:read, Player) }
        it { is_expected.to_not be_able_to(:crud, Player) }
      end
    end
  end

  context "user" do

    %w/blogger librarian member/.each do |role|
      context role do
        let(:user) { create(:user, roles: [role]) }

        it { is_expected.to be_able_to(:index, User) }
        it { is_expected.to_not be_able_to(:show, user) }
        it { is_expected.to_not be_able_to(:crud, User) }
      end
    end

    context "guest" do
      let(:user) { Guest.new }

      it { is_expected.to_not be_able_to(:index, User) }
      it { is_expected.to_not be_able_to(:show, User) }
      it { is_expected.to_not be_able_to(:crud, User) }
    end
  end
end
