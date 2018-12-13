# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

editButtonId = '#editSshKey';
sshKeyFieldId = '#sshKeyField';
saveButtonsId = '#saveButtons';
cancelButtonId = '#cancelEditButton';
oldSSHValue = ''

turnEditViewOn = ->
  saveOldSSHValue()
  enableSSHKeyField()
  enableEditViewButtons()

saveOldSSHValue = ->
  sshKeyField= $(sshKeyFieldId);
  oldSSHValue = sshKeyField.val();


enableSSHKeyField = ->
  sshKeyField= $(sshKeyFieldId)[0];
  sshKeyField.disabled = false;

enableEditViewButtons = ->
  sshKeyEditButton = $(editButtonId);
  sshKeyEditButton.addClass('d-none');
  saveButtons = $(saveButtonsId)
  saveButtons.removeClass('d-none');

turnEditViewOff = ->
  resetSSHKeyField()
  disableSSHKeyField()
  disableEditViewButton()

resetSSHKeyField = ->
  sshKeyField= $(sshKeyFieldId);
  sshKeyField.val(oldSSHValue)

disableSSHKeyField = ->
  sshKeyField= $(sshKeyFieldId)[0];
  sshKeyField.disabled = true;

disableEditViewButton = ->
  sshKeyEditButton = $(editButtonId);
  sshKeyEditButton.removeClass('d-none');
  saveButtons = $(saveButtonsId)
  saveButtons.addClass('d-none');

$(document).on('click', editButtonId, ( ->
  turnEditViewOn()
));

$(document).on('click', cancelButtonId, ( ->
  turnEditViewOff()
))
