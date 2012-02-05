module Periods
  module Extension
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def has_time_span_scopes(*args)
        opts = args.extract_options!
          class_attribute :periods_has_time_span_scopes_column, :periods_default_scope_name,
          :instance_writer => false, :instance_reader => false

        column = args.pop || ::Periods::ServiceHelpers.fallback_column(self)
        self.periods_has_time_span_scopes_column = column

        scope_name = (opts[:scope_name] || :span).to_sym
        self.periods_default_scope_name = scope_name

        include ::Periods::DefaultScopes
        include ::Periods::OptionalScopes if opts[:with_all_scopes]
      end
    end
  end
end

ActiveRecord::Base.send(:include, Periods::Extension)

