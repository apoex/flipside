module Flipside
  module Config
    module Settings
      attr_accessor :ui_back_path, :create_missing_features
      attr_writer :default_object

      def default_object
        case @default_object
        when Proc
          @default_object.call
        else
          @default_object
        end
      end
    end
  end
end
