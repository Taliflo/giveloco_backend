require 'rails_helper'

describe V1::Users::UsersController do

  include Support::Auth

  describe 'GET /v1/users/role/cause' do

    it 'should not return anything' do
      get '/v1/users/role/cause'
      expect( JSON.parse(response.body).size ).to eq(0)
    end

    it 'should return all the causes' do

      @businesses = create_list(:business, 3)
      @causes = create_list(:cause, 4)

      get '/v1/users/role/cause'
      expect( response.status ).to eq(200)
      resp = JSON.parse(response.body)
      expect( resp.size ).to eq(4)

      expect( resp[0]['id'] ).to eq(@causes[0].id)
      expect( resp[1]['id'] ).to eq(@causes[1].id)
      expect( resp[2]['id'] ).to eq(@causes[2].id)
      expect( resp[3]['id'] ).to eq(@causes[3].id)


    end

  end

  describe 'PUT /v1/users/:id' do

    before(:each) do
      @b = create(:business, :is_activated => false)
      @admin = create(:admin)
    end

    it 'should allow users to update their own profile' do
      put "/v1/users/#{@b.id}", {
          :first_name => 'foo'
      }, auth_session(@b)
      expect( User.find(@b.id).first_name ).to eq('foo')
    end

    it 'should not allow users to update their active/inactive state' do
      put "/v1/users/#{@b.id}", {
          :is_activated => true
      }, auth_session(@b)
      expect( User.find(@b.id).is_activated ).to eq(false)
    end

    it 'should allow admins to update profiles and activate / deactive them' do
      put "/v1/users/#{@b.id}", {
          :is_activated => true
      }, auth_session(@admin)
      expect( User.find(@b.id).is_activated ).to eq(true)
    end

    describe 'exception scenarios' do

      it 'should not allow anybody to edit anybodys profile' do

        put "/v1/users/#{@b.id}", {
            :first_name => 'TomatoWasher'
        }, auth_session( create(:business) )

        expect( response.status ).to eq(403)
        expect( User.find(@b.id).first_name ).to_not eq('TomatoWasher')

      end

    end

  end

end