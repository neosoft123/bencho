namespace "7am" do
  namespace "tunnel" do
    ######################################################################################
    ######################################################################################
    desc "Start a reverse tunnel to develop from localhost. Please ensure that you have a properly configured config/tunnel.yml file."
    task "start" => "environment" do
  
      remoteUsername = TUNNEL['username']
      remoteHost = TUNNEL['host']
      remotePort = TUNNEL['port']
      localPort = TUNNEL['local_port']
      sshPort = TUNNEL['ssh_port'] || "22"
  
      puts "======================================================"
      puts "Tunneling #{remoteHost}:#{remotePort} to 0.0.0.0:#{localPort}"
        
      puts
      puts "NOTES:"
      puts "* ensure that you have Rails running on your local machine at port #{localPort}"
      puts "* once logged in to the tunnel, you can visit http://#{remoteHost}:#{remotePort} to view your site"
      puts "* use ctrl-c to quit the tunnel"
      puts "* if you have problems creating the tunnel, you may need to add the following to /etc/ssh/sshd_config on your server:"
      puts "
    GatewayPorts clientspecified

    "
      puts "* if you have problems with #{remoteHost} timing out your ssh connection, add the following lines to your '~/.ssh/config' file:"
      puts "
    Host #{remoteHost}
    ServerAliveInterval 120

    "
      puts "======================================================"
      exec "ssh -p #{sshPort} -nNT -g -R *:#{remotePort}:0.0.0.0:#{localPort} #{remoteUsername}@#{remoteHost}"
    end
  end
end