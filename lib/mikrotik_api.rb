# app/lib/mikrotik_api.rb
require 'socket'

class MikrotikApi
  def initialize(host, username, password, port = 8728)
    @host = host
    @username = username
    @password = password
    @port = port
    @socket = nil
  end

  def connect
    begin
      @socket = TCPSocket.new(@host, @port)
      login
    rescue => e
      Rails.logger.error "MikroTik API connection failed: #{e.message}"
      false
    end
  end

  def disconnect
    @socket&.close
  end

  def execute(command, attributes = {})
    return false unless @socket

    send_command(command, attributes)
    read_response
  end

  private

  def login
    send_command('/login', { 'name' => @username, 'password' => @password })
    response = read_response
    response&.any? { |item| item['!done'] }
  end

  def send_command(command, attributes = {})
    @socket.write(encode_length(command.length) + command)
    
    attributes.each do |key, value|
      param = "=#{key}=#{value}"
      @socket.write(encode_length(param.length) + param)
    end
    
    @socket.write("\x00") # End of command
  end

  def read_response
    response = []
    loop do
      length = decode_length
      break if length == 0
      
      sentence = @socket.read(length)
      response << parse_sentence(sentence)
      break if sentence.start_with?('!done')
    end
    response
  end

  def encode_length(length)
    if length < 0x80
      [length].pack('C')
    elsif length < 0x4000
      [(length | 0x8000)].pack('n')
    elsif length < 0x200000
      [(length | 0xC00000)].pack('N')[1..-1]
    elsif length < 0x10000000
      [(length | 0xE0000000)].pack('N')
    else
      "\xF0" + [length].pack('N')
    end
  end

  def decode_length
    first_byte = @socket.read(1).unpack('C').first
    return 0 if first_byte.nil?

    if first_byte < 0x80
      first_byte
    elsif first_byte < 0xC0
      second_byte = @socket.read(1).unpack('C').first
      ((first_byte & 0x7F) << 8) + second_byte
    # Add more length decoding cases as needed
    else
      # Handle longer lengths
      0
    end
  end

  def parse_sentence(sentence)
    # Parse MikroTik API sentence format
    # This is a simplified version - you might want to use a proper gem
    { sentence.split('=').first => sentence }
  end
end