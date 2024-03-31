class RoomsController < ApplicationController
  require 'net/http'
  require 'uri'
  require 'json'
  require 'open-uri'
  require 'fileutils'
  require 'rmagick'
  require 'net/http/post/multipart'

  def index
    @rooms = Room.all
  end

  def show
    @room = Room.find(params[:id])
    @video_filepath = @room.video_filepath
    counter = 0
    Dir.foreach(Rails.root.join('app', 'assets', 'images', "#{@room.name}")) do |photo|
      filepath = Rails.root.join('app', 'assets', 'images', "#{@room.name}", "#{counter}.jpg")
      video_path = Rails.root.join('app', 'assets', 'images', "#{@room.name}", "#{counter}.mp4")
      id = img_to_video(filepath)
      # img_to_video(filepath).write(video_path)
      get_video(id, video_path)
      counter += 1 if counter < 4
    end
  end

  def new
    @room = Room.new
  end

  def img_to_video(filepath)
    uri = URI('https://api.stability.ai/v2beta/image-to-video')

  #   uri = URI('https://api.stability.ai/v2beta/image-to-video')

  #   filepath = Rails.root.join('app', 'assets', 'images', 'instabase_img2.png')

  #   request = Net::HTTP::Post::Multipart.new(uri.path, {
  #     'image' => UploadIO.new(File.open(filepath), 'image/png', 'image.png')
  #   })
   # request['authorization'] = ENV['STABILITY_TOKEN']
    request = Net::HTTP::Post::Multipart.new(uri.path, {
        'image' => UploadIO.new(File.open(filepath), 'image/jpg', 'image.jpg')
      })
    request['authorization'] = ENV['STABILITY_TOKEN']

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
    JSON.parse(response.body)["id"]
  end

  def get_video(id, file_path)
    url = URI("https://api.stability.ai/v2beta/image-to-video/result/#{id}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request['Authorization'] = ENV['STABILITY_TOKEN']
    request['accept'] = 'video/*'

    response = http.request(request)
    # file_path = Rails.root.join('app', 'assets', 'videos', "#{id}.mp4")

    case response.code.to_i
    when 202
      puts "Still processing. Retrying in 10 seconds..."
      sleep(10)
      get_video(id)
    when 200
      File.open(file_path, 'wb') { |file| file.write(response.body) }
      puts "Success: Video saved to #{file_path}"
    when 400..599
      File.open('./error.json', 'wb') { |file| file.write(response.body) }
      puts "Error: Check ./error.json for details."
    end
    # file_path
  end

  def create
    room = Room.new(room_params)
    url = "https://ece1-152-165-122-193.ngrok-free.app/"
    user_serialized = URI.open(url).read
    user = JSON.parse(user_serialized)
    room_data = user.find { |hash| hash["room_id"] == room.name }

    room_data["images"].each_with_index do |image, index|
      crop_image("https://www.instabase.jp#{image}", index, room)
    end

    if room.save
      redirect_to room_path(room)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def crop_image(image_url, photo_id, room)
    image = Magick::Image.read(image_url).first
    cropped_image = image.crop(0, 0, image.columns, image.rows)
    resized_image = cropped_image.resize_to_fill(1024, 576)
    # Define the new directory path
    new_directory_path = Rails.root.join('app', 'assets', 'images', "#{room.name}")
    # Create the new directory
    FileUtils.mkdir_p(new_directory_path) unless File.directory?(new_directory_path)
    filepath = Rails.root.join('app', 'assets', 'images', "#{room.name}", "#{photo_id}.jpg")
    # resized_image.write(new_directory_path)
    resized_image.write(filepath)
  end

  private

  def room_params
    params.require(:room).permit(:name, :description, photos: [])
  end
end


  # def crop_image(image_url, room_id)
  #   image = Magick::Image.read(image_url).first
  #   cropped_image = image.crop(0, 0, image.columns, image.rows)
  #   resized_image = cropped_image.resize_to_fill(1024, 576)
  #   # Define the new directory path
  #   new_directory_path = Rails.root.join('app', 'assets', 'images', "#{@room.id}")
  #   # Create the new directory
  #   FileUtils.mkdir_p(new_directory_path) unless File.directory?(new_directory_path)
  #   filepath = Rails.root.join('app', 'assets', 'images', "#{@room.id}", "#{room_id}.jpg")
  #   # resized_image.write(new_directory_path)
  #   resized_image.write(filepath)
  # end

      # directory_path = Rails.root.join('app', 'assets', 'images', "#{@room.name}")
    # Dir.foreach(directory_path) do |photo|
    #   filepath = Rails.root.join('app', 'assets', 'images', "#{@room.name}", "#{counter}.jpg")
    #   # img_to_video(filepath)
    #   counter += 1
    # end
