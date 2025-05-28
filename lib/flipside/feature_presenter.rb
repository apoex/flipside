require 'forwardable'

class FeaturePresenter
  extend Forwardable
  attr_reader :feature

  def_delegators :@feature, :name, :description, :enabled, :entities, :roles

  def initialize(feature)
    @feature = feature
  end

  def status
    if feature.active?
      "active"
    else
      "inactive"
    end
  end

  def status_color
    if feature.active?
      deactivates_soon? ? "bg-orange-600" : "bg-green-600"
    elsif activates_soon?
      "bg-yellow-600"
    else
      "bg-zinc-600"
    end
  end

  def switch_color
    return "bg-blue-700" if feature.enabled

    if (feature.entities.count + feature.roles.count) > 0
      "bg-blue-300"
    else
      "bg-gray-200"
    end
  end

  def activated_at
    feature.activated_at&.strftime("%Y-%m-%d %H:%M")
  end

  def deactivated_at
    feature.deactivated_at&.strftime("%Y-%m-%d %H:%M")
  end

  def activates_soon?(period = 60 * 60 * 24)
    return false if feature.active?
    return false if feature.activated_at.nil?

    feature.activated_at <= Time.now + period
  end

  def deactivates_soon?(period = 60 * 60 * 24)
    return false unless feature.active?
    return false if feature.deactivated_at.nil?

    feature.deactivated_at <= Time.now + period
  end

  def status_title
    if activates_soon?
      "Activates at: #{activated_at}"
    elsif deactivates_soon?
      "deactivates at: #{deactivated_at}"
    end
  end

  def entity_count_str
    count = feature.entities.count
    if count == 1
      "Enabled for one entity"
    elsif count.positive?
      "Enabled for #{count} entities"
    else
      ""
    end
  end

  def role_count_str
    count = feature.roles.count
    if count == 1
      "Enabled for one role"
    elsif count.positive?
      "Enabled for #{count} roles"
    else
      ""
    end
  end
end
