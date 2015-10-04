ipc = require 'ipc'
remote = require 'remote'

EventEmitter = require('events').EventEmitter
desktopCapturer = new EventEmitter

# Tells main process the renderer is requiring 'desktop-capture' module.
ipc.sendSync 'ATOM_BROWSER_DESKTOP_CAPTURER_REQUIRED'

desktopCapturer.getSource = (index) ->
  ipc.sendSync 'ATOM_BROWSER_DESKTOP_CAPTURER_GET_SOURCE', index

desktopCapturer.startUpdating = (args) ->
  ipc.send 'ATOM_BROWSER_DESKTOP_CAPTURER_START_UPDATING', args

desktopCapturer.stopUpdating = (args) ->
  ipc.send 'ATOM_BROWSER_DESKTOP_CAPTURER_STOP_UPDATING', args

for event_name in ['source-added', 'source-removed', 'source-moved', 'source-name-changed', "source-thumbnail-changed"]
  do (event_name) ->
    ipc.on event_name, (args) ->
      desktopCapturer.emit event_name, args

module.exports = desktopCapturer
