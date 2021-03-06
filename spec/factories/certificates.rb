# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :certificate do
    association :purchaser, :factory => :user
    sponsorship { FactoryGirl.create(:sponsorship, :status => :accepted) }
    donation_percentage "9.99"
    amount 9.99
    recipient "happyuser@fake.com"
    sequence(:serial_number) do |n|
      "#{n}-1234"
    end
  end
end
