# frozen_string_literal: true

class PushArbetsformedlingenAdService
  Result = Struct.new(:errors, :log)

  def self.call(arbetsformedlingen_ad)
    ad = arbetsformedlingen_ad

    wrapper = Arbetsformedlingen::JobWrapper.new(ad)
    return Result.new(wrapper.errors, nil) unless wrapper.valid?

    response = Arbetsformedlingen.post_job(wrapper.packet)

    log = ArbetsformedlingenAdLog.create!(
      arbetsformedlingen_ad: ad,
      response: {
        code: response.code,
        messages: response.messages,
        body: response.body,
        request_body: response.request_body
      }
    )

    Result.new([], log)
  end
end
