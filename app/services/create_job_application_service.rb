# frozen_string_literal: true

class CreateJobApplicationService
  def self.call(job:, user:, attributes:, job_owner:)
    job_user = JobUser.find_or_initialize_by(user: user, job: job)
    job_user.application_withdrawn = false
    job_user.apply_message = attributes[:apply_message]
    job_user.language = Language.find_by(id: attributes[:language_id])

    if job_user.save
      job_user.set_translation(attributes).tap do |result|
        ProcessTranslationJob.perform_later(
          translation: result.translation,
          changed: result.changed_fields
        )
      end

      missing_traits = Queries::MissingUserTraits
      missing_skills = missing_traits.skills(user: user, skills: job.skills)
      missing_languages = missing_traits.languages(user: user, languages: job.languages)
      NewApplicantNotifier.call(
        job_user: job_user,
        owner: job_owner,
        skills: missing_skills,
        languages: missing_languages
      )
    end

    job_user
  end
end
