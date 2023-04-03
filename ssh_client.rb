# https://github.com/hirura/hrr_rb_ssh#writing-standard-ssh-server

require 'hrr_rb_ssh'

options = Hash.new
options['transport_server_secret_host_keys'] = {}
options['transport_server_secret_host_keys']['ecdsa-sha2-nistp256'] = <<-'EOB'
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIFFtGZHk6A8anZkLCJan9YBlB63uCIN/ZcQNCaJout8loAoGCCqGSM49
AwEHoUQDQgAEk8m548Xga+XGEmRx7P71xGlxCfgjPj3XVOw+fXPXRgA03a5yDJEp
OfeosJOO9twerD7pPhmXREkygblPsEXaVA==
-----END EC PRIVATE KEY-----
EOB

# # Allow password authentication
# auth_password = HrrRbSsh::Authentication::Authenticator.new { |context|
# user_and_pass = [
#     ['rtest',  'rword'],
# ]
# user_and_pass.any? { |user, pass|
# context.verify user, pass
# }
# }
# options['authentication_password_authenticator'] = auth_password
# puts "test"
# puts Dir.home
# puts "test"
# #authorized keys
# auth_publickey = HrrRbSsh::Authentication::Authenticator.new { |context|
#   username = ENV['USER']
#   puts Dir.home
#   authorized_keys = HrrRbSsh::Compat::OpenSSH::AuthorizedKeys.new(File.read(File.join(Dir.home, '.ssh', 'authorized_keys')))
#   authorized_keys.any?{ |public_key|
#     context.verify username, public_key.algorithm_name, public_key.to_pem
#   }
# }
# options['authentication_publickey_authenticator'] = auth_publickey

auth_none = HrrRbSsh::Authentication::Authenticator.new { |context|
  if context.username == 'user1'
    true
  else
    false
  end
}
options['authentication_none_authenticator'] = auth_none

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