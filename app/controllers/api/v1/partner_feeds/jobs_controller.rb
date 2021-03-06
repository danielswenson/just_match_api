# frozen_string_literal: true

module Api
  module V1
    module PartnerFeeds
      class JobsController < BaseController
        before_action :verify_linkedin_sync_key, only: %i(linkedin)
        after_action :verify_authorized, except: %i(linkedin blocketjobb)

        resource_description do
          resource_id 'PartnerFeeds'
          short 'API for partner job feeds'
          name 'Partner Feeds'
          description 'Job feeds for partners'
          formats [:xml]
          api_versions '1.0'
        end

        api :GET, '/partner-feeds/jobs/linkedin', 'List jobs for LinkedIN feed'
        description 'Returns a list of jobs for LinkedIN to consume.'
        param :auth_token, String, desc: 'Auth token', required: true
        example <<-XML_EXAMPLE
        <?xml version="1.0" encoding="UTF-8"?>
        <source>
          <publisherUrl>https://justarrived.se</publisherUrl>
          <publisher>Just Arrived</publisher>
          <job>
              <company><![CDATA[Macejkovic, Lynch and Considine]]></company>
              <partnerJobId><![CDATA[300]]></partnerJobId>
              <title><![CDATA[Something something, title.]]></title>
              <description><![CDATA[Something, something. #welcometalent]]></description>
              <location>Storta Nygatan 36, 21137, Stockholm, Sverige</location>
              <city><![CDATA[Stockholm]]></city>
              <countryCode><![CDATA[SE]]></countryCode>
              <postalCode><![CDATA[21137]]></postalCode>
              <applyUrl><![CDATA[https://app.justarrived.se/job/300]]></applyUrl>
          </job>
          <job>
            ...
          </job>
        </source>
        XML_EXAMPLE
        def linkedin
          jobs = Job.with_translations.
                 linkedin_jobs.
                 includes(:company).
                 order(created_at: :desc).
                 limit(AppConfig.linkedin_job_records_feed_limit)

          render xml: LinkedinJobsSerializer.to_xml(jobs: jobs)
        end

        api :GET, '/partner-feeds/jobs/blocketjobb', 'List jobs for Blocketjobb feed'
        description 'Returns a list of jobs for Blocketjobb to consume.'
        param :auth_token, String, desc: 'Auth token', required: true
        def blocketjobb
          jobs = Job.with_translations.
                 blocketjobb_jobs.
                 includes(:company).
                 order(created_at: :desc)

          render xml: BlocketjobbJobsSerializer.to_xml(jobs: jobs)
        end

        private

        def verify_linkedin_sync_key
          unauthorized! if params[:auth_token].blank?
          return if AppSecrets.linkedin_sync_key == params[:auth_token]

          unauthorized!
        end

        def unauthorized!
          raise Pundit::NotAuthorizedError
        end
      end
    end
  end
end
