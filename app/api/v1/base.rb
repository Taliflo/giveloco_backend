class V1::Base < API::Root
	mount V1::Users::UsersController
	mount V1::Transactions::TransactionsController
end