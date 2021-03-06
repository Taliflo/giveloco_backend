require 'rails_helper'

describe 'As an admin I want to manipulate the campaign tags for a business or cause' do

  before(:each) do
    @admin = create(:admin)
    @b = create(:business)
    @b.campaign_list.add 'testing'
    @b.save!
    @s = create(:sponsorship, :business => @b, :status => :accepted)
  end

  it 'should allow the admin to see all tags' do
    login(@admin)
    expect(page).to have_content(@b.company_name)
    expect(page).to have_content('testing')
    click_link 'testing'
    expect(page).to have_content('Explore Businesses')
    expect(page).to have_content(@b.company_name)
  end

  it 'should allow the admin to add tags' do

    login(@admin)
    expect(page).to have_content(@b.company_name)
    find(".user-actions a.dropdown-toggle").click
    click_link 'Edit Profile'
    expect(page).to have_content('Editing')
    find('#userCampaigns input').set "foobar,"
    find('#userCampaigns input').set " "
    expect(page).to have_content('foobar')
    click_link_or_button 'Save Changes'
    expect(page).to have_content('Your account information was successfully updated')
    expect(page).to have_content('foobar')

  end

end