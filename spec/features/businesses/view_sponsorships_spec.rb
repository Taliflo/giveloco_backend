require 'rails_helper'

describe 'As a business I want to view my list of sponsorships' do

  include Support::Auth

  before(:each) do
    assert_front_end_up
    @b = create(:business)
    @c = create(:cause)
    @s = create(:sponsorship, :business => @b, :cause => @c)
  end

  it 'should display a list of accepted sponsorships' do
    login(@b)
    expect(page).to have_content(@b.company_name)
    expect(page).to have_content(@c.company_name)
  end

end