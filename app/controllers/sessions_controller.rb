class SessionsController < BaseController
  layout 'new_application'
#  if AppConfig.closed_beta_mode
#    skip_before_filter :beta_login_required
#  end  

  def index
    redirect_to :action => "new"
  end  

  def new
    redirect_to user_path(current_user) and return if current_user
    @user_session = UserSession.new
   # render :layout => 'beta' if AppConfig.closed_beta_mode
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    
    @user_session.save do |result|

    if result
       current_user = @user_session.record
       
      flash[:notice] = :thanks_youre_now_logged_in.l
      redirect_back_or_default user_path(current_user)
    else
       flash[:notice] = :uh_oh_we_couldnt_log_you_in_with_the_username_and_password_you_entered_try_again.l
      render :action => :new
    end
  end
    
    
#    #begin
#      if @user_session.save
#        
#        current_user = @user_session.record #if current_user has been called before this, it will ne nil, so we have to make to reset it
#        
#        flash[:notice] = :thanks_youre_now_logged_in.l
#        redirect_back_or_default(user_path(current_user)) and return
#      else
#        flash[:notice] = :uh_oh_we_couldnt_log_you_in_with_the_username_and_password_you_entered_try_again.l
#        # redirect_to teaser_path and return
#        #render :action => :new and return
#        #redirect_back_or_default(login_path) and return
#      end

#    rescue OAuth::Unauthorized
#      flash[:notice] = "A autenticação pelo Twitter falhou. Erro: \"401 Não autorizado\""
#      render :action => :new
#    end
    
    
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = :youve_been_logged_out_hope_you_come_back_soon.l
    redirect_to new_session_path
  end

end
