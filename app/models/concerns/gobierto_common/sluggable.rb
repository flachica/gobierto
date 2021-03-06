# frozen_string_literal: true

module GobiertoCommon
  module Sluggable
    extend ActiveSupport::Concern

    included do
      before_validation :set_slug
      after_destroy :add_archived_to_slug
    end

    private

    def set_slug
      if slug.present? && !slug.include?("archived-")
        self.slug = slug.tr("_", " ").parameterize
        return
      end

      base_slug = attributes_for_slug.join("-").tr("_", " ").parameterize
      new_slug = base_slug

      if uniqueness_validators.present?
        uniqueness_validators.each do |validator|
          if (related_slugs = self.class.where("slug ~* ?", "#{ new_slug }-\\d+$").where(scope_attributes(validator.options[:scope]))).exists?
            max_count = related_slugs.pluck(:slug).map { |slug| slug.scan(/\d+$/).first.to_i }.max
            new_slug = "#{ base_slug }-#{ max_count + 1 }"
          elsif self.class.exists?(scope_attributes(validator.options[:scope]).merge(slug: new_slug))
            new_slug = "#{ base_slug }-2"
          end
        end
      end

      self.slug = new_slug
    end

    def add_archived_to_slug
      unless destroyed?
        update_attribute(:slug, "archived-" + id.to_s)
      end
    end

    def uniqueness_validators
      @uniqueness_validators ||= self.class.validators_on(:slug).select { |validator| validator.kind == :uniqueness }
    end

    def scope_attributes(options)
      options = [options].compact unless options.is_a? Enumerable
      attributes.slice(*options.map(&:to_s))
    end
  end
end
