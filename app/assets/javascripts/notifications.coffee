# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

callback =->
  console.log("Hello World")
  $.ajax(url: "/notifications/has_any").done (response) ->
    if(response.has_unread_notifications)
      $('#notification-alert').show()

$(document).on 'turbolinks:load', ->
  console.log("Hello There")
  callback()
  setInterval(callback, 60000)

