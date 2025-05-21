module ActiveMongoid
  class FinderProxy
    instance_methods.each do |method|
      undef_method(method) unless method =~ /(^__|^object_id|^tap)/
    end

    attr_accessor :__target
    attr_accessor :__target_class


    def initialize(target)
      @__target = target
      @__target_class = target.respond_to?(:klass) ? target.klass : target
    end

    def find(*args)
      key = args.flatten.first
      if !key.is_a?(Integer) && (key.is_a?(::ActiveMongoid::BSON::ObjectId) || ::ActiveMongoid::BSON::ObjectId.legal?(key))
        where({__am_primary_key => key}).first.tap do |obj|
          raise ActiveRecord::RecordNotFound unless obj
        end
      else
        FinderProxy.new(__target.send(:find, *args))
      end
    end

    def where(opts = :chain, *rest)
      if opts && opts.is_a?(Hash)
        bson_opts = opts.select do |k,v|
          ActiveMongoid::BSON::ObjectId.legal?(v)
        end
        if bson_opts[:id] && __am_primary_key != :id
          opts.delete(:id)
          bson_opts[:_id] = bson_opts.delete(:id)
        elsif bson_opts[:_id] && __am_primary_key == :id
          opts.delete(:_id)
          bson_opts[:id] = bson_opts.delete(:_id)
        end

        bson_opts.each do |k,v|
          bson_opts[k] = v.to_s
        end

        opts.merge!(bson_opts)
      end
      FinderProxy.new(__target.send(:where, opts, *rest))
    end

    def method_missing(name, *args, &block)
      resp = __target.send(name, *args, &block)
      if resp.is_a?(ActiveRecord::Relation)
        if resp.klass == __target_class
          FinderProxy.new(resp)
        else
          resp
        end
      elsif resp == __target_class
        FinderProxy.new(resp)
      else
        resp
      end
    end

    def __am_primary_key
      if __target_class.respond_to?(:__am_primary_key) && __target_class.__am_primary_key
        __target_class.__am_primary_key
      else
        :_id
      end
    end

  end
end
