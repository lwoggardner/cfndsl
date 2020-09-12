# frozen_string_literal: true

module CfnDsl
  module Generate
    # Plural names for lists of content objects
    module Plurals
      module_function

      # known special cases seen in cloudformation
      @plurals = {
        'SecurityGroupIngress' => 'SecurityGroupIngressRules',
        'SecurityGroupEgress' => 'SecurityGroupEgressRules'
      }
      @singles = @plurals.invert

      def pluralize(name)
        if name.to_s != singularize(name)
          # If the name can be singularized to something different then it is already pluralized
          name.to_s
        else
          @plurals.fetch(name.to_s) do |key|
            case key
            when /[^aeiou]y$/ # property => properties, but not toy => toyies
              key[0..-2] + 'ies'
            when /(sh|ch|ss)$/
              key + 'es'
            else
              key + 's'
            end
          end
        end
      end

      def singularize(name)
        @singles.fetch(name.to_s) do |key|
          case key
          when /List$/ # ThingList => Thing
            key[0..-5]
          when /ies$/ # properties => property
            key[0..-4] + 'y'
          when /[aeiou][^aeiou]es$/, /[aeiou]es$/ # cases => case, issues => issue
            key[0..-2]
          when /es$/ # processes => process, boxes => box, hashes -> hash
            key[0..-3]
          when /[^s]s$/ # plans => plan, cases => case, but not class => clas
            key[0..-2]
          else
            key # assume already singular
          end
        end
      end
    end
  end
end
