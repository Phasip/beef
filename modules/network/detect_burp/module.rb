#
# Copyright (c) 2006-2024 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_burp < BeEF::Core::Command
  def post_execute
    save({ 'result' => @datastore['result'] })

    configuration = BeEF::Core::Configuration.instance
    return unless configuration.get('beef.extension.network.enable') == true
    return unless @datastore['results'] =~ /^has_burp=true&response=PROXY ([\d.]+:\d+)/

    ip = Regexp.last_match(1).split(':')[0]
    port = Regexp.last_match(1).split(':')[1]
    session_id = @datastore['beefhook']
    hooked_browser = BeEF::Core::Models::HookedBrowser.where(session: session_id).first

    if BeEF::Filters.is_valid_ip?(ip)
      print_debug("Hooked browser found network service [ip: #{ip}, port: #{port}]")
      BeEF::Core::Models::NetworkService.create(hooked_browser: hooked_browser, proto: 'http', ip: ip, port: port, ntype: 'Burp Proxy')
    end
  end
end
