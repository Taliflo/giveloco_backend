class V1::Base < API::Root
  include V1::Defaults
  mount V1::Certificates::CertificatesController
	mount V1::Tags::TagsController
	mount V1::Users::UsersController
  mount V1::Sponsorships::SponsorshipsController
end