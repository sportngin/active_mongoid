require "active_mongoid/associations/document_relation/macros"
require "active_mongoid/associations/document_relation/accessors"
require "active_mongoid/associations/document_relation/builders"
require "active_mongoid/associations/document_relation/auto_save"
require "active_mongoid/associations/document_relation/dependent"
require "active_mongoid/associations/document_relation/bindings/one"
require "active_mongoid/associations/document_relation/bindings/in"
require "active_mongoid/associations/document_relation/bindings/many"
require "active_mongoid/associations/document_relation/referenced/one"
require "active_mongoid/associations/document_relation/referenced/in"
require "active_mongoid/associations/document_relation/referenced/many"

module ActiveMongoid
  module Associations
    module DocumentRelation
      module Associations
        extend ActiveSupport::Concern

        attr_accessor :__metadata__

        included do
          include DocumentRelation::Macros
          include DocumentRelation::Accessors
          include DocumentRelation::Builders
          include DocumentRelation::AutoSave
          include DocumentRelation::Dependent
        end

        def referenced_many_records?
          __metadata__ && __metadata__.macro == :has_many_records
        end

        def referenced_one_record?
          __metadata__ && __metadata__.macro == :has_one_record
        end

      end
    end
  end
end

