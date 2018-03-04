module Texico
  class Template
    # FileStatus
    #
    # The FileStatus object represents the result of a copy command on a
    # template file. This class should never be used directly.
    class FileStatus
      STATUS = %i[successful target_exist replaced_target].freeze

      attr_reader :file

      def initialize(file, status = STATUS[0])
        unless STATUS.include?(status) || status.is_a?(Exception)
          raise ArgumentError, 'Unknown status'
        end

        @status    = status
        @file      = file

        freeze
      end

      def to_s
        "#{file.basename} [#{status}]"
      end

      def status
        @status.is_a?(Exception) ? :template_error : @status
      end
    end
  end
end
