class RoomsController < ApplicationController
  require 'net/http'
  require 'uri'
  require 'rmagick'

  def index
    @rooms = Room.all
  end

  def show
    @room = Room.find(params[:id])
    @video_filepath = @room.video_filepath
    crop_image("https://www.instabase.jp/imgs/r/uploads/room_image/image/264346/161a9f02-e69a-45ec-96a2-87aa5cb208f7.jpg.medium.jpeg")
  end

  def new
    @room = Room.new
  end

  # def img_to_video
  #   require 'net/http/post/multipart'

  #   uri = URI('https://api.stability.ai/v2beta/image-to-video')

  #   filepath = Rails.root.join('app', 'assets', 'images', 'instabase_img2.png')

  #   request = Net::HTTP::Post::Multipart.new(uri.path, {
  #     'image' => UploadIO.new(File.open(filepath), 'image/png', 'image.png')
  #   })
  #   request['authorization'] = 'Bearer sk-kFXejOyVsFzonoMIiYYhqelsAdhRPnlFuxnnG0Pa4W12KaG8'


  #   response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  #     http.request(request)
  #   end
  #   return JSON.parse(response.body)["id"]
  # end

  # def get_video(id)
  #   url = URI("https://api.stability.ai/v2beta/image-to-video/result/#{id}")

  #   http = Net::HTTP.new(url.host, url.port)
  #   http.use_ssl = true

  #   request = Net::HTTP::Get.new(url)
  #   request['Authorization'] = 'Bearer sk-yfgygN4lz6calwx3My3vNucN9AEic1xp4JLE6JWnf3j0FqJ9'
  #   request['accept'] = 'video/*'

  #   response = http.request(request)
  #   file_path = Rails.root.join('app', 'assets', 'videos', "#{id}.mp4")

  #   case response.code.to_i
  #   when 202
  #     puts "Still processing. Retrying in 10 seconds..."
  #     sleep(10)
  #     get_video(id)
  #   when 200
  #     File.open(file_path, 'wb') { |file| file.write(response.body) }
  #     puts "Success: Video saved to #{file_path}"
  #   when 400..599
  #     File.open('./error.json', 'wb') { |file| file.write(response.body) }
  #     puts "Error: Check ./error.json for details."
  #   end
  #   return file_path
  # end

  def create
    room = Room.new(room_params)
    # crop_image("https://www.instabase.jp/imgs/r/uploads/room_image/image/264346/161a9f02-e69a-45ec-96a2-87aa5cb208f7.jpg.medium.jpeg")

    # id = img_to_video

    # room.video_filepath = get_video(id)

    if room.save
      redirect_to room_path(room)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def crop_image(image_url)
    # Load the image into ImageMagick
    filepath = Rails.root.join('app', 'assets', 'images', 'new_image.jpg')

    image = Magick::Image.read(image_url).first
    # image = Magick::Image.read(image_url).first

    # Crop the image
    cropped_image = image.crop(0, 0, image.columns, image.rows)

    # Resize the image
    resized_image = cropped_image.resize_to_fill(1024, 576)

    # Write the image back to a file
    resized_image.write(filepath)
  end

  private

  def room_params
    params.require(:room).permit(:name, :description, photos: [])
  end
end
