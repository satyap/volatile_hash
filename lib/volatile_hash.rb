class VolatileHash
    def initialize(options)
        @strategy = options[:strategy] || 'ttl'
        @cache = {}
        if @strategy == 'ttl'
            @registry = {}
            @ttl = options[:ttl] || 3600
        else #lru
            @max_items = options[:max] || 10
            @item_order = []
        end
        @refresh = options[:refresh] or false
    end

    def key?(key)
        value = @cache.key?(key)
        if @strategy == 'ttl'
            if @registry[key] && expired?(key)
                @cache.delete key
                @registry.delete key
                value = false
            end
            if @refresh and @registry[key]
                set_ttl(key)
            end
        else
            lru_update key if @cache.has_key?(key)
        end
        value #in case of LRU, just return the value that was read
    end

    def keys
        output = []
        values = @cache.keys
        values.each do |value|
            output.push(value) if key?(value)
        end
        output
    end

    def to_hash
        output = {}
        values = @cache.keys
        values.each do |value|
            output[value] = @cache[value] if key?(value)
        end
        output
    end

    def [](key)
        value = @cache[key]
        if @strategy == 'ttl'
            if @registry[key] && expired?(key)
                @cache.delete key
                @registry.delete key
                value = nil
            end
            if @refresh and @registry[key]
                set_ttl(key)
            end
        else
            lru_update key if @cache.has_key?(key)
        end
        value #in case of LRU, just return the value that was read
    end

    def []=(key, value)
        if @strategy == 'ttl'
            set_ttl(key)
            @cache[key] = value
        else
            @item_order.unshift key
            @cache[key] = value
            lru_invalidate if @max_items < @item_order.length
        end
    end

    private
    def set_ttl(key)
        @registry[key] = Time.now + @ttl.to_f
    end

    def expired?(key)
        Time.now > @registry[key]
    end

    def lru_invalidate
        while @max_items < @item_order.length
            @cache.delete @item_order.pop
        end
    end

    def lru_update(key)
        @item_order.delete key
        @item_order.unshift key
    end
end
