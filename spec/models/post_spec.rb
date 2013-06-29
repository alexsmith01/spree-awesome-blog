require 'spec_helper'

describe Spree::Post do
  context "when creating" do
    it "is valid" do
      create_post.should have(0).errors
    end

    it "require title" do
      create_post(title: "").should have(1).error_on(:title)
    end

    it "have permalink" do
      post = create_post(title: "Test Post")
      post.permalink.should eql("test-post")
    end
  end

  context "status" do
    it "can be unpublished for new post" do
      create_post.status.should eql("unpublished")
    end

    it "can be published after post is published" do
      create_post(publish: true).status.should eql("published")
    end
  end

  it "have images" do
    create_post.should have(0).images
  end

  it "have comment" do
    create_post.should have(0).comments
  end

  context "when publishing" do
    it "save publish date" do
      post = create_post(publish: true)
      post.published_on.to_date.should eql(Date.today)
    end

    it "dosnt change publish date, unless publish is changed" do
      post = create_post(publish: true)
      post.update_attribute(:published_on, Date.new(2011,1,1))
      post.published_on.to_date.should eql(Date.new(2011,1,1))
    end

    it "remove publish date when unpublished" do
      post = create_post(publish: true)
      post.update_attribute(:publish, false)
      post.published_on.should be_nil
    end

    it "find published" do
      2.times { create_post(publish: true) }
      Spree::Post.published.should have(2).posts
    end
  end

  describe "tagging" do
    it "is taggable" do
      post = create_post(tag_list: "awesome,cool")
      post.tag_list.should have(2).tags
    end

    it "find by tags" do
      2.times { create_post(tag_list: "awesome,cool") }
      Spree::Post.tagged_with("awesome").should have(2).posts
    end
  end

  context "finding" do
    it "find by year" do
      create_post(publish: true)
      Post.by_date(Date.today.year).should have(1).posts
    end

    it "find by month" do
      create_post(publish: true)
      post = create_post(publish: true)
      post.update_attribute(:published_on, Date.today.advance(months: 1))
      Post.by_date(Date.today.year, Date.today.month).should have(1).posts
    end

    it "find by day" do
      create_post(publish: true)
      post = create_post(publish: true)
      post.update_attribute(:published_on, Date.today.advance(days: 1))
      Spree::Post.by_date(Date.today.year, Date.today.month, Date.today.day).should have(1).posts
    end
  end

  it "group by dates" do
    create_post(title: "january post",   publish: true, published_on: Date.new(2010,01,01))
    create_post(title: "january post 2", publish: true, published_on: Date.new(2010,01,01))
    create_post(title: "january post",   publish: true, published_on: Date.new(2010,02,01))
    create_post(title: "january post 2", publish: true, published_on: Date.new(2011,03,05))

    group = Spree::Post.published.group_dates

    group.should_not be_empty
    group.first.first.should eql(2011)

    month = group.first[1][0][0]
    month.to_date.should eql(Date.new(2011,03,01))
  end

  def create_post(options={})
    post = Spree::Post.create({ title: "test" }.merge(options))
    if options.key?(:published_on)
      post.published_on = options[:published_on]
      post.save
    end
    post
  end
end
