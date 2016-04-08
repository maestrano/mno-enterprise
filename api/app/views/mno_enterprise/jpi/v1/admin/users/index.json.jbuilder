json.users @users, partial: 'user', as: :user
json.metadata @users.metadata if @users.respond_to?(:metadata)
