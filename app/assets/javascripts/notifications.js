var check_notifications = function () {
    $.ajax({
        url: "/notifications/has_any"
    }).done(function (response) {
        if (response.has_unread_notifications) {
            $('#notification-alert').show();
        }
    });
};

$(document).on('turbolinks:load', function () {
    check_notifications();
    setInterval(check_notifications, 60000);
});

