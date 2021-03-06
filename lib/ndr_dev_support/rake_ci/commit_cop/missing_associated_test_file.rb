require_relative 'concerns/deputisable'

module NdrDevSupport
  module RakeCI
    module CommitCop
      # This cop checks for new controllers, helpers,
      # mailers and models without a new, associated test file
      class MissingAssociatedTestFile
        include Deputisable

        def check(changes)
          added = changes[:added]
          return unless added.any?

          tested_paths = CommitCop.tested_paths.join('|')
          monitored_files = added.select { |file| file =~ %r{((#{tested_paths})\/.*\.rb)} }

          files_without_tests = monitored_files.reduce([]) do |missing_tests, monitored_file|
            test_file = monitored_file.gsub(%r{\A\w+\/(.*)\.rb\z}, 'test/\1_test.rb')
            added.include?(test_file) ? missing_tests : missing_tests << monitored_file
          end

          return if files_without_tests.empty?

          attachment :danger,
                     'No associated test file committed',
                     "File(s) submitted without an associated test file:\n" \
                     "#{files_without_tests.join("\n")}"
        end
      end
    end
  end
end
