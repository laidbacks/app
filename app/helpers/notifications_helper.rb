module NotificationsHelper
  def notification_type_icon(type)
    case type&.to_s
    when "email"
      "fa-envelope"
    when "push"
      "fa-bell"
    when "sms"
      "fa-comment-sms"
    else
      "fa-bell"
    end
  end
end
