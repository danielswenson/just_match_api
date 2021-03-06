# frozen_string_literal: true

module Api
  module V1
    class BaseController < ::Api::BaseController
      resource_description do
        api_version '1.0'
        app_info <<-DOCDESCRIPTION
          # JustMatch API - v1.0 <a href="http://jsonapi.org/"><svg xmlns="http://www.w3.org/2000/svg" style="font-weight:normal;" width="90" height="20"><linearGradient id="b" x2="0" y2="100%"><stop offset="0" stop-color="#bbb" stop-opacity=".1"/><stop offset="1" stop-opacity=".1"/></linearGradient><mask id="a"><rect width="90" height="20" rx="3" fill="#fff"/></mask><g mask="url(#a)"><path fill="#555" d="M0 0h63v20H0z"/><path fill="#9f9f9f" d="M63 0h27v20H63z"/><path fill="url(#b)" d="M0 0h90v20H0z"/></g><g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="11"><text x="31.5" y="15" fill="#010101" fill-opacity=".3">JSON API</text><text x="31.5" y="14">JSON API</text><text x="75.5" y="15" fill="#010101" fill-opacity=".3">1.0</text><text x="75.5" y="14">1.0</text></g></svg></a>

          ---

          The API follows the [JSON API 1.0](http://jsonapi.org) specification.

          ---

          ### Headers

          __Content-Type__

          The correct Content-Type is:

          `Content-Type: application/vnd.api+json`

          Please note that the correct Content-Type isn't standard. See the specification at [jsosnapi.org/format](http://jsonapi.org/format/#content-negotiation-clients).

          __Locale__

          `X-API-LOCALE: en` is used to specify current locale, valid locales are #{I18n.available_locales.map { |locale| "`#{locale}`" }.join(', ')}

          __Authorization__

          `Authorization: Token token=XXXYYYZZZ`

          __Admin__

          `X-API-ACT-AS-USER` an admin can "act as" a user by sending this header.

          ---

          ### Authorization

          There are two was of passing an authorization token, in HTTP-header or as an URL-paramter. The preferred method is HTTP-header.

          Pass the authorization token in HTTP-header:

          `Authorization: Token token=XXXYYYZZZ`

          Pass the authorization token as an URL-paramter, `auth_token`:

          `https://api.justarrived.se/api/v1/users/1?auth_token=XXXYYYZZZ`

          ---

          ## HTTP Codes

          ### Success

          Status      | Name                  | Comment
          ------------|:----------------------|:----------------------------------------------------------------------------------------|
          200         | OK                    | Everything went well.                                                                   |
          201         | Created               | Resource created.                                                                       |
          202         | Accepted              | All good, but we're gonna keep working. For example when a password reset is requested. |
          204         | No content            | We got nothing to say, but everythings seems fine. |

          ### Error

          Status      | Name                  | Comment
          ------------|:----------------------|:--------------------------------------------------------------------------------------------------|
          400         | Bad Request           | Bad JSON format etc, essentially its your fault.                                                  |
          401         | Unauthorized          | Please login.. To see if your authorized.                                                         |
          403         | Forbidden             | We know who you are, but you're not allowed to do this.                                           |
          404         | Not found             | Couldn't find that resource, its either been removed, or you, the client, have sent the wrong ID. |
          422         | Unprocessable entity  | Validation error, typically forms, please check the data sent/prompt the user to fix them.        |
          429         | Rate limited          | Slow down a bit, you're making too many requests in too little time                               |
          500         | Internal server error | The server screwed up, but don't worry we're on it.                                               |

          ---

          ### Example job scenario

          Action | Request |
          ------------------------------------------------------------------------------------------|:-------------------------------------------------------------|
          1. Owner creates job                                                                      | `POST /api/v1/jobs/`                                         |
          2. User can apply to a job by creating a job user                                         | `POST /api/v1/jobs/:job_id/users/`                           |
          3. Owner can accept a user                                                                | `POST /api/v1/jobs/:job_id/users/:job_user_id/acceptances`   |
          4. User confirms that they will perform                                                   | `POST /api/v1/jobs/:job_id/users/:job_user_id/confirmations` |
          5. Check if user has added bank account details (frilans_finans_payment_details: `true`)  | `GET  /api/v1/users/:id`                                      |
          5.1 If `false` then add bank account details                                              | `POST /api/v1/users/:user_id/frilans-finans`
          6. Owner creates invoice                                                                  | `POST /api/v1/jobs/:job_id/users/:job_user_id/invoices`      |
          7. (optional) User confirms that they've performed the job                                | `POST /api/v1/jobs/:job_id/users/:job_user_id/performed`     |

          ---

          ### Examples

          __Jobs__

          Get a list of available jobs

              #{Doxxer.curl_for(name: 'jobs')}

          Get a single job

              #{Doxxer.curl_for(name: 'jobs', id: 1)}

          __Skills__

          Get a list of skills

              #{Doxxer.curl_for(name: 'skills')}

          Get a single skill

              #{Doxxer.curl_for(name: 'skills', id: 1)}

          ### Locale

          Set the locale

              #{Doxxer.curl_for(name: 'users', id: 1, locale: true, join_with: " \\
                     ")}

          ### Authentication

          Pass the authorization token as a HTTP header

              #{Doxxer.curl_for(name: 'users', id: 1, auth: true, join_with: " \\
                     ")}

          ## Errors

          All errors returned by the API should conform to the [JSONAPI spec](http://jsonapi.org/format/#error-objects).

          Errors can be both general and specific (i.e validation error for an attribute).

          :warning: The errors below are not intended to be a comprehensive list of all errors that the API can return. It lists the most important ones and tries to show the format of the errors.

          ## Global errors

          Below is a list of a few global/general errors that can be returned from the API.
          Note that global/general errors lack a `source/pointer` attribute, since they don't belong to any specific attribute.


          ### 401 - Login Required

              #{JSON.parse(Doxxer.read_example_file(:login_required)).to_json}

          ### 401 - Token Expired

              #{JSON.parse(Doxxer.read_example_file(:token_expired)).to_json}

          ### 403 - Invalid Credentials

              #{JSON.parse(Doxxer.read_example_file(:invalid_credentials)).to_json}

          ### 404 - Not Found

              #{JSON.parse(Doxxer.read_example_file(:not_found)).to_json}

          ## Resource errors

          Below is a list of a few resource errors that can be returned from the API.
          Note that errors have a `source/pointer` attribute, since errors belong to a specific attribute or resource.

          Simple example:

              {
                "errors": [
                  {
                    "status": 422,
                    "source": {
                      "pointer": "/data/attributes/email"
                    },
                    "detail": "has already been taken",
                    "meta": {
                      "type": "taken"
                    }
                  }
                ]
              }

          There can also be multiple errors on the same field

              {
                "errors": [
                  {
                    "status": 422,
                    "source": {
                      "pointer": "/data/attributes/age"
                    },
                    "detail": "must be a less than or equal to 123",
                    "meta": {
                      "type": "less_than_or_equal_to",
                      "value": 200,
                      "count": 123
                    }
                  },
                  {
                    "status": 422,
                    "source": {
                      "pointer": "/data/attributes/phone"
                    },
                    "detail": "must be a valid phone number",
                    "meta": {
                      "type": "invalid"
                    }
                  },
                  {
                    "status": 422,
                    "source": {
                      "pointer": "/data/attributes/phone"
                    },
                    "detail": "must be a Swedish phone number (+46)",
                    "meta": {
                      "type": "invalid"
                    }
                  }
                ]
              }

          Its also possible that the `pointer` is more general and doesn't point to a specific attribute, but instead `data/attributes`.
          In this case there is a general error.
          One example could be that the user has a max limit on the number of resources they create per day and when they reached their max limit:

              {
                "errors": [
                  {
                    "status": 403,
                    "source": {
                      "pointer": "/data/attributes"
                    },
                    "detail": "can't create more than 10 per day"
                  }
                ]
              }

          In rare cases `source/pointer` can point to a "virtual" attribute.
          For example `clearing_number` and `account_number` can have specific errors, but they can also have an error that is due to the combination of the two.
          In this case called `account` (this should be documented under each specific resource that can have errors like this).

              {
                "errors": [
                  {
                    "status": 422,
                    "source": {
                      "pointer": "/data/attributes/account"
                    },
                    "detail": "is too short",
                    "meta": {
                      "type": "too_short",
                      "count": 4
                    }
                  }
                ]
              }

          As you can see above the API adds a `meta`-key under each error object. It should contain a `type` attribute and can contain a `count` and `value` attribute.
          `type` is derivied from the error types found in `ActiveModel::Errors#details` (added in Rails 5). All attribute errors with an unknown type will default to `invalid`.

          List of available error types: #{JsonApiErrorSerializer::KNOWN_ERROR_TYPES.to_a.map { |t| "`#{t}`" }.to_sentence}.

        DOCDESCRIPTION
        api_base_url '/api/v1'
      end

      NoSuchTokenError = Class.new(ArgumentError)
      ExpiredTokenError = Class.new(ArgumentError)
      InvalidAuthTokenError = Class.new(ArgumentError)

      before_action :authenticate_user_token!
      before_action :set_locale

      ALLOWED_INCLUDES = [].freeze

      # Needed for #authenticate_with_http_token
      include ActionController::HttpAuthentication::Token::ControllerMethods

      after_action :track_request
      after_action :verify_authorized

      rescue_from Pundit::NotAuthorizedError, with: :user_forbidden
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ExpiredTokenError, with: :expired_token
      rescue_from NoSuchTokenError, with: :no_such_token
      rescue_from InvalidAuthTokenError, with: :invalid_auth_token

      def append_info_to_payload(payload)
        super
        payload[:user_id] = current_user.id
      end

      def track_event(label, properties = {})
        data = default_event_properties.merge!(properties)
        analytics.track(label, data: data)
      end

      def default_event_properties
        {
          locale: I18n.locale,
          user_agent: request.user_agent,
          origin: request.origin,
          referer: request.referer,
          remote_ip: request.remote_ip,
          cf_remote_ip: request.headers['CF-Connecting-IP'],
          cf_ip_country_code: request.headers['CF-IPCountry'],
          content_type: request.content_type,
          url: request.url,
          verb: request.method,
          path: request.path,
          query: request.query_string,
          true_user_id: true_user.id,
          current_user_id: current_user.id
        }
      end

      def analytics
        @_ahoy ||= Analytics.new(controller: self)
      end

      def jsonapi_params
        @_deserialized_params ||= JsonApiDeserializer.parse(params)
      end

      def include_params
        @_include_params ||= JsonApiIncludeParams.new(params[:include])
      end

      def fields_params
        @_fields_params ||= JsonApiFieldsParams.new(params[:fields])
      end

      def included_resources
        @_included_resources ||= include_params.permit(self.class::ALLOWED_INCLUDES)
      end

      def included_resource?(resource_name)
        included_resources.include?(resource_name.to_s)
      end

      def current_user
        @_current_user ||= User.new
      end

      def true_user
        @_true_user ||= User.new
      end

      def current_language
        @_current_language ||= Language.find_by_locale(I18n.locale)
      end

      protected

      def track_request
        response_error_body = {}
        # If there is validation errors, then add that to the event, so we can check
        # what the most common validation errors are (and then fix the client UX)
        response_error_body = JSON.parse(response.body) if response.status == 422

        properties = {
          response_status: response.status,
          response_message: response.message,
          response_error_json: response_error_body
        }
        track_event("#{params[:controller]}##{params[:action]}", properties)
      end

      def api_render_errors(model)
        errors = {
          errors: JsonApiErrorSerializer.serialize(model),
          meta: deprecations_meta
        }
        render json: errors, status: :unprocessable_entity
      end

      def api_render(model_or_model_array, status: :ok, total: nil, meta: {})
        model = model_or_model_array
        meta[:total] = total if total

        meta[:current_page] = model.current_page if model.respond_to?(:current_page)
        meta[:total_pages] = model.total_pages if model.respond_to?(:total_pages)

        serialized_model = JsonApiSerializer.serialize(
          model,
          included: included_resources,
          fields: fields_params.to_h,
          current_user: current_user,
          current_language: current_language,
          meta: meta.merge(deprecations_meta),
          request: request
        )

        render json: serialized_model, status: status
      end

      def record_not_found
        render json: NotFound.add, status: :not_found
      end

      def require_user
        return if logged_in?

        render json: LoginRequired.add, status: :unauthorized
      end

      def user_forbidden
        status = nil
        errors = JsonApiErrors.new

        if logged_in?
          status = 403 # forbidden
          InvalidCredentials.add(errors)
        else
          status = 401 # unauthorized
          LoginRequired.add(errors)
        end

        render json: errors, status: status
      end

      def expired_token
        status = 401 # unauthorized
        render json: TokenExpired.add.to_json, status: status
      end

      def no_such_token
        status = 401 # unauthorized
        render json: NoSuchToken.add.to_json, status: status
      end

      def invalid_auth_token
        status = 401 # unauthorized
        render json: InvalidAuthToken.add.to_json, status: status
      end

      def login_user(user, true_user = nil)
        @_true_user = true_user || user
        @_current_user = user
      end

      def not_logged_in?
        !logged_in?
      end

      def logged_in?
        current_user.persisted?
      end

      def set_locale
        locale_header = api_locale_header
        if locale_header.blank?
          I18n.locale = current_user.locale
          return
        end

        # Only allow available locales
        I18n.available_locales.map(&:to_s).each do |locale|
          I18n.locale = locale if locale == locale_header
        end
      end

      def api_locale_header
        request.headers['X-API-LOCALE']
      end

      def act_as_user_header
        request.headers['X-API-ACT-AS-USER']
      end

      private

      def deprecations_meta
        return {} if @deprecations.blank?
        { deprecations: @deprecations }
      end

      def add_deprecation(message, attribute = nil)
        ActiveSupport::Deprecation.warn(message)

        @deprecations ||= []
        @deprecations << { attribute: attribute, message: message }
      end

      def authenticate_user_token!
        # First try to grab the token from the Authorization header
        authenticate_with_http_token do |auth_token, _options|
          return login_user_from_token(auth_token)
        end

        # Secondly, if no Authorization header is set try to grab it from the URL
        login_user_from_token(params[:auth_token]) unless logged_in?
      end

      def login_user_from_token(auth_token)
        return if auth_token.blank?

        token = Token.find_by(token: auth_token)
        return if token.nil?
        # return raise NoSuchTokenError if token.nil?
        return raise ExpiredTokenError if token.expired?

        user = token.user

        if user.admin? && act_as_user_header.present?
          true_user = user
          user = User.find(act_as_user_header)
        end

        login_user(user, true_user)
      end
    end
  end
end
