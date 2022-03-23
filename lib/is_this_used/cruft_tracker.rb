# frozen_string_literal: true

module IsThisUsed
  module CruftTracker
    INSTANCE_METHOD = 'instance_method'
    CLASS_METHOD = 'class_method'

    class Recorder
      def self.record_invocation(potential_cruft)
        PotentialCruft.increment_counter(
          :invocations,
          potential_cruft.id,
          touch: true
        )
        record_stack(potential_cruft)
      end

      def self.record_stack(potential_cruft)
        stack = filtered_stack
        stack_hash = Digest::MD5.hexdigest(stack.to_json)

        potential_cruft_stack =
          PotentialCruftStack.find_by(
            potential_cruft: potential_cruft, stack_hash: stack_hash
          )
        potential_cruft_stack ||=
          PotentialCruftStack.new(
            potential_cruft: potential_cruft,
            stack_hash: stack_hash,
            stack: stack
          )

        potential_cruft_stack.occurrences += 1

        potential_cruft_stack.save
      end

      def self.filtered_stack
        caller_locations.reject do |location|
          location.path.match?(
            %r{\/lib\/is_this_used\/(cruft_tracker.rb|util\/log_suppressor.rb)$}
          )
        end.map do |location|
          {
            path: location.path,
            label: location.label,
            base_label: location.base_label,
            lineno: location.lineno
          }
        end
      end

      def self.record_arguments(potential_cruft, arguments)
        arguments_hash = Digest::MD5.hexdigest(arguments.to_json)

        potential_cruft_argument =
          PotentialCruftArgument.find_by(
            potential_cruft: potential_cruft, arguments_hash: arguments_hash
          )
        potential_cruft_argument ||=
          PotentialCruftArgument.new(
            potential_cruft: potential_cruft,
            arguments_hash: arguments_hash,
            arguments: arguments
          )

        potential_cruft_argument.occurrences += 1

        potential_cruft_argument.save
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def is_this_used?(method_name, method_type: nil, track_arguments: false)
        IsThisUsed::Util::LogSuppressor.suppress_logging do
          method_type ||= determine_method_type(method_name)
          target_method = target_method(method_name, method_type)

          potential_cruft = create_or_find_potential_cruft(
            owner_name: self.name,
            method_name: method_name,
            method_type: method_type
          )

          potential_cruft.update(deleted_at: nil) if potential_cruft.deleted_at.present?

          IsThisUsed::Registry.instance << potential_cruft

          target_method.owner.define_method target_method.name do |*args|
            IsThisUsed::Util::LogSuppressor.suppress_logging do
              CruftTracker::Recorder.record_invocation(potential_cruft)
              if track_arguments
                arguments = track_arguments.instance_of?(Proc) ? track_arguments.call(args) : args

                CruftTracker::Recorder.record_arguments(potential_cruft, arguments)
              end
            end
            if method_type == INSTANCE_METHOD
              target_method.bind(self).call(*args)
            else
              target_method.call(*args)
            end
          end
        end
      rescue ActiveRecord::StatementInvalid => e
        raise unless e.cause.present? && e.cause.instance_of?(Mysql2::Error)

        Rails.logger.warn(
          'There was an error recording potential cruft. Does the potential_crufts table exist? Have migrations been run?'
        )
      rescue NoMethodError
        Rails.logger.warn(
          'There was an error recording potential cruft. Have migrations been run?'
        )
      rescue Mysql2::Error::ConnectionError, ActiveRecord::ConnectionNotEstablished
        Rails.logger.warn(
          'There was an error recording potential cruft due to being unable to connect to the database. This may be a non-issue in cases where the database is intentionally not available.'
        )
      end

      def target_method(method_name, method_type)
        case method_type
        when INSTANCE_METHOD
          self.instance_method(method_name)
        when CLASS_METHOD
          self.method(method_name)
        end
      end

      def determine_method_type(method_name)
        is_instance_method =
          (self.instance_methods + self.private_instance_methods).include?(
            method_name
          )
        is_class_method =
          (self.methods + self.private_methods).include?(method_name)

        if is_instance_method && is_class_method
          raise AmbiguousMethodType.new(self.name, method_name)
        elsif is_instance_method
          INSTANCE_METHOD
        elsif is_class_method
          CLASS_METHOD
        else
          raise NoSuchMethod.new(self.name, method_name)
        end
      end

      def create_or_find_potential_cruft(owner_name:, method_name:, method_type:)
        PotentialCruft.find_or_create_by(owner_name: self.name,
                                         method_name: method_name,
                                         method_type: method_type)

      rescue ActiveRecord::RecordNotUnique => e
        PotentialCruft.find_by(owner_name: self.name,
                               method_name: method_name,
                               method_type: method_type)
      end
    end
  end

  class AmbiguousMethodType < StandardError
    def initialize(owner_name, ambiguous_method_name)
      super(
        "#{owner_name} has instance and class methods named '#{
          ambiguous_method_name
        }'. Please specify the correct type."
      )
    end
  end

  class NoSuchMethod < StandardError
    def initialize(owner_name, missing_method_name)
      super(
        "#{owner_name} does not have an instance or class method named '#{
          missing_method_name
        }'."
      )
    end
  end
end
