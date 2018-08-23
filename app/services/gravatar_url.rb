class GravatarUrl
  def self.generate(email)
    return unless email.present?

    ["http://www.gravatar.com/avatar/", Digest::MD5.hexdigest(email.downcase.strip), "?d=mm"].join
  end
end
