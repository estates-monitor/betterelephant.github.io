require 'bundler/setup'
require 'sinatra/base'

# The project root directory
$root = ::File.dirname(__FILE__)

class SinatraStaticServer < Sinatra::Base  

  get(/.+/) do
    send_sinatra_file(request.path) {404}
  end

  not_found do
    send_sinatra_file('404.html') {"Sorry, I cannot find #{request.path}"}
  end

  def send_sinatra_file(path, &missing_file_block)
    file_path = File.join(File.dirname(__FILE__), 'public',  path)
    file_path = File.join(file_path, 'index.html') unless file_path =~ /\.[a-z]+$/i  
    File.exist?(file_path) ? send_file(file_path) : missing_file_block.call
  end

helpers do

    def protected!
          unless authorized?
                 response['WWW-Authenticate'] = %(Basic realm="Testing HTTP Auth")
                  throw(:halt, [401, "Not authorized\n"])
               end
            end

    def authorized?
          @auth ||=  Rack::Auth::Basic::Request.new(request.env)
          @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['iglasspool', 'likewise']
     end

end


end

run SinatraStaticServer
