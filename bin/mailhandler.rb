#!/usr/bin/env ruby
#
# mailhandler.rb
#
# This handler has been written after giving up on getting
# sensu-plugins-mailer to work. Make configuration simpler
# and less dependent on json. Not many bells and whistles.
# Easy to set email addresses and get mail off.
# Code has been unscrupulously copied from sensu-plugins-mailer.
# 
#
# OUTPUT:
# Sends an email.
#
#
# USAGE:
# Configutation is prioritized as follows:
# 
# - command line parameters are prioritized first
# - json config, ie. configuration files seconf
# - Potential check settings last
#
#
# PLATFORM:
# Any with ruby.
#
#
# DEPENDENCIES: 
#
# gem: erubis
# gem: json
# gem: mail
# gem: sensu-plugin
#
#
# LICENSE:
# Copyright © 2016 Lars Bahner <<lars.bahner@gmail.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'sensu-handler'
require 'json'
require 'mail'
require 'erubis'

$fqdn = %x(hostname -f)

class Mailhandler < Sensu::Handler

  option  :body_template,
          description: 'Optional body template (erb) to use for generating message body.',
          short: '-b body_template_file',
          long: '--body-template body_template_file',
          required: false
 
  option  :from,
          description: 'Define sender of email',
          short: '-f sender',
          long: '--from sender',
          required: false

  option  :json_config,
          description: 'Configuration name',
          short: '-j JSONconfig',
          long: '--json-config JSONconfig',
          required: false,
          default: 'mailhandler'

  option  :smtp_host,
          description: 'SMTP host to connect to for sending email',
          short: '-h smtp host',
          long: '--host smtp host',
          required: false

  option  :smtp_port,
          description: 'Port to connect smtp host on',
          short: '-p smtp port',
          long: '--port smtp port',
          required: false

  option  :to,
          description: 'comma separated list of recipient',
          short: '-t recipient',
          long: '--to recipient',
          required: false
  
  # Set sane defaults
  default = Hash.new

  default['from']       = 'root@' + $fqdn,
  default['to']         = 'lars.bahner@gmail.com',
  default['smtp_host']  = 'localhost',
  default['smtp_port']  = '25'
  default['subject']    = 'Sensu@' + @event['client']['name'] + ': ' + status_text

  def status_text
    case @event['check']['status']
      when 0
        'OK'
      when 1
        'WARNING'
      when 2
        'CRITICAL'
      else
        'UNKNOWN'
    end
  end

  def get_setting(name)
    if config[name]
      config[name]
    elsif settings[config[:json_config][name]]
      settings[config[:json_config][name]]
    elsif @event['check'][name]
      @event['check'][name]
    else
      default[name]
    end
  end

  def body
    erb_template = if self.get_setting(body_template) && File.readable?(self.get_setting(body_template))
      File.read(body_template)
    else
      <<-BODY
        Status: <%= status_text %>
        Check: <%= @event['client']['name'] %>/<%= @event['check']['name'] %>
        Timestamp: <%= Time.at(@event['check']['issued']) %>
        Occurences: <%= @event['occurrences'] %>
        
        It's all in a days work for System Control™.

        --
        <%= output %>
      BODY
    template = Erubis.new(erb_template)
    template.result(binding)
  end

  def handle

    self.get_setting(to).each do |recipient|
      mail = Mail.new do
        from    self.get_setting(from)
        to      recipient
        subject self.get_setting(subject)
        body    self.body()
        delivery_method :smtp, self.get_setting(smtp_host), self.get_setting(smtp_port)
      end

      mail.deliver!
    end
  end
end

puts "hello"
