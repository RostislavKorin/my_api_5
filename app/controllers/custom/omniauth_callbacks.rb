class Custom::OmniauthCallbacksController < DeviseTokenAuth::OmniauthCallbacksController
  rescue_from ActiveRecord::RecordNotUnique, with: :user_exists_with_other_providers

  def user_exists_with_other_providers
    @resource = resource_class.where({
                  email: auth_hash['email']]
                  })

    create_token_info
    set_token_on_resource
    create_auth_params

    if resource_class.devise_modules.include?(:confirmable)
      @resource.skip_confirmation!
    end

    if @resource.image.nil?
      @resource.image = get_large_image(auth_hash['info']['image'])
    end
    if @resource.nickname.nil?
      @resource.nickname = auth_hash['info']['nickname']
    end
    @resource.provider = auth_hash['info']['provider']

    sign_in(:user, @resource, store: false, bypass: false)
    @resource.save!

    yield @resource if block_given?

    render_data_or_redirect('deliverCredentials', @auth_params.as_json, @resource.as_json)
  end
end
