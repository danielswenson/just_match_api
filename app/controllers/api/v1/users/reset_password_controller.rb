# frozen_string_literal: true
module Api
  module V1
    module Users
      class ResetPasswordController < BaseController
        before_action :require_promo_code, except: [:create]
        after_action :verify_authorized, only: []

        api :POST, '/users/reset-password/', 'Reset password'
        description 'Sends a reset password email to user.'
        error code: 422, desc: 'Unprocessable entity'
        param :data, Hash, desc: 'Top level key', required: true do
          param :attributes, Hash, desc: 'Reset password attributes', required: true do
            param :email_or_phone, String, desc: 'Email or phone', required: true
          end
        end
        example '# Response example
{}
'
        def create
          user = User.find_by_email_or_phone(email_or_phone)

          if user
            user.generate_one_time_token(:reset_password)
            user.save!
            ResetPasswordNotifier.call(user: user)
          end

          # Always render 202 accepted status, we don't want to increase the number of
          # places that exposes what emails are in the system
          render json: {}, status: :accepted
        end

        private

        def email_or_phone
          email_or_phone = jsonapi_params[:email_or_phone]
          return email_or_phone unless email_or_phone.blank?

          message = [
            'Param `email` is deprecated!',
            'Please use `email_or_phone` instead.'
          ].join(' ')
          ActiveSupport::Deprecation.warn(message)
          jsonapi_params[:email]
        end
      end
    end
  end
end
