module V1
  module Users
    class UsersController < V1::Base

      content_type :json, "application/json"
      content_type :csv, "text/csv"
      content_type :txt, "text/plain"
      content_type :html, "text/html"

      default_format :json

      logger = Rails.logger

      resource :users do

        resource :password do
          desc 'Resets a user password'
          params do
            requires :email
          end
          post do
            @user = User.find_by_email!( params[:email] )
            @user.send_reset_password_instructions
            if @user.errors.empty?
              { :status => 'ok' }
            else
              { :status => 'error', :message => @user.errors.full_messages }
            end
          end

          desc 'Creates a new password'
          params do
            requires :reset_password_token
            requires :password
            requires :password_confirmation
          end
          put do
            resource = User.reset_password_by_token(params)
            if resource.errors.empty?
              { :status => 'ok' }
            else
              { :status => 'error', :message => resource.errors.full_messages }
            end
          end
        end

        resource :confirmations do
          desc "Resend the confirmation email"
          post do
            user = authenticate!
            user.send_confirmation_instructions
            present user, :with => V1::Users::Entity
          end
        end

        desc "Return complete list of users.  Optional search param."
        params do
          optional :t
        end
        get do
          if params[:t]
            @users = User.active.tagged_with(params[:t])
          elsif is_admin
            @users = User.all
          else
            @users = User.active
          end
          if is_admin
            present @users, with: V1::Users::Entity, type: 'authorized'
          else
            present @users, with: V1::Users::Entity
          end
        end

        # =======================================================================
        # 	Return lists of users by role
        # =======================================================================
        desc "Return list of causes"
        get 'role/cause' do
          @causes = User.where("role = 'cause'")
          present @causes, with: V1::Users::Entity
        end

        desc "Return list of businesses"
        get 'role/business' do
          @businesses = User.where(:role => 'business', :is_published => true)
          present @businesses, with: V1::Users::Entity
        end

        desc "Return list of individuals"
        get 'role/individual' do
          @individuals = User.where("role = 'individual'")
          present @individuals, with: V1::Users::Entity
        end

        # =======================================================================
        # 	Get single user (requires authentication)
        # =======================================================================
        desc "Return a single user"
        get ':id' do
          # authenticate!
          @user = User.find(params[:id])
          if (is_authenticated && can?(:read, @user)) || is_admin
            present @user, with: V1::Users::Entity, type: 'authorized'
          else
            present @user, with: V1::Users::Entity
          end
        end

        # =======================================================================
        # 	Update single user
        # =======================================================================
        desc "Update a single user"
        params do
          requires :id, type: Integer
          optional :first_name
          optional :last_name
          optional :email
          optional :password
          optional :password_confirmation
          optional :current_password
          optional :company_name
          optional :phone
          optional :street_address
          optional :city
          optional :state
          optional :country
          optional :zip
          optional :summary
          optional :description
          optional :website
          optional :tag_list
          optional :twitter
        end
        put ':id' do
          authenticate!
          @user = User.find(params[:id])
          can_or_die :update, @user
          # safe_params function is in the helpers.rb file
          update_user_params = safe_params(params).permit([:email,
                                                           :mailing_list_opt_in,
                                                           :password, :password_confirmation, :current_password,
                                                           :first_name, :last_name,
                                                           :company_name, :phone,
                                                           :street_address, :city, :state, :country, :zip,
                                                           :summary, :description, :website, :twitter,
                                                           (:is_activated if current_user.admin?),
                                                           ({ :campaign_list => [] } if current_user.admin?),
                                                           tag_list: []].compact )
          if @user.update_attributes(update_user_params) && /user\-.*@giveloco\.com/.match(@user.email)
            @user.confirm!
          end
          present @user, with: V1::Users::Entity
        end

        # =======================================================================
        # 	User image upload
        # =======================================================================
        desc "Upload a single user's Profile Picture"
        params do
          requires :id, type: Integer
          requires :profile_picture
          optional :route_info
        end
        post ':id/upload_image' do
          authenticate!
          upload_picture_params = safe_params(params).permit(:profile_picture)
          @user = User.find(params[:id])

          unless params[:profile_picture].blank?
            profile_picture = params[:profile_picture]

            attachment = {
                :filename => profile_picture[:filename],
                :type => profile_picture[:type],
                :headers => profile_picture[:head],
                :tempfile => profile_picture[:tempfile]
            }

            @user.update_attributes(upload_picture_params)
            @user.profile_picture = ActionDispatch::Http::UploadedFile.new(attachment)
            @user.save
          end

          if @user.errors.empty?
            present @user, with: V1::Users::Entity
          else
            status 422
            present @user.errors, with: V1::Errors
          end

        end

        # =======================================================================
        # 	Delete user's profile picture
        # =======================================================================
        desc "Delete a single user's Profile Picture"
        params do
          requires :id, type: Integer
        end
        delete ':id/delete_image' do
          authenticate!
          @user = User.find(params[:id])
          @user.profile_picture = nil
          @user.save
        end

        resource '/certificates' do
          desc 'Purchases a new gift certificate for an anonymous user'
          post do
            _params = safe_params(params)
                          .require(:newUser)
                          .permit(:email, :first_name, :last_name, :mailing_list_opt_in, :agree_to_tc,
                                  { :certificates_attributes => [:sponsorship_id, :amount, :serial_number] })
            logger.info("Creating a new gift certificate: #{_params.to_json}")
            begin
              @user = User.find_by_email(_params[:email])
              if (@user)
                @user.update_attributes! _params
              else
                @user = User.create(_params)
                @user.set_authentication_token
                @user.save!
              end
            rescue Exception => e
              logger.error("There was an error: #{e}")
              logger.error(e)
              raise e
            end
            logger.info("Successfully created a new certificate with id #{@user.certificates.first.id}")
            present @user, with: V1::Users::Entity, :type => 'authorized', :certificates => true
          end
        end

        resource '/sponsorships' do
          resource '/certificates' do
            resource '/csv' do
              desc 'Returns a CSV of all certificates'
              get do
                authenticate!
                can_or_die :index, Certificate
                @certificates = Certificate.order_by_date
                env['api.format'] = :csv
                header 'Content-Disposition', 'attachment; filename=certificates.csv'
                body @certificates.to_comma
              end
            end
          end
        end

        # =======================================================================
        # 	Return single user's transactions and tags (requires authentication)
        # =======================================================================
        segment '/:id' do

          resource '/certificates' do
            desc 'Returns the list of certificates purchased by this user'
            get do
              authenticate!
              can_or_die :read, Certificate, { :user_id => params[:id].to_i }
              @certificates = User.find(params[:id]).certificates
              present @certificates, :with => V1::Certificates::Entity
            end
          end

          resource '/sponsorships' do
            desc 'Returns a list of sponsorships for this business'
            get do
              @sponsorships = User.find(params[:id]).sponsorships
              present @sponsorships, :with => V1::Sponsorships::Entity
            end

            resource '/certificates' do
              desc 'Returns all of the certificates for this business'
              get do
                authenticate!
                @user = User.find(params[:id])
                can_or_die :read_purchased_certificates, @user
                @certificates = @user.purchased_certificates
                present @certificates, :with => V1::Certificates::Entity
              end

              resource '/csv' do
                desc 'returns a csv of the certificates for this business'
                get do
                  authenticate!
                  @user = User.find(params[:id])
                  can_or_die :read_purchased_certificates, @user
                  @certificates = @user.purchased_certificates
                  env['api.format'] = :csv
                  header 'Content-Disposition', 'attachment; filename=certificates.csv'
                  body @certificates.to_comma
                end

              end

            end

          end

          resource '/sponsors' do
            desc 'Returns the list of sponsorships for this cause'
            get do
              @sponsors = User.find(params[:id]).sponsors
              present @sponsors, :with => V1::Sponsorships::Entity
            end

            resource '/certificates' do
              desc 'Returns all of the gift certificates purchased for this cause'
              get do
                @certificates = User.find(params[:id]).sponsor_certificates
                present @certificates, :with => V1::Certificates::Entity
              end
            end
          end

          resource '/transactions' do
            desc "A list of certificates that have been purchased for this business"
            get do
              authenticate!
              @certificates = Certificate.for_business( current_user )
              present @certificates, with: V1::Certificates::Entity
            end
          end

          resource '/donations' do
            desc 'A list of certificates that donate to this cause'
            get do
              authenticate!
              @certificates = Certificate.for_cause( current_user )
              present @certificates, with: V1::Certificates::Entity
            end
          end

          resource '/transactions_created' do

            desc "Return list of user's CREATED Transactions"
            get do
              @created_transactions_list = User.find(params[:id]).transactions_created
              present @created_transactions_list, with: V1::Transactions::Entities
            end

            desc "Return a single transaction CREATED by this user"
            get '/:transaction_id' do
              @created_transaction = User.find(params[:id]).transactions_created.find(params[:transaction_id])
              present @created_transaction, with: V1::Transactions::Entities
            end
          end

          resource '/transactions_accepted' do

            desc "Return list of user's ACCEPTED Transactions"
            get do
              @accepted_transactions_list = User.find(params[:id]).transactions_accepted
              present @accepted_transactions_list, with: V1::Transactions::Entities
            end

            desc "Return a single transaction ACCEPTED by this user"
            get '/:transaction_id' do
              @accepted_transaction = User.find(params[:id]).transactions_accepted.find(params[:transaction_id])
              present @accepted_transaction, with: V1::Transactions::Entities
            end
          end

          resource '/tags' do
            desc "Return COMPLETE list of user's Tags"
            get do
              @tags = User.find(params[:id]).tag_counts_on(:tags)
            end
          end
        end

      end

    end # End Class

# Example: https://github.com/bloudraak/grape-sample-blog-api-with-entities/blob/master/app/api/blog/api.rb
  end
end
