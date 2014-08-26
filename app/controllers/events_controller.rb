class EventsController < ApplicationController
  # This is our new function that comes before Devise's one
  before_filter :authenticate_user_from_token!

  # This is Devise's authentication
  before_filter :authenticate_user!

  skip_before_filter :verify_authenticity_token,
                :if => Proc.new { |c| c.request.format == 'application/json' }


  respond_to :json

  def index
      events = current_user.events
      events = events.map{|event|
        eventJSON = event.as_json
        participants = event.users;
        eventJSON['participants'] = participants
        eventJSON
      }

      render :status => 200,
         :json => { success: true,
           events: events
        }
  end

  def create
     params[:start_time] = Time.at(params[:start_time]).to_datetime.strftime("%Y-%m-%d")
     event = Event.create(params.permit(:name, :description, :start_time, :latitute, :longitude, :address))
     friend_array = []
     
     params[:participants].each do |participant|
        friend = User.find(participant['id'])
        if(friend) 
          friend_array.push(friend)
        else
           render :status => 400,
           :json => { success: false,
             friend_id_not_found: friend_id}
        end
     end
     event.users = friend_array.push(current_user)

     if (event.save)
       eventJSON = event.as_json;
       participants = event.users;
       eventJSON['participants'] = participants

       render :status => 200,
         :json => { success: true,
                     event: eventJSON}
        
     else
         render :status => 400,
         :json => { success: false,
          error: event.errors}
        
     end
  end

  def show
       render :status => 200,
         :json => { success: true,
                     events: "make me yo"}
  end
end
