class Application < Sinatra::Base
  helpers do

    def class_for_number num
      if num < 0
        "red"
      elsif num > 0
        "green"
      else
        ""
      end
    end

    def checked_if(boolean)
      boolean == true ? 'checked' : ''
    end

    def selected_if(boolean)
      boolean == true ? 'selected' : ''
    end

    def todays_date
      Time.now.strftime("%Y-%m-%d") 
    end

    def title(*value)
      if !value.empty?
        @_title = value.first 
      elsif !@_full_title.blank?
        "<title>#{@_full_title}</title>"
      else
        "<title>#{@_title} - #{Application.Config.title}</title>"
      end
    end

    def full_title(*value); 
      @_full_title = value.first
    end

    def description(*value)
      unless value.empty?
        @_description = value.first
      else
        "<meta name='description' content='#{@_description}'>"
      end
    end

    def mobile_view(bool) 
      @_mobile = bool || false 
    end

    def viewport
      '<meta name="viewport" content="width=device-width,initial-scale=1">' if @_mobile
    end
    
    def partial(page, options={})
      erubis page, options.merge!(:layout => false)
    end
    
    def current_page?(*matches)
      matches.include? request.path
    end

    def path_class
      classes = request.path.split('/')
      classes.push('root') if request.path == '/'
      classes.join(" ")
    end
  end
end