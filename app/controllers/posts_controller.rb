class PostsController < ApplicationController
  add_breadcrumb "Post List", :root_path

  # function : index
  # @return [<Type>] <posts>
  def index
    @posts = PostService.getAllPosts(current_user)
  end

  # function : show
  # show post
  # param : post_id
  # @return [<Type>] <post>
  def show
    add_breadcrumb "Post Detail", :post_path
    @post = PostService.getPostById(params[:id])
  end

  # function : new
  # show create post
  # @return [<Type>] <post>
  def new
    add_breadcrumb "Create Post", :new_post_path
    @post = Post.new
    # logger.info(@post)
  end

  # function : create
  # param : post_params
  # create post
  # @return redirect
  def create
    params[:post][:created_by] ||= current_user.id
    @post = Post.new(post_params)
    logger.info(post_params)
    @is_save_post = PostService.createPost(@post)
    if @is_save_post
      redirect_to posts_path
    else
      render :new
    end
  end

  # function : edit
  # param : post_id
  # show edit post
  # @return [<Type>] <post>
  def edit
    add_breadcrumb "Post Detail", :post_path
    add_breadcrumb "Edit Post", :edit_post_path
    @post = PostService.getPostById(params[:id])
  end

  # function : update
  # param : post_id, post_params
  # @return [<Type>] redirect
  def update
    @post = PostService.getPostById(params[:id])
    params[:post][:updated_by] = current_user.id
    @is_post_update = PostService.updatePost(@post, post_params)
    if @is_post_update
      redirect_to @post
    else
      render :edit
    end
  end

  # function : destory
  # delete post
  # param : post_id
  # @return [<Type>] redirect
  def destroy
    @post = PostService.getPostById(params[:id])
    PostService.destroyPost(@post)
    redirect_to root_path
  end

  def filter
    @filter_by = params[:filter_by]
    @user_id = current_user.id
    @posts = PostService.filter(@filter_by, @user_id)
    @last_filter_by = @filter_by
    render :index
  end

  def download_csv
    @posts = PostService.getAllPosts(current_user)
    @posts = @posts.reorder('id ASC')
    respond_to do |format|
      format.html
      format.csv { send_data @posts.to_csv,  :filename => "Post List.csv" }
    end
  end

  def upload_csv
    path = Rails.application.routes.recognize_path(request.path)
    logger.info('zzzzzzzzzzzzzzzzzzz')
    logger.info(path[:controller])
  end

  def import_csv
    if (params[:file].nil?)
      redirect_to upload_csv_path, notice: Messages::REQUIRE_FILE_VALIDATION
    elsif !File.extname(params[:file]).eql?(".csv")
      redirect_to upload_csv_path, notice: Messages::WRONG_FILE_TYPE
    else
      error_msg = PostsHelper.check_header(Constants::POST_CSV_HEADER,params[:file])
      if error_msg.present?
        redirect_to upload_csv_path, notice: error_msg
      else
          Post.import(params[:file], current_user.id)
          redirect_to posts_path, notice: Messages::UPLOAD_SUCCESSFUL
      end
    end
  end

  private
  # set post parameters
  # @return [<Type>] <description>
  def post_params
    params.require(:post).permit(:title, :description, :public_flag, :created_by, :updated_by)
  end
end





# tags[0][exhibition_item_choice_id]