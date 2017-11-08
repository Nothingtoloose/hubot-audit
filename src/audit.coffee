# Description
#   log all hubot interaction to an audit channel
#
# Configuration:
#   AUDIT_CHANNEL - the room for hubot to log all interaction to.
#
# Commands:
#   None  
#
# Notes:
#   set your AUDIT_CHANNEL to "moderated" to avoid noise
#   configure hubot to join that channel
#
# Author:
#   BuJo
#   cy4n
#   Christian Koehler


AUDIT_CHANNEL = process.env.AUDIT_CHANNEL

module.exports = (robot) ->
  # log hubot commands, with issuer and chatroom
  robot.listenerMiddleware (context, next, done) ->
    match = /^\@Hubot+/i.test(context.response.message.text) or /^\Hubot+/i.test(context.response.message.text)
    
    room = context.response.message.user.room_name
    issuer = context.response.message.user.name
    cmd = context.response.message.text
    switch room
      when 'Shell' # for interactive testing
        robot.logger.info "| listenerMiddleware: #{room}: <#{issuer}> #{cmd}"
      when AUDIT_CHANNEL # ignore AUDIT_CHANNEL to avoid recursion
      else
        if match
          robot.messageRoom(AUDIT_CHANNEL, "#{room}: <#{issuer}> #{cmd}")
        else
          
    next()

  # log hubot's answer for the command that hubot listened to earlier
  robot.responseMiddleware (context, next, done) ->
    #match = /^\@Hubot+/i.test(context.response.message.text) or /^\Hubot+/i.test(context.response.message.text)
    #if match 
    return unless context.plaintext?
    switch context.response.envelope.room
      when 'Shell' #for interactive testing
        robot.logger.info "| responseMiddleware:" + context.strings[0]
      when AUDIT_CHANNEL # ignore AUDIT_CHANNEL to avoid recursion
      else
        robot.messageRoom(AUDIT_CHANNEL, s) for s in context.strings

    next()

