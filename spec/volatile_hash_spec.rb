require 'spec_helper'

describe VolatileHash do
  class VolatileHash
        attr_reader :cache
    end

    describe "TTL mode" do
        before do
            @cache = VolatileHash.new(:strategy => 'ttl', :ttl => 0.7, :max => 1)
            @x = Object.new
            @cache[:x] = @x.to_s
        end

        it "should remember cached values" do
            @cache[:x].should == @x.to_s
        end
        
        it "should not have to re-calculate cached values" do
            dont_allow(@x).to_s
            @cache[:x] ||= @x.to_s
        end

        it "should forget cached values after the TTL expires" do
            @cache[:x].should == @x.to_s

            sleep(0.8)

            @cache[:x].should be_nil
        end

        it "should continue returning nil for cached values after the TTL expires" do
            @cache[:x].should == @x.to_s

            sleep(0.8)

            @cache[:x].should be_nil
            @cache[:x].should be_nil
        end

        it "should not throw out least-recently used value" do
            @cache[:y] = 1

            @cache[:x].should_not be_nil
            @cache[:y].should_not be_nil
        end
        
        it "should not reset TTL when an item is accessed" do
            sleep(0.4)
            @cache[:x].should == @x.to_s
            sleep(0.4)
            @cache[:x].should be_nil
        end

        context "key?(hash_key)" do
            it "should return true if key is present and not expired" do
                @cache.key?(:x).should == true
            end

            it "should return false if key is absent or expired" do
                @cache.key?(:y).should == false
                sleep(0.8)
                @cache.key?(:x).should == false
            end
        end

        context 'keys' do
            it 'should return the keys of cache' do
                @cache.keys.should == [:x]
            end
        end

        context 'to_hash' do
            it 'should return the native hash' do
                @cache.to_hash.should eq(@cache.cache)
            end
        end

        context "when asked to refresh TTL on access" do
            it "should not forget cached values after TTL expires" do
                cache = VolatileHash.new(:strategy => 'ttl', :ttl => 0.7, :refresh => true)
                x = Object.new
                cache[:x] = @x.to_s
                sleep(0.4)
                cache[:x].should == @x.to_s
                sleep(0.4)
                cache[:x].should == @x.to_s
            end
        end
    end

    describe "LRU mode" do
        before do
            @cache = VolatileHash.new(:strategy => 'lru', :max => 3, :ttl => 0.1)
            @x = Object.new
            @y = Object.new
            @z = Object.new
            @cache[:x] = @x.to_s
        end

        it "should remember cached values" do
            @cache[:x].should == @x.to_s
        end

        it "should not have to re-calculate cached values" do
            dont_allow(@x).to_s
            @cache[:x] ||= @x.to_s
        end

        it "should have only up to the last max values" do
            @cache[:x].should == @x.to_s
            @cache[:y].should be_nil
            @cache[:z].should be_nil
            @cache[:w].should be_nil

            @cache[:y] = @y.to_s
            @cache[:z] = @z.to_s
            @cache[:w] = @z.to_s

            @cache[:x].should be_nil
            @cache[:y].should == @y.to_s
            @cache[:z].should == @z.to_s
            @cache[:w].should == @z.to_s
        end

        it "should throw out the least recently accessed value" do
            @cache[:y] = @y.to_s
            @cache[:z] = @z.to_s
            @cache[:y].should == @y.to_s
            @cache[:x].should == @x.to_s
            @cache[:z].should == @z.to_s

            @cache[:w] = @x.to_s

            @cache[:x].should == @x.to_s
            @cache[:y].should be_nil
            @cache[:z].should == @z.to_s
            @cache[:w].should == @x.to_s
        end

        it "should not expire by ttl" do
            sleep(0.3)
            @cache[:x].should_not be_nil
        end

    end
end

