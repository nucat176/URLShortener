# == Schema Information
#
# Table name: taggings
#
#  id               :integer          not null, primary key
#  tag_id           :integer          not null
#  shortened_url_id :integer          not null
#  created_at       :datetime
#  updated_at       :datetime
#

class Tagging < ActiveRecord::Base
  validates :tag_id, presence: true
  validates :shortened_url_id, presence: true

  belongs_to :tag,
    class_name: :TagTopic,
    primary_key: :id,
    foreign_key: :tag_id

  belongs_to :url,
    class_name: :ShortenedUrl,
    primary_key: :id,
    foreign_key: :shortened_url_id
end
