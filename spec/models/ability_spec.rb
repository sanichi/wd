require 'rails_helper'
require 'cancan/matchers'

describe Ability do
  subject(:ability) { Ability.new(user) }
  let(:user) { nil }

  context "blogger" do
    let(:user) { create(:user, roles: ["blogger"]) }

    context "blog" do

      context "same user" do
        let(:blog) { create(:blog, user: user) }

        it { is_expected.to be_able_to(:read, blog) }
        it { is_expected.to be_able_to(:crud, blog) }
      end

      context "different or no user" do
        let(:blogger) { create(:user, roles: ["blogger"]) }

        context "finished" do
          let(:blog) { create(:blog, user: [blogger, nil].sample, draft: false) }

          it { is_expected.to be_able_to(:read, blog) }
          it { is_expected.to_not be_able_to(:crud, blog) }
        end

        context "draft" do
          let(:blog) { create(:blog, user: [blogger, nil].sample, draft: true) }

          it { is_expected.to_not be_able_to(:read, blog) }
          it { is_expected.to_not be_able_to(:crud, blog) }
        end
      end
    end

    context "user" do
      it { is_expected.to be_able_to(:index, User) }
      it { is_expected.to_not be_able_to(:show, user) }
      it { is_expected.to_not be_able_to(:crud, user) }
    end
  end

  context "member" do
    let(:user) { create(:user, roles: ["member"]) }

    context "blog" do
      let(:blogger) { create(:user, roles: ["blogger"]) }

      context "finished" do
        let(:blog) { create(:blog, user: [blogger, nil].sample, draft: false) }

        it { is_expected.to be_able_to(:read, blog) }
        it { is_expected.to_not be_able_to(:crud, blog) }
      end

      context "draft" do
        let(:blog) { create(:blog, user: [blogger, nil].sample, draft: true) }

        it { is_expected.to_not be_able_to(:read, blog) }
        it { is_expected.to_not be_able_to(:crud, blog) }
      end
    end

    context "user" do
      it { is_expected.to be_able_to(:index, User) }
      it { is_expected.to_not be_able_to(:show, user) }
      it { is_expected.to_not be_able_to(:crud, user) }
    end
  end

  context "guest" do
    let(:user) { Guest.new }

    context "blog" do
      let(:blogger) { create(:user, roles: ["blogger"]) }

      context "finished" do
        let(:blog) { create(:blog, user: [blogger, nil].sample, draft: false) }

        it { is_expected.to be_able_to(:read, blog) }
        it { is_expected.to_not be_able_to(:crud, blog) }
      end

      context "draft" do
        let(:blog) { create(:blog, user: [blogger, nil].sample, draft: true) }

        it { is_expected.to_not be_able_to(:read, blog) }
        it { is_expected.to_not be_able_to(:crud, blog) }
      end
    end

    context "user" do
      let(:other) { create(:user) }

      it { is_expected.to_not be_able_to(:index, User) }
      it { is_expected.to_not be_able_to(:show, other) }
      it { is_expected.to_not be_able_to(:crud, other) }
    end
  end
end
