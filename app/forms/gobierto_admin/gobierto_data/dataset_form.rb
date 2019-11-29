# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoData
    class DatasetForm < BaseForm
      prepend ::GobiertoCommon::TrackableGroupedAttributes

      attr_accessor(
        :id,
        :site_id,
        :name_translations,
        :table_name,
        :slug,
        :admin_id,
        :ip
      )

      validates :site_id, presence: true
      validate :table_reachable

      delegate :persisted?, to: :dataset

      trackable_on :dataset
      use_event_prefix :dataset
      notify_changed :name_translations, :table_name, :slug, as: :attribute
      use_publisher Publishers::AdminGobiertoDataActivity
      use_trackable_subject :dataset

      def save
        save_dataset if valid?
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end

      def dataset
        @dataset ||= dataset_class.find_by(id: id).presence || build_dataset
      end

      def available_table_names
        ::GobiertoData::Connection.tables(site)
      end

      private

      def build_dataset
        dataset_class.new
      end

      def dataset_class
        ::GobiertoData::Dataset
      end

      def save_dataset
        @dataset = dataset.tap do |attributes|
          attributes.site_id = site_id
          attributes.name_translations = name_translations
          attributes.table_name = table_name
          attributes.slug = slug.blank? ? nil : slug
        end

        if @dataset.valid?
          run_callbacks(:save) do
            @dataset.save
          end

          @dataset
        else
          promote_errors(@dataset.errors)

          false
        end
      end

      def table_reachable
        query_result = ::GobiertoData::Connection.execute_query(site, Arel.sql("SELECT COUNT(*) FROM #{table_name} LIMIT 1"))

        errors.add(:table_name, :invalid_table, error_message: query_result[:error]) if query_result.is_a?(Hash) && query_result.has_key?(:error)
      end
    end
  end
end