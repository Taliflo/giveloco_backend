require 'rails_helper'

describe 'As an individual I want to search businesses and causes' do

  before(:each) do
    @sponsorships = create_list(:sponsorship, 10, :status => :accepted)
    @sponsorships.first.business.tag_list.add "test"
    @sponsorships.first.business.company_name = "Juju Jazz"
    @sponsorships.first.business.save!
    @sponsorships.last.business.tag_list.add 'foo'
    @sponsorships.last.business.save!
  end

  it 'should allow the user to search businesses by tag' do

    visit '/'
    click_link 'Explore'
    fill_in :search_businesses, :with => "laiwejfasliejf"
    expect(page).to_not have_content(@sponsorships.first.business.company_name)
    expect(page).to_not have_content(@sponsorships.last.business.company_name)
    fill_in :search_businesses, :with => "test"
    expect(page).to have_content(@sponsorships.first.business.company_name)
    expect(page).to_not have_content(@sponsorships.last.business.company_name)

  end

  it 'should allow the user to search businesses by name' do

    visit '/'
    click_link 'Explore'
    fill_in :search_businesses, :with => "laiwejfasliejf"
    expect(page).to_not have_content(@sponsorships.first.business.company_name)
    expect(page).to_not have_content(@sponsorships.last.business.company_name)
    fill_in :search_businesses, :with => "Juju"
    expect(page).to have_content(@sponsorships.first.business.company_name)
    expect(page).to_not have_content(@sponsorships.last.business.company_name)

  end

end