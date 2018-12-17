# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

callback =->
  $.ajax(url: "/notifications/has_any").done (response) ->
    if(response.has_unread_notifications)
      $('#notification-alert').show()

$(document).on 'turbolinks:load', ->
  callback()
  setInterval(callback, 60000)

