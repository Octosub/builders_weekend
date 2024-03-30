class RoomsController < ApplicationController
  require 'net/http'
  require 'uri'

  def index
    @rooms = Room.all
  end

  def show
    @room = Room.find(params[:id])
  end

  def new
    @room = Room.new
  end

  def img_to_video
    require 'net/http/post/multipart'

    uri = URI('https://api.stability.ai/v2beta/image-to-video')

    filepath = Rails.root.join('app', 'assets', 'images', 'instabase_img2.png')

    request = Net::HTTP::Post::Multipart.new(uri.path, {
      'image' => UploadIO.new(File.open(filepath), 'image/png', 'image.png')
    })
    request['authorization'] = 'Bearer sk-yfgygN4lz6calwx3My3vNucN9AEic1xp4JLE6JWnf3j0FqJ9'


    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
    return JSON.parse(response.body)["id"]
  end

  def get_video(id)
    url = URI("https://api.stability.ai/v2beta/image-to-video/result/#{id}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request['Authorization'] = 'Bearer sk-yfgygN4lz6calwx3My3vNucN9AEic1xp4JLE6JWnf3j0FqJ9'
    request['accept'] = 'video/*'

    response = http.request(request)

    File.open("output.mp4", "wb") do |file|
      file.write(response.body)
    end
  end

  def create
    room = Room.new(room_params)

    id = img_to_video

    room.description = get_video(id)

    if room.save
      redirect_to room_path(room)
    else
      render :new, status: :unprocessable_entity
    end
  end


  private

  def room_params
    params.require(:room).permit(:name, :description, photos: [])
  end
end
