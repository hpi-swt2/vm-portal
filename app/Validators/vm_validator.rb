# frozen_string_literal: true

class VmValidator < SimpleDelegator
  include ActiveModel::Validations

  validates :cpu_cores, numericality: { only_integer: true, greater_than_or_equal_to: :min_cpu_cores, less_than_or_equal_to: :max_cpu_cores }
  validates :ram_gb, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: :max_ram_size }
  validates :storage_gb, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: :max_storage_size }

  def validate(post)
    self.__setobj__(post)
    super

    post.errors.messages.merge!(self.errors.messages)
  end

  def min_cpu_cores
    AppSetting.instance.min_cpu_cores
  end

  def max_cpu_cores
    AppSetting.instance.max_cpu_cores
  end

  def max_ram_size
    AppSetting.instance.max_ram_size
  end

  def max_storage_size
    AppSetting.instance.max_storage_size
  end
end
