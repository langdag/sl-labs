module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      set_current_user || reject_unauthorized_connection
    end

    private
      def set_current_user
        if token = request.params[:token]
          decoded = JsonWebToken.decode(token)
          if decoded && user = User.find_by(id: decoded[:user_id])
            self.current_user = user
          else
            nil
          end
        else
          nil
        end
      end
  end
end
