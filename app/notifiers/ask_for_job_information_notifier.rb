# frozen_string_literal: true

class AskForJobInformationNotifier < BaseNotifier
  def self.call(job_user:)
    job = job_user.job
    user = job_user.user
    missing_skills = Queries::MissingUserTraits.skills(user: user, skills: job.skills)

    return if missing_skills.empty?

    envelope = JobMailer.
               ask_for_information_email(user: user, job: job, skills: missing_skills)
    dispatch(envelope, user: user, locale: user.locale)
  end
end
