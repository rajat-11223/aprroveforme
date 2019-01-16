module CountryBlock
  class App
    HEADER_KEY = ENV.fetch("COUNTRY_BLOCK_HEADER_KEY", "HTTP_CF_IPCOUNTRY")
    REDIRECT_TYPE = ENV.fetch("COUNTRY_BLOCK_REDIRECT_TYPE", 302)
    REDIRECT_URL = ENV.fetch("COUNTRY_BLOCK_REDIRECT_URL")

    EU_COUNTRIES =
      ["AT", "BE", "BG", "HR", "CY", "CZ", "DK", "EE", "FI", "FR", "DE", "GR", "HU", "IE", "IT", "LV", "LT", "LU", "MT", "NL",
       "PL", "PT", "RO", "SK", "SI", "ES", "GB", "GF", "GP", "MQ", "ME", "YT", "RE", "MF", "GI", "AX", "PM", "GL", "BL",
       "SX", "AW", "CW", "WF", "PF", "NC", "TF", "AI", "BM", "IO", "VG", "KY", "FK", "MS", "PN", "SH", "GS", "TC", "AD", "LI",
       "MC", "SM", "VA", "JE", "GG", "GI", "CH"]

    #  Temporarily enable these:
    ALLOWED_COUNTRIES = ["SE"]

    BLOCKED_COUNTRIES = ENV.fetch("BLOCKED_COUNTRIES", EU_COUNTRIES).map(&:upcase).compact

    def initialize(app)
      @app = app
    end

    def call(env)
      @req = Rack::Request.new(env)

      return redirect_to_country_block_path if !on_allowed_page? && from_blocked_country?

      @app.call(env)
    end

    private

    attr_reader :req

    def on_allowed_page?
      req.post? ||
        req.path.starts_with?(REDIRECT_URL) ||
        req.path.starts_with?("/assets") ||
        req.path.starts_with?("/packs")
    end

    def from_blocked_country?
      country = req.get_header(HEADER_KEY)
      return false if country.blank?

      BLOCKED_COUNTRIES.include?(country.upcase)
    end

    def redirect_to_country_block_path
      [REDIRECT_TYPE, {"Content-Type" => "text/plain; charset=utf-8", "Location" => REDIRECT_URL}, REDIRECT_URL.chars]
    end
  end
end
