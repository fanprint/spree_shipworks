shared_context 'for ShipWorks actions' do
  def create_admin_user
    unless Spree.user_class.find_by_email('spree@example.com').present?
      admin = Spree.user_class.create!(:email => 'spree@example.com', :password => 'spree123')
      admin.spree_roles << Spree::Role.where(name: :admin).first_or_create
    end
  end

  def create_normal_user
    create_admin_user
    Spree.user_class.create!(:email => 'customer@example.com', :password => 'spree123')
  end

  let(:valid_user_api_response) do
    create_admin_user
    params = { 'username' => 'spree@example.com', 'password' => 'spree123' }.
      merge('action' => action).
      merge(action_params || {})
    post '/shipworks/api', params
    response
  end

  let(:xml) do
    Nokogiri::XML.parse(valid_user_api_response.body)
  end

  let(:invalid_user_api_response) do
    create_admin_user
    params = { 'username' => 'spree@example.com', 'password' => 'invalid' }.
      merge('action' => action).
      merge(action_params || {})
    post '/shipworks/api', params
    response
  end

  let(:invalid_user_xml) do
    Nokogiri::XML.parse(invalid_user_api_response.body)
  end

  let(:unauthorized_user_api_response) do
    create_normal_user
    params = { 'username' => 'customer@example.com', 'password' => 'spree123' }.
      merge('action' => action).
      merge(action_params || {})
    post '/shipworks/api', params
    response
  end

  let(:unauthorized_user_xml) do
    Nokogiri::XML.parse(unauthorized_user_api_response.body)
  end

end
