require 'rails_helper'

describe 'As the admin I want to update sponsorship status' do

  before(:each) do
    assert_front_end_up
    @admin = create(:admin)
    @s = create(:sponsorship, :status => :pending)
  end

  it 'should allow the admin to accept' do
    login(@admin)
    open_sponsorships
    expect(find('tr.sponsorship')).to have_content('pending')
    find('tr.sponsorship .user-actions a.dropdown-toggle').click
    click_link 'Accept'
    expect(find('tr.sponsorship')).to have_content('accepted')
  end

  it 'should allow the admin to cancel' do
    login(@admin)
    open_sponsorships
    expect(find('tr.sponsorship')).to have_content('pending')
    find('tr.sponsorship .user-actions a.dropdown-toggle').click
    click_link 'Cancel'
    expect(find('tr.sponsorship')).to have_content('cancelled')
  end

end