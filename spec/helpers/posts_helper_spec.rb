require 'spec_helper'

describe Spree::PostsHelper do
  describe :make_title do
    context "no prameters" do
      it "use blog title if present" do
        Spree::Config[:blog_title] = nil
        make_title.should eql(Spree.t(:blog))
      end

      it "use blog when no title present" do
        Spree::Config[:blog_title] = "this is a test"
        make_title.should eql("this is a test")
      end
    end

    context "with tags" do
      it "say by tag" do
        make_title("awesome").should eql("Posts tagged Awesome")
      end
    end

    context "with date" do
      it "handle year" do
        make_title(nil, "2010").should eql("Posts for year 2010")
      end

      it "handle month" do
        make_title(nil, "2010", "1").should eql("Posts for January 2010")
      end

      it "handle day" do
        make_title(nil, "2011", "1", "1").should eql("Posts for Saturday, 01 January, 2011")
      end
    end
  end
end
