module Texico
  class Template
    class FileStatus
      STATUS = [
        :successful,
        :target_exist,
        :replaced_target
      ]

      attr_reader :file

      def initialize(file, status = :successful)
        unless STATUS.include?(status) || status.is_a?(Exception)
          raise ArgumentError, 'Unknown status'
        end

        @status    = status
        @file      = file

        freeze
      end

      def status
        @status.is_a?(Exception) ? :template_error : @status
      end
    end # FileStatus
  end # Template
end # Texico
