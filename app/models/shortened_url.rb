# == Schema Information
#
# Table name: shortened_urls
#
#  id         :integer          not null, primary key
#  long_url   :string           not null
#  short_url  :string           not null
#  owner_id   :integer          not null
#  created_at :datetime
#  updated_at :datetime
#
require 'byebug'
class ShortenedUrl < ActiveRecord::Base
  validates :short_url, presence: true, uniqueness: true
  validates :owner_id, presence: true
  validates :long_url, presence: true

  validate :long_length, :too_many_requests

  belongs_to :submitter,
    class_name: :User,
    primary_key: :id,
    foreign_key: :owner_id

  has_many :visits,
    class_name: :Visit,
    primary_key: :id,
    foreign_key: :shortened_url_id

  has_many :visitors,
    -> { distinct },  # replaces Proc.new { distinct }
    through: :visits,
    source: :visitor

  has_many :taggings,
    class_name: :Tagging,
    primary_key: :id,
    foreign_key: :shortened_url_id

  has_many :tags,
    -> {distinct},
    through: :taggings,
    source: :tag

  def long_length
    errors[:long_url] << 'is too long' if long_url.length > 1024
  end

  def too_many_requests
    recent_reqs =     self.visits.select(:user_id)
            .where(["user_id > ? AND updated_at > ? ", owner_id, 5.minutes.ago])
            .distinct.count
    errors[:too_many_recent] << "requests, please wait."  if recent_reqs > 5
  end

  def self.random_code
    code = SecureRandom.urlsafe_base64
    while ShortenedUrl.exists?(short_url: code)
      code = SecureRandom.urlsafe_base64
    end
    code
  end

  def self.create_for_user_and_long_url!(user, long_url)
    debugger
    short_url = ShortenedUrl.random_code
    ShortenedUrl.create!(long_url: long_url, short_url: short_url, owner_id: user.id)
  end

  def num_clicks
    self.visitors.count
  end

  def num_uniques
    self.visits.select(:user_id).distinct.count
  end

  def num_recent_uniques
    self.visits.select(:user_id)
        .where(["updated_at > ?", 10.minutes.ago])
        .distinct.count
  end


end
