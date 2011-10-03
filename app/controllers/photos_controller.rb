class PhotosController < ApplicationController

  before_filter :get_photo, :only => [:show, :download]
  
  before_filter :ensure_authenticated_to_facebook, :only => [ :facebook_upload ]
  
  def flickr_upload
  #   photo = Photo.find(params[:id])
  #   flickr = Flickr.new(File.join(RAILS_ROOT, "config", "flickr.yml"))
  #   flickr.uploader.upload(photo.image, { :title => photo.caption })
  #   render :text => "OMFG IT WORKS!"
  # rescue => e
  #   render :text => "ERROR: #{e.message}"
  render :text => "NOTHING TO SEE HERE ... MOVE ALONG"
  end
  
  def facebook_upload
    photo = Photo.find(params[:id])
    file = Net::HTTP::MultipartPostFile.new(
      photo.image,
      nil,
      File.open(photo.image, 'r').read
    )    
    facebook_session.user.upload_photo(file, :caption => photo.caption)
    flash[:notice] = "<h3>Photo uploaded</h3>Your photo has been uploaded to Facebook. You will find it in your 7.am album." 
  rescue => e
    flash[:error] = "<h3>Photo upload failed</h3>Could not upload your photo to Facebook. Please try again."
  ensure
    redirect_to profile_photos_path(@p)
  end
  
  def index
    @photos = @profile.photos.paginate(:all, :page => @page, :per_page => 5)
    @photo = @profile.photos.new
    respond_to do |format|
      format.html
      format.rss {render :layout=>false}
      format.mobile
    end
  end
  
  def show
    respond_to do |format|
      format.html do
        redirect_to profile_photos_path(@profile)
      end
      format.mobile
    end
  end
  
  def download
    send_file @photo.image
  end
  
  def new 
    handle_facebook_auth if @u.settings.upload_photos_to_facebook? 
    @photo = @p.photos.new
  end
  
  
  def create
    @photo = @p.photos.new params[:photo]
    respond_to do |format|
      last_photo = @p.photos.first rescue nil
      logger.debug "LAST PHOTO: #{last_photo.nil? ? "NIL" : last_photo.caption}"
      if last_photo.nil? || (@photo.caption != last_photo.caption && @photo.image != last_photo.image)
        if @photo.save
         if @photo.caption.include?("ruby/object:Tempfile")
			   @photo.update_attribute(:caption,  "")
			  
	end 
         #flash[:notice] = 'Photo successfully uploaded.'
          format.mobile do
	           
	    if(params[:facebook_flag] == "1")
            if @u.settings.upload_photos_to_facebook?
              redirect_to facebook_photo_upload_path(@p, @photo)
           
           else
               flash[:notice] = 'Photo successfully uploaded.'
              redirect_to profile_photos_path(@p)
            end
	    else
              flash[:notice] = 'Photo successfully uploaded.'
              redirect_to profile_photos_path(@p)
            end
          end
        else
          flash.now[:error] = 'Photo could not be uploaded.'
          format.mobile do
            redirect_to profile_photos_path(@p)
          end
        end
      else
        format.mobile do
          redirect_to profile_photos_path(@p)
        end
      end
    end
  end
  
  
  def destroy
    Photo.destroy(params[:id]) rescue nil
    respond_to do |wants|
      wants.html do
        flash[:notice] = 'Photo was deleted.'
        redirect_to profile_photos_path(@p)
      end
      wants.mobile do
        flash[:notice] = "<h3>Your photo has been deleted</h3>Please note that photos " +
          "that have been uploaded to Facebook cannot be automatically deleted"
        redirect_to profile_photos_path(@p)
      end
    end
  end
  
  
  
  private
  
  def allow_to
    super :owner, :all => true
    super :friend, :only => [:index, :show, :download]
    super :user, :only => [:show, :index]
  end
    
  def get_photo
    @photo = @profile.photos.find(params[:id])
  end
  
end
