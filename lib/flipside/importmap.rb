module Flipside
  module Importmap
    LIBRARIES = {
      "@hotwired/stimulus": "https://cdn.jsdelivr.net/npm/@hotwired/stimulus/dist/stimulus.js",
    }.freeze

    def importmap_tags
      JSON.generate({imports:})
    end

    private

    def imports
      LIBRARIES.merge(controllers)
    end

    def controllers
      pattern = File.join(__dir__, "public/*_controller.js")

      Dir.glob(pattern).to_h do |controller|
        name = File.basename(controller, ".js")
        [name, public_path("#{name}.js")]
      end
    end
  end
end
