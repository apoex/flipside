require 'forwardable'

class FeaturePresenter
  extend Forwardable
  attr_reader :feature, :base_path

  def_delegators :@feature, :name, :description, :enabled, :activated_at, :deactivated_at

  def initialize(feature, base_path)
    @feature = feature
    @base_path = base_path
  end

  def href
    File.join(base_path, "feature", name)
  end

  def toggle_href
    File.join(href, "toggle")
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
end
