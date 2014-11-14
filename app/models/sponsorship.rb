class Sponsorship < ActiveRecord::Base

  MAX_FAILED_REQUESTS = 2
  MAX_SPONSORED_CAUSES = 3

  enum :status => [ :pending, :accepted, :cancelled ]

  validates_presence_of :business
  validates_associated :business
  validate :is_business
  validate :no_current_pending_sponsorship
  validate :max_cancelled_requests
  validate :max_sponsored_causes

  belongs_to :business, :class_name => User
  belongs_to :cause, :class_name => User

  def is_business
    errors.add(:business, "Must be a business") unless self.business.role == :business
  end

  def no_current_pending_sponsorship
    if self.business.sponsorships.where.not(:id => self.id).exists?(:status => Sponsorship.statuses[:pending], :cause_id => self.cause.id)
      errors.add(:business, "A sponsorship request has already been created for this cause.")
    end
  end

  def max_sponsored_causes
    if (self.business.sponsorships + [self]).uniq.size > MAX_SPONSORED_CAUSES
      errors.add(:business, "A business can sponsor at most #{MAX_SPONSORED_CAUSES} causes.")
    end
  end

  def max_cancelled_requests
    if self.business.sponsorships.where.not(:id => self.id).where(:status => Sponsorship.statuses[:cancelled], :cause_id => self.cause.id).count >= MAX_FAILED_REQUESTS
      errors.add(:business, "You can request sponsorship at most #{MAX_FAILED_REQUESTS} times.")
    end
  end

  def business_name
    self.business.company_name
  end

  def cause_name
    self.cause.company_name
  end

end
