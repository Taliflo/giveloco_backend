module V1
  module Sponsorships
    class Snapshot < Grape::Entity
      expose :id
      expose :business, :using => V1::Users::Snapshot
      expose :cause, :using => V1::Users::Snapshot
      expose :status
    end
  end
end
