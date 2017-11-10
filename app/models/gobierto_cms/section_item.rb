# frozen_string_literal: true

require_dependency "gobierto_cms"

module GobiertoCms
  class SectionItem < ApplicationRecord
    belongs_to :item, polymorphic: true
    belongs_to :section
    belongs_to :parent, class_name: "GobiertoCms::SectionItem", foreign_key: "parent_id"
    has_many :children, dependent: :destroy, class_name: "GobiertoCms::SectionItem", foreign_key: "parent_id"

    validates :item_id, :item_type, :position, :parent_id, :section_id, :level, presence: true

    scope :without_parent, -> { where(parent_id: 0) }
    scope :sorted, -> { order(position: :asc) }

    def all_parents(parent_array = [])
      if parent_id != 0
        parent_array.unshift(parent)
        parent.all_parents(parent_array)
      end
      parent_array
    end

    def hierarchy_and_children
      hierarchy = all_parents
      hierarchy.push(self)
      hierarchy.push(self.children)
    end
  end
end
