class Post < ApplicationRecord
  validates :content, presence: true, length: { maximum: 1000,
                                                too_long: '1000 characters in post is the maximum allowed.' }

  belongs_to :user

  scope :ordered_by_most_recent, -> { order(created_at: :desc) }
  scope :join_friends, lambda {
                         joins('INNER JOIN users on users.id = posts.user_id LEFT JOIN friendships ON
      (friendships.user_id = users.id OR friend_id = users.id) ')
                       }

  scope :friends_post, lambda { |id|
    join_friends.where("((friendships.user_id= ? OR friendships.friend_id= ?) AND status='connected')
     OR users.id = #{id}", id, id).group('posts.id, users.id').ordered_by_most_recent
  }

  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
end
