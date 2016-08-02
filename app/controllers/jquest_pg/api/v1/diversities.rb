module JquestPg
  module API
    module V1
      class Diversities < Grape::API
        resource :diversities do
          desc "Return list of diversities"
          get do
            Diversity.
              page(params[:page]).
              # Default limit is 25
              per(params[:limit])
          end

          desc "Create a diversity object"
          post do
            diversity = Diversity.create value: params.value,
                                         resource_a: Person.find(params.resource_a.id),
                                         resource_b: Person.find(params.resource_b.id)
            # Go to the next level
            current_user_point.next_level unless progression.remaining_assignments > 0
            # Returns the new diversity
            diversity
          end

          get :request do
            authenticate!
            # No one unassigned by default
            unassigned = Assignment.none
            person = progression.assignment.resource.person
            # Loop until a diversity request can be created with this unassigned person
            begin
              # An assigned person can only be in diversity twice
              return nil if Diversity.occurrences(person) > 2
              # Loop until a diversity request can be created with this unassigned person
              loop do
                # Get other users' assignments
                other_users_assignments = Assignment.unassigned_to(current_user).
                  # ...joins through the mandatures table using the assignment's resource_id
                  joins('INNER JOIN jquest_pg_mandatures ON jquest_pg_mandatures.id = assignments.resource_id').
                  joins('INNER JOIN jquest_pg_people ON jquest_pg_people.id = jquest_pg_mandatures.person_id').
                  # Filter other assignments to only get the one with images
                  where.not(jquest_pg_people: { image: nil })
                puts other_users_assignments
                # Collect a random assignment
                unassigned = other_users_assignments.order("RANDOM()").limit(1).first
                # Break if there is to few unassigned people
                break if unassigned.nil?
                # Break if the people have not been compared yet
                break unless Diversity.both_exists?(unassigned.resource.person, person)
              end
              # Nothing to propose
              return nil if unassigned.nil?
              # Instanciate a diversity record without saving it
              Diversity.new(resource_a: unassigned.resource.person, resource_b: person)
            end
          end

          get :ranking do
            authenticate!
            # Return all diversities ranking
            Diversity.as_ranking.map { |item| item[1] }
          end
        end
      end
    end
  end
end
