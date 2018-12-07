# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

enableSSHKeyField = ->
  sshKeyField= $('#sshKeyField')[0];
  console.log(sshKeyField);
  sshKeyField.disabled = false;
