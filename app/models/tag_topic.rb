# == Schema Information
#
# Table name: tag_topics
#
#  id         :integer          not null, primary key
#  topic      :string           not null
#  created_at :datetime
#  updated_at :datetime
#

class TagTopic < ActiveRecord::Base
  validates :topic, presence: true, uniqueness: true

  has_many :taggings,
    class_name: :Tagging,
    primary_key: :id,
    foreign_key: :tag_id

  has_many :urls,
    ->{distinct},
    through: :taggings,
    source: :url
end
