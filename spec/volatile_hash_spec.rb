require 'spec_helper'

describe VolatileHash do
    describe "TTL mode" do
        before do
            @cache = VolatileHash.new(:strategy => 'ttl', :ttl => 0.5)
            @x = Object.new
        end

        it "should remember cached values" do
            @cache[:x] = @x.to_s

            @cache[:x].should == @x.to_s
        end
        
        it "should not have to re-calculate cached values" do
            @cache[:x] = @x.to_s

            dont_allow(@x).to_s
            @cache[:x] ||= @x.to_s
        end

        it "should forget cached values after the TTL expires" do
            @cache[:x] = @x.to_s
            @cache[:x].should == @x.to_s

            sleep(0.6)

            @cache[:x].should be_nil
        end
    end

    describe "LRU mode" do
    end
end

