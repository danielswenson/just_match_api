# frozen_string_literal: true
class NewApplicantNotifier < BaseNotifier
  def self.call(job_user:, owner:)
    return if ignored?(owner)

    JobMailer.
      new_applicant_email(job_user: job_user, owner: owner).
      deliver_later
  end
end
