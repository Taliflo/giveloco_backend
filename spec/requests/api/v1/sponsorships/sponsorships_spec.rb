require 'rails_helper'

describe V1::Sponsorships::SponsorshipsController do

  before(:each) do
    @admin = create(:admin)
    @business = create(:business)
    @cause = create(:cause)
  end

  def expect_admin_email_with_subject(subject)
    last_mail = ActionMailer::Base.deliveries.last
    expect( last_mail.subject ).to eq(subject)
    expect( last_mail.to ).to eq([User.where(:role => 'admin').first.email])
  end

  describe 'GET /v1/sponsorships' do

    before(:each) do
      @s = create(:sponsorship)
    end

    it 'should allow the admin to access all sponsorships' do
      get '/v1/sponsorships', {}, auth_session(@admin)
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
    end

  end

  describe 'DELETE /v1/sponsorships' do

    before(:each) do
      @s = create(:sponsorship)
    end

    it 'should work' do
      delete "/v1/sponsorships/#{@s.id}", {}, auth_session(@admin)
      expect(response.status).to eq(200)
    end

  end

  describe 'POST /v1/sponsorships' do

    let(:post_params) {
      {
          :business_id => @business.id,
          :cause_id => @cause.id
      }
    }

    def post_with_user(user)
      post '/v1/sponsorships', post_params, auth_session(user)
    end

    it 'should not allow a business to request a sponsorship' do
      create_list(:sponsorship, Sponsorship::MAX_FAILED_REQUESTS - 1, :business => @business)
      post_with_user(@business)
      expect( response.status ).to eq(201)
    end

    it 'should not allow a business to request a sponsorship while one is pending' do
      s = create(:sponsorship, :business => @business, :cause => @cause)
      post_with_user(@business)
      expect( response.status ).to eq(422)
    end

    it 'should allow a business to re-request a sponsorship if the previous ones were cancelled' do
      s = create(:sponsorship, :business => @business, :cause => @cause, :status => Sponsorship.statuses[:cancelled])
      post_with_user(@business)
      expect( response.status ).to eq(201)
    end

    it "should prevent a business from requesting sponsorship when it has been cancelled #{Sponsorship::MAX_FAILED_REQUESTS} times" do
      s = create_list(:sponsorship, Sponsorship::MAX_FAILED_REQUESTS, :business => @business, :cause => @cause, :status => Sponsorship.statuses[:cancelled])
      post_with_user(@business)
      expect( response.status ).to eq(422)
      expect( @business.sponsorships.count ).to eq(Sponsorship::MAX_FAILED_REQUESTS)
    end

    it 'should allow an admin to request a sponsorship' do
      post_with_user(@admin)
      expect( response.status ).to eq(201)
      s = Sponsorship.last
      json = JSON.parse(response.body)
      expect( json['id'] ).to eq(s.id)
    end

    it 'should prevent anonymous sponsorship request' do
       post '/v1/sponsorships', post_params
      expect( response.status ).to eq(401)
    end

    it 'should prevent anybody from sponsoring' do
      post '/v1/sponsorships', post_params, auth_session( create(:business) )
      expect( response.status ).to eq(403)
    end

    describe 'Exception scenarios' do

      it 'Should prevent the business from having more than 3 sponsorships' do
        pending "limit on the number of sponsorships a business can have"
        create_list(:sponsorship, Sponsorship::MAX_SPONSORED_CAUSES, :business => @business)
        post '/v1/sponsorships', post_params, auth_session(@admin)
        expect( response.status ).to eq(422)
        expect( User.find(@business.id).causes.size ).to eq(Sponsorship::MAX_SPONSORED_CAUSES)

      end

    end

    describe 'PUT /v1/sponsorships/:id/resolve' do

      before(:each) do
        @s = create(:sponsorship, :business => @business, :cause => @cause, :status => :pending)
      end

      def resolve(sponsorship, status, user)
        put "/v1/sponsorships/#{sponsorship.id}/resolve", { :status => status }, auth_session(user)
      end

      def cancel(sponsorship, user)
        resolve(sponsorship, 'cancelled', user)
      end

      def accept(sponsorship, user)
        resolve(sponsorship, 'accepted', user)
      end

      it 'should allow admins to accept sponsorships' do
        accept(@s, @admin)
        expect(Sponsorship.find(@s.id).accepted?).to eq(true)
      end

      it 'should allow admins to cancel sponsorships' do
        cancel(@s, @admin)
        expect(Sponsorship.find(@s.id).cancelled?).to eq(true)
      end

      it 'should not allow anyone to accept' do
        accept(@s, nil)
        expect(Sponsorship.find(@s.id).pending?).to eq(true)
      end

      it 'should not allow the business to accept' do
        accept(@s, @s.business)
        expect(Sponsorship.find(@s.id).pending?).to eq(true)
      end

      it 'should not allow the cause to accept' do
        accept(@s, @s.cause)
        expect(Sponsorship.find(@s.id).pending?).to eq(true)
      end


    end

  end

end