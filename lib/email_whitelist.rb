module EmailWhitelist
  def self.whitelisted?(email, whitelist: nil)
    if whitelist.nil?
         whitelist = Rails.application.secrets.email_whitelist || ''
    end
    if whitelist.empty?
         puts "EMAIL_WHITELIST is empty"
         return false
    end
    patterns = self.parse_whitelist whitelist
    !!patterns.match(email)
  end

  private
  def self.parse_whitelist(whitelist)
    regexps = whitelist.split(';').map do |pattern|
      Regexp.new pattern
    end
    Regexp::union regexps
  end
end
