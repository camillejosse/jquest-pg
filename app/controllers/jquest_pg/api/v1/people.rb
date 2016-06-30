module JquestPg
  module API
    module V1
      class People < Grape::API
        resource :people do

          desc "Return list of people"
          get do
            Person.page(params[:page])
          end

          route_param :assigned do
            desc "Return list of people assigned to the user"
            get do
              authenticate!
              # Collect person assigned to this user
              Person.assigned_to(current_user, season).
                # Paginates results
                page(params[:page])
            end

            desc "Return list of people assigned to the user and still pending"
            get :pending do
              authenticate!
              # Collect person assigned to this user
              Person.assigned_to(current_user, season, true, :pending).              
                # Paginates results
                page(params[:page])
            end
          end

          desc "Return list of people not assigned to the user"
          get :unassigned do
            authenticate!
            # Collect person unassigned to this user
            Person.unassigned_to(current_user, true).
                   order("RANDOM()").
                   page(params[:page])
          end

          params do
            requires :id, type: Integer, desc: 'person id'
          end
          route_param :id do

            desc "Get a person"
            get do
              Person.find(params[:id])
            end

            desc "Update a person"
            put do
              authenticate!
              person = Person.find params[:id]
              # The person must be assigned to that user's progression
              authorize person, :update?
              # Create or update sources
              params[:sources].map! do |source|
                source.resource = person
                Source.update_or_create source
              end
              person.update_attributes permitted_params(person, params)
              # Return a person
              person
            end

            desc "Genderize a person"
            params do
              requires :gender, type: String, desc: 'new gender'
            end
            post :genderize do
              authenticate!
              person = Person.find params[:id]
              # The person must be assigned to that user's progression
              authorize person, :update?
              # Change the gender
              person.gender = params[:gender]
              # Ensure a version is created even if the value is the same
              person.touch_with_version unless person.gender_changed?
              person.save!
              # Return a person
              person
            end
          end

        end
      end
    end
  end
end
