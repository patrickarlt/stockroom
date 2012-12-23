class Application < Sinatra::Base
  helpers do 

    def logged_in?
      (!current_user.nil? && session[:session_id]) ? true : false
    end

    def require_session
      redirect "/login" unless logged_in? && current_user
    end

    def current_user
      begin
        current_user ||= Account.find(session[:user_id]) if(session[:user_id] && session[:session_id])
      rescue
        session.clear
        current_user = nil
        redirect "/login"
      end
    end

    def logged_out?
      (current_user.nil? && session[:session_id].nil?) ? true : false
    end

  end
end
