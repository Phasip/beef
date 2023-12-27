#
# Copyright (c) 2006-2024 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Etag_client < BeEF::Core::Command
  def self.options
    [
      { 'name' => 'payload_name', 'ui_label' => 'Payload Name', 'type' => 'text', 'width' => '400px', 'value' => 'etagTunnelPayload' },
      { 'name' => 'data', 'ui_label' => 'Message', 'type' => 'textarea',
        'value' => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ' \
                   'ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco ' \
                   'laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in ' \
                   'voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat ' \
                   'non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
        'width' => '400px', 'height' => '100px' }
    ]
  end

  def pre_send
    # gets the value configured in the module configuration by the user
    @configuration = BeEF::Core::Configuration.instance
    enable = @configuration.get('beef.extension.etag.enable')
    raise ArgumentError, 'etag extension is disabled' if enable != true

    @datastore.each do |input|
      @data = input['value'] if input['name'] == 'data'
    end
    BeEF::Extension::ETag::ETagMessages.instance.messages.store(@command_id.to_i, @data.unpack1('B*'))
  end

  def post_execute
    # gets the value of command_id from BeEF database and delete the message from Etag webserver "database"
    cid = @datastore['cid'].to_i
    BeEF::Extension::ETag::ETagMessages.instance.messages.delete(cid)
  end
end
