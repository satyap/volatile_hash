class VolatileHash
    def initialize(options)
        @strategy = options[:strategy] || 'ttl'
        @registry = {}
        @cache = {}
        if @strategy == 'ttl'
            @ttl = options[:ttl] || 3600
        else #lru
            @max_items = options[:max_items] || 10
        end
    end

    def [](key)
        if @strategy == 'ttl'
            if expired?(key)
                @cache.delete key
                @registry.delete key
                return nil
            end
        else
        end
        @cache[key]
    end

    def []=(key, value)
        if @strategy == 'ttl'
            @registry[key] = Time.now + @ttl.to_f
        else
        end
        @cache[key] = value
    end

    private
    def expired?(key)
        Time.now > @registry[key]
    end
end
