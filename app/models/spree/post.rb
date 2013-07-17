class Spree::Post < ActiveRecord::Base
  make_permalink
  acts_as_taggable
  paginates_per 10

  attr_accessible :title

  has_many :comments, dependent: :destroy, class_name: 'Spree::Comment'

  validates :title, presence: true

  before_save :check_published

  default_scope { includes(:tags).order('publish, published_on DESC') }
  scope :published, -> { where publish: true }

  def self.by_date(year, month=nil, day=nil)
    start_date = Date.new(year, month || 1, day || 1)
    end_date = nil

    if day
      end_date = start_date.advance(days: 1)
    elsif month
      end_date = start_date.advance(months: 1)
    else
      end_date = start_date.advance(years: 1)
    end

    where('published_on BETWEEN ? AND ?', start_date, end_date)
  end

  def self.group_dates
    select('published_on, title, permalink').
      group_by {|post| post.published_on.to_date.advance(days: -(post.published_on.day-1)) }.
      group_by {|date| date.first.year }
  end

  def status
    publish ? 'published' : 'unpublished'
  end

  def to_param
    return permalink unless permalink.blank?
    title.to_url
  end

  private

  def check_published
    return unless publish_changed?
    self.published_on = publish ? Time.now : nil
  end
end
