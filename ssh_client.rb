require 'hrr_rb_ssh'

options = Hash.new
options['authentication_password_authenticator'] = auth_password
server = TCPServer.new 3001
loop do
  Thread.new(server.accept) do |io|
    pid = fork do
      begin
        server = HrrRbSsh::Server.new options
        server.start io
      ensure
        io.close
      end
    end
    io.close
    Process.waitpid pid
  end
end