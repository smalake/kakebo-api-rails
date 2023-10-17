class ApplicationMailer < ActionMailer::Base
  default from: "kakebo-noreply@google.com"
  layout "mailer"
end
