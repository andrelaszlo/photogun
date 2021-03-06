module PhotosHelper
  # Remove most of the local part of an email address
  # user@example.com will be u...r@example.com
  def redact_email(email)
    name, domain = email.split '@'
    redacted = "%s..." % name[0]
    "#{redacted}@#{domain}"
  end
end
