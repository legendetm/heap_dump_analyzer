module ApplicationHelper
  def bootstrap_flash_type(type)
    case type
    when 'notice'
      'success'
    when 'alert'
      'warning'
    else
      type.to_s
    end
  end
end
