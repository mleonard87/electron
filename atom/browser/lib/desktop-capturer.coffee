ipc = require 'ipc'
BrowserWindow = require 'browser-window'
EventEmitter = require('events').EventEmitter

desktopCapturer = process.atomBinding('desktop_capturer').desktopCapturer
desktopCapturer.__proto__ = EventEmitter.prototype


getWebContentsFromId = (id) ->
  windows = BrowserWindow.getAllWindows()
  return window.webContents for window in windows when window.webContents?.getId() == id

webContentsIds = new Set

ipc.on 'ATOM_BROWSER_DESKTOP_CAPTURER_REQUIRED', (event) ->
  id = event.sender.getId()
  webContentsIds.add id
  getWebContentsFromId(id).on 'destroyed', ()->
    webContentsIds.delete id
    if webContentsIds.size is 0
      desktopCapturer.stopUpdating()

  event.returnValue = 'done'

ipc.on 'ATOM_BROWSER_DESKTOP_CAPTURER_START_UPDATING', (event, args) ->
  desktopCapturer.startUpdating args

ipc.on 'ATOM_BROWSER_DESKTOP_CAPTURER_STOP_UPDATING', (event) ->
  desktopCapturer.stopUpdating()

ipc.on 'ATOM_BROWSER_DESKTOP_CAPTURER_GET_SOURCE', (event, index) ->
  event.returnValue = desktopCapturer.getSource index

for event_name in ['source-added', 'source-removed', 'source-moved', 'source-name-changed', "source-thumbnail-changed"]
  do (event_name) ->
    desktopCapturer.on event_name, (event, args)->
      webContentsIds.forEach (id) ->
        getWebContentsFromId(id).send event_name, args
